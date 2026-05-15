import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';

class AllReservationsScreen extends StatefulWidget {
  const AllReservationsScreen({super.key});

  @override
  State<AllReservationsScreen> createState() => _AllReservationsScreenState();
}

class _AllReservationsScreenState extends State<AllReservationsScreen> {
  final _bookingService = BookingService();
  String _filter = 'All';

  Color _statusColor(String s) {
    switch (s) {
      case 'approved': return AppColors.green;
      case 'rejected': return AppColors.red;
      case 'cancelled': return AppColors.grey;
      default: return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Pending', 'Approved', 'Rejected', 'Cancelled']
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
          const SizedBox(height: 8),
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
                  itemCount: bookings.length,
                  itemBuilder: (ctx, i) {
                    final b = bookings[i];
                    return ListTile(
                      title: Text('${b.companyName} · Booth ${b.boothId}'),
                      subtitle: Text(b.eventId),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(b.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          b.status.toUpperCase(),
                          style: TextStyle(
                              color: _statusColor(b.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
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
}
