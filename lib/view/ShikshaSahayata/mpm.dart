import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class MPMView extends StatefulWidget {
  const MPMView({super.key});

  @override
  State<MPMView> createState() => _MPMViewState();
}

class _MPMViewState extends State<MPMView> {
  /// 🔹 SIGNATURE CONTROLLERS
  final SignatureController applicantController =
  SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  final SignatureController guardianController =
  SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  bool applicantLocked = false;
  bool guardianLocked = false;

  /// 🔹 DOCUMENT CHECKLIST (POINT NO. 15)
  bool docAadhar = false;
  bool docMarksheet = false;
  bool docBonafide = false;
  bool docIncome = false;
  bool docOther = false;

  bool get allDocumentsAccepted =>
      docAadhar &&
          docMarksheet &&
          docBonafide &&
          docIncome &&
          docOther;

  @override
  void dispose() {
    applicantController.dispose();
    guardianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
        ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: const Text(
          "MPM Verification",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 🔹 DOCUMENT CHECKLIST
            _buildDocumentChecklist(),

            const SizedBox(height: 20),

            /// 🔹 APPLICANT SIGNATURE
            _buildSignatureCard(
              title: "Applicant Signature",
              controller: applicantController,
              locked: applicantLocked,
              onSave: () async {
                Uint8List? data = await applicantController.toPngBytes();
                if (data != null) {
                  setState(() => applicantLocked = true);
                  _showSavedSnack();
                }
              },
              onClear: () {
                applicantController.clear();
              },
            ),

            const SizedBox(height: 20),

            /// 🔹 GUARDIAN SIGNATURE
            _buildSignatureCard(
              title: "Father / Guardian Signature",
              controller: guardianController,
              locked: guardianLocked,
              onSave: () async {
                Uint8List? data = await guardianController.toPngBytes();
                if (data != null) {
                  setState(() => guardianLocked = true);
                  _showSavedSnack();
                }
              },
              onClear: () {
                guardianController.clear();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===================== DOCUMENT CHECKLIST =====================

  bool docDeclaration = false; // 🔹 ADD THIS VARIABLE IN STATE

  Widget _buildDocumentChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        _checkPoint(
          "Aadhaar Card (both sides)",
          docAadhar,
              (v) => setState(() => docAadhar = v),
        ),

        _checkPoint(
          "10th to HSC (12th) Marksheet",
          docMarksheet,
              (v) => setState(() => docMarksheet = v),
        ),

        _checkPoint(
          "College Bonafide Certificate",
          docBonafide,
              (v) => setState(() => docBonafide = v),
        ),

        _checkPoint(
          "Any other required document",
          docOther,
              (v) => setState(() => docOther = v),
        ),

        const SizedBox(height: 12),

        /// 🔹 DECLARATION CHECKBOX
        _checkPoint(
          "I hereby confirm that all the above information and documents provided by me are true.",
          docDeclaration,
              (v) => setState(() => docDeclaration = v),
        ),
      ],
    );
  }

  Widget _checkPoint(
      String text, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ===================== SIGNATURE CARD =====================

  Widget _buildSignatureCard({
    required String title,
    required SignatureController controller,
    required bool locked,
    required VoidCallback onSave,
    required VoidCallback onClear,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AbsorbPointer(
                absorbing: locked,
                child: Signature(
                  controller: controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: locked ? null : onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text("Clear"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!allDocumentsAccepted ||
                        controller.isEmpty ||
                        locked)
                        ? null
                        : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorHelperClass.getColorFromHex(
                          ColorResources.red_color),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(locked ? "Saved" : "Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Signature saved and locked successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
