import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../repository/qr_code_scanner_repository/qr_code_scanner_repo.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  String? scannedData;
  late AnimationController _animationController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final QrCodeScannerRepository _repository = QrCodeScannerRepository();
  bool isDialogOpen = false; // prevent multiple dialogs

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final cutOutSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Text(
          'QR Code Scanner',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          // Camera view
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.green,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: cutOutSize,
            ),
          ),

          // Overlay mask
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.green.withOpacity(0.2),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: cutOutSize,
                    height: cutOutSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated scanning line
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 -
                    cutOutSize / 2 +
                    (_animationController.value * cutOutSize),
                left: MediaQuery.of(context).size.width / 2 - cutOutSize / 2,
                child: Container(
                  width: cutOutSize,
                  height: 2,
                  color: Colors.greenAccent,
                ),
              );
            },
          ),

          // Bottom text
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(
                scannedData != null
                    ? "Scanned: $scannedData"
                    : "Align the QR code within the frame to scan",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (isDialogOpen) return; // avoid duplicate dialogs
      final String? scannedValue = scanData.code;

      if (scannedValue != null && scannedValue.isNotEmpty) {
        setState(() {
          scannedData = scannedValue;
        });

        //log('QR Scanned: $scannedValue');
        isDialogOpen = true;
        controller?.pauseCamera();

        // First popup: show scanned value and ask to proceed
        final bool? proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Attendee - $scannedValue QR Code Detected',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Do you want to verify this attendee’s event check-in?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );

        if (proceed == true) {
          try {
            final result = await _repository.scanQrCode(scannedValue);

            if (result.status == true) {
              _showTopBanner(context,
                  result.message ?? "Attendance confirmed", Colors.green);
            } else {
              _showTopBanner(context,
                  result.message ?? "Invalid attendee code", Colors.red);
            }
          } catch (e) {
            _showTopBanner(context, "Error: $e", Colors.red);
          }
        }

        // Resume scanning after short delay
        await Future.delayed(const Duration(milliseconds: 500));
        controller?.resumeCamera();
        isDialogOpen = false;
      }
    });
  }

  void _showTopBanner(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: color,
        content: Text(
          message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          SizedBox.shrink(),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
