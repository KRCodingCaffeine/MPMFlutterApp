import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../repository/qr_code_scanner_repository/qr_code_scanner_repo.dart';

class QRScannerScreen extends StatefulWidget {
  final String scanType;

  const QRScannerScreen({Key? key, required this.scanType}) : super(key: key);

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
  bool isDialogOpen = false;

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
          "${widget.scanType} Scanner",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          /// CAMERA
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

          /// DARK OVERLAY
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

          /// SCAN LINE
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
                  color: widget.scanType == "Gate Entry"
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
              );
            },
          ),

          /// BOTTOM TEXT
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(
                scannedData != null
                    ? "${widget.scanType} Scanned: $scannedData"
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
      if (isDialogOpen) return;

      final scannedValue = scanData.code;

      if (scannedValue != null && scannedValue.isNotEmpty) {
        setState(() => scannedData = scannedValue);

        isDialogOpen = true;
        controller?.pauseCamera();

        try {
          late final bool resultStatus;
          late final String resultMessage;
          late final Color resultBannerColor;

          if (widget.scanType == "Meal Box Entry") {
            final result = await _repository.scanQrCodeForFood(scannedValue);
            resultStatus = result.status == true;
            resultMessage = result.message ?? "Food Entry Done";
            resultBannerColor = resultStatus ? Colors.green : Colors.red;
          } else {
            final result = await _repository.scanQrCode(scannedValue);
            resultStatus = result.status == true;
            resultMessage = result.message ?? "Success";
            resultBannerColor = resultStatus ? Colors.green : Colors.red;
          }

          if (_isAlreadyRegisteredMessage(resultMessage)) {
            await _showAlreadyRegisteredDialog(resultMessage);
            await Future.delayed(const Duration(milliseconds: 500));
            controller?.resumeCamera();
            isDialogOpen = false;
            return;
          }

          if (!resultStatus) {
            _showTopBanner(context, resultMessage, resultBannerColor);
            await Future.delayed(const Duration(milliseconds: 500));
            controller?.resumeCamera();
            isDialogOpen = false;
            return;
          }

          final bool? proceed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.scanType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(height: 8),
                    const Divider(thickness: 1, color: Colors.grey),
                  ],
                ),
                content: Text(
                  "$scannedValue\n\nDo you want to verify this attendee’s event check-in?",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.scanType == "Gate Entry"
                          ? Colors.green
                          : Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );

          if (proceed == true) {
            _showTopBanner(context, resultMessage, resultBannerColor);
          }
        } catch (e) {
          _showTopBanner(context, "Error: $e", Colors.red);
        }

        await Future.delayed(const Duration(milliseconds: 500));
        controller?.resumeCamera();
        isDialogOpen = false;
      }
    });
  }

  bool _isAlreadyRegisteredMessage(String? message) {
    final normalizedMessage = message?.toLowerCase() ?? '';
    return normalizedMessage.contains('already') &&
        (normalizedMessage.contains('register') ||
            normalizedMessage.contains('entry') ||
            normalizedMessage.contains('check-in') ||
            normalizedMessage.contains('checked in'));
  }

  Future<void> _showAlreadyRegisteredDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Already Registered',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: Colors.grey),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    ColorHelperClass.getColorFromHex(ColorResources.red_color),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showTopBanner(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: color,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        actions: const [SizedBox()],
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
