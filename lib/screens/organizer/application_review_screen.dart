import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key});

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  final _bookingService = BookingService();
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Review')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Rejected']
                    .map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: _bookingService.getAllBookings(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var bookings = snapshot.data!;
                if (_filter != 'All') {
                  bookings = bookings
                      .where((b) =>
                  b.status.toLowerCase() == _filter.toLowerCase())
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (ctx, i) {
                    final booking = bookings[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(booking.companyName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('Booth ${booking.boothId}',
                                    style: const TextStyle(
                                        color: AppColors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (booking.status == 'pending') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateStatus(
                                          booking.id, 'approved'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.green),
                                      child: const Text('Approved',
                                          style:
                                          TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _updateStatus(
                                          booking.id, 'rejected'),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: booking.status == 'approved'
                                      ? AppColors.green.withOpacity(0.1)
                                      : AppColors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  booking.status.toUpperCase(),
                                  style: TextStyle(
                                    color: booking.status == 'approved'
                                        ? AppColors.green
                                        : AppColors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    await _bookingService.updateBookingStatus(bookingId, status);
  }
}