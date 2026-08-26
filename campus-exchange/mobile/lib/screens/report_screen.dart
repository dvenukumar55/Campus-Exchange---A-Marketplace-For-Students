import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../services/report_service.dart';
import '../widgets/custom_text_field.dart';

class ReportScreen extends StatefulWidget {
  final Listing listing;

  const ReportScreen({Key? key, required this.listing}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final ReportService _reportService = ReportService();

  String _selectedReason = AppConstants.reportReasons.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _reportService.createReport(
        listingId: widget.listing.listingId,
        reason: _selectedReason,
        description: _descController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted. Campus moderation will review this listing.', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: ${e.toString()}', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Report Listing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppTheme.warningColor, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reporting: ${widget.listing.title}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Help keep Campus Exchange safe and transparent by reporting misleading items or inappropriate conduct.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Reason for Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: AppConstants.reportReasons.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _descController,
                label: 'Details & Evidence',
                hint: 'Describe why this listing violates campus guidelines...',
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Please provide at least 5 characters of explanation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Submit Report to Moderation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
