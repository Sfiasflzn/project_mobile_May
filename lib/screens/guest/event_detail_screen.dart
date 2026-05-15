import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/booth_model.dart';
import '../../models/event_model.dart';
import '../../services/booth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/booth_grid_widget.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final boothService = BoothService();
    final fmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${event.venue} · ${fmt.format(event.startDate)}–${fmt.format(event.endDate)}',
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(event.status.toUpperCase(),
                  style: const TextStyle(color: AppColors.blue, fontSize: 12)),
            ),
            const SizedBox(height: 16),

            const Text('FLOOR PLAN [READ ONLY]',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grey)),
            const SizedBox(height: 8),

            // Booth grid (read-only for guest)
            StreamBuilder<List<BoothModel>>(
              stream: boothService.getBoothsForEvent(event.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return BoothGridWidget(
                  booths: snapshot.data!,
                  isReadOnly: true,
                  onBoothTap: null,
                );
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/login-prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Book a Booth → Login Required',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
