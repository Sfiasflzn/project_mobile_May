import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? existingEvent; // Null = create, ada = edit

  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _nameCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _maxExhibitorsCtrl = TextEditingController();
  final _eventService = EventService();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _preventAdjacentCompetitors = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      final e = widget.existingEvent!;
      _nameCtrl.text = e.name;
      _venueCtrl.text = e.venue;
      _descCtrl.text = e.description;
      _maxExhibitorsCtrl.text = e.maxExhibitors.toString();
      _startDate = e.startDate;
      _endDate = e.endDate;
      _preventAdjacentCompetitors = e.preventAdjacentCompetitors;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _save({bool isDraft = false}) async {
    if (_nameCtrl.text.isEmpty || _venueCtrl.text.isEmpty ||
        _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required information')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final event = EventModel(
        id: widget.existingEvent?.id ?? '',
        name: _nameCtrl.text.trim(),
        venue: _venueCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        description: _descCtrl.text.trim(),
        maxExhibitors: int.tryParse(_maxExhibitorsCtrl.text) ?? 0,
        preventAdjacentCompetitors: _preventAdjacentCompetitors,
        isPublished: !isDraft,
        organizerId: uid,
        status: 'upcoming',
      );

      if (widget.existingEvent != null) {
        await _eventService.updateEvent(event);
      } else {
        await _eventService.createEvent(event);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isDraft ? 'Saved as draft' : 'Event saved!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: Text(
            widget.existingEvent != null ? 'Edit Exhibition' : 'Create Exhibition'),
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
            _field('Exhibition Name *', _nameCtrl),
            _field('Venue / Location *', _venueCtrl),

            Row(
              children: [
                Expanded(child: _datePicker('Start Date', _startDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _datePicker('End Date', _endDate, () => _pickDate(false))),
              ],
            ),

            const SizedBox(height: 14),
            _field('Description', _descCtrl, maxLines: 3),
            _field('Max Exhibitors', _maxExhibitorsCtrl,
                type: TextInputType.number),

            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Prevent adjacent competitor booths'),
              value: _preventAdjacentCompetitors,
              onChanged: (v) => setState(() => _preventAdjacentCompetitors = v),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Exhibition',
              onPressed: () => _save(),
              isLoading: _isLoading,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Save as Draft',
              onPressed: () => _save(isDraft: true),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Choose date',
              style: TextStyle(
                color: date != null ? AppColors.primary : AppColors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}