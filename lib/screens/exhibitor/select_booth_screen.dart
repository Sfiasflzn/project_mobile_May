import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booth_model.dart';
import '../../services/booth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/booth_grid_widget.dart';

class SelectBoothScreen extends StatefulWidget {
  final String eventId;

  const SelectBoothScreen({super.key, required this.eventId});

  @override
  State<SelectBoothScreen> createState() => _SelectBoothScreenState();
}

class _SelectBoothScreenState extends State<SelectBoothScreen> {
  final _boothService = BoothService();
  BoothModel? _selectedBooth;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Booth'),
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
            // Date picker
            const Text('Select Dates:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date',
                          style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      GestureDetector(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${_startDate.day} ${_monthName(_startDate.month)}'),
                              const Icon(Icons.expand_more, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date',
                          style: TextStyle(fontSize: 12, color: AppColors.grey)),
                      GestureDetector(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${_endDate.day} ${_monthName(_endDate.month)}'),
                              const Icon(Icons.expand_more, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('BOOTH AVAILABILITY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),

            // Booth grid
            StreamBuilder<List<BoothModel>>(
              stream: _boothService.getBoothsForEvent(widget.eventId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return BoothGridWidget(
                  booths: snapshot.data!,
                  isReadOnly: false,
                  selectedBoothId: _selectedBooth?.boothId,
                  onBoothTap: (booth) {
                    setState(() => _selectedBooth = booth);
                  },
                );
              },
            ),

            if (_selectedBooth != null) ...[
              const SizedBox(height: 12),
              Text(
                'Selected Booth: ${_selectedBooth!.boothId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push(
                    '/exhibitor/booth-detail',
                    extra: {
                      'booth': _selectedBooth,
                      'startDate': _startDate,
                      'endDate': _endDate,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('View Booth Details →',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
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