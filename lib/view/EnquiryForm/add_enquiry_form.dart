// add_enquiry_form_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpm/model/AddEnquiryForm/AddEnquiryFormData.dart';
import 'package:mpm/repository/add_enquiry_form_repository/add_enquiry_form_repo.dart';
import 'package:mpm/utils/AppDrawer.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';

class AddEnquiryFormView extends StatefulWidget {
  final String memberId;
  final String createdBy;
  final String addedBy;

  const AddEnquiryFormView({
    super.key,
    required this.memberId,
    required this.createdBy,
    required this.addedBy,
  });

  @override
  State<AddEnquiryFormView> createState() => _AddEnquiryFormViewState();
}

class _AddEnquiryFormViewState extends State<AddEnquiryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _repository = EnquiryRepository();

  var _isLoading = false;
  var _lastSubmissionStatus = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastSubmissionStatus = '';
    });

    try {
      final enquiry = EnquiryData(
        memberId: widget.memberId,
        message: _messageController.text.trim(),
        enquiryStatus: 'pending',
        addedBy: widget.memberId,
        createdBy: widget.memberId,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );

      final response = await _repository.submitEnquiry(enquiry);

      if (!mounted) return;

      final bool isSuccess = response['status'] == true;
      final String responseMessage = response['msg'] ?? 'Unknown error';

      setState(() {
        _lastSubmissionStatus = isSuccess ? 'success' : 'failed';
      });

      if (isSuccess) {
        _messageController.clear();
        _showSuccessSnackbar('Enquiry submitted successfully!');
      } else {
        _showErrorSnackbar(responseMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Enquiry Form",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your enquiry message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEnquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.red_color),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              _buildContactInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Need Immediate Assistance?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            children: [
              TextSpan(text: 'For urgent help, you may WhatsApp or call:\n\n'),
              TextSpan(
                text: 'Ramavtar ji Chandak\n',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: '93234 50502\n\n'),
              TextSpan(
                text: 'Satya Narayan ji Somani\n',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(text: '98210 81143'),
            ],
          ),
        ),
      ],
    );
  }
}
