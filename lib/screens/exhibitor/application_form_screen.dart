import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booth_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class ApplicationFormScreen extends StatefulWidget {
  final BoothModel booth;
  final DateTime startDate;
  final DateTime endDate;

  const ApplicationFormScreen({
    super.key,
    required this.booth,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _companyNameCtrl = TextEditingController();
  final _companyDescCtrl = TextEditingController();
  final _exhibitProfileCtrl = TextEditingController();
  final _bookingService = BookingService();
  bool _isLoading = false;

  final Map<String, bool> _addOns = {
    'Extra Furniture': false,
    'Promotional Spot': false,
    'Extended WiFi': false,
  };

  Future<void> _submit() async {
    if (_companyNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter company name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final selectedAddOns = _addOns.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final booking = BookingModel(
        id: '',
        exhibitorId: uid,
        eventId: widget.booth.eventId,
        boothId: widget.booth.boothId,
        companyName: _companyNameCtrl.text.trim(),
        companyDescription: _companyDescCtrl.text.trim(),
        exhibitProfile: _exhibitProfileCtrl.text.trim(),
        addOns: selectedAddOns,
        totalPrice: widget.booth.price,
        startDate: widget.startDate,
        endDate: widget.endDate,
        createdAt: DateTime.now(),
      );

      final bookingId = await _bookingService.createBooking(booking);

      if (mounted) {
        context.pushReplacement('/exhibitor/application-status', extra: bookingId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: Tech Expo 2026',
                style: const TextStyle(color: AppColors.grey)),
            Text(
                'Date: ${widget.startDate.day}–${widget.endDate.day} ${_monthName(widget.startDate.month)}',
                style: const TextStyle(color: AppColors.grey)),
            const SizedBox(height: 16),

            _buildField('Company Name', _companyNameCtrl),
            _buildField('Company Description', _companyDescCtrl, maxLines: 3),
            _buildField('Exhibit Profile', _exhibitProfileCtrl),

            const SizedBox(height: 8),
            const Text('ADD-ONS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grey)),
            ..._addOns.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.key),
                value: entry.value,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) =>
                    setState(() => _addOns[entry.key] = val!),
              );
            }),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Submit Application',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}