import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exhibitions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review),
            onPressed: () => context.push('/organizer/review'),
            tooltip: 'Application Review',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exhibitions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: AppColors.lightGrey,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: eventService.getOrganizerEvents(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No exhibition. Create new!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, i) {
                    final event = snapshot.data![i];
                    return _EventManageCard(event: event,
                        eventService: eventService);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/organizer/create-event'),
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create New Exhibition',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _EventManageCard extends StatelessWidget {
  final EventModel event;
  final EventService eventService;

  const _EventManageCard(
      {required this.event, required this.eventService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(event.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: event.status == 'upcoming'
                        ? AppColors.blue.withOpacity(0.1)
                        : AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: event.status == 'upcoming'
                            ? AppColors.blue
                            : AppColors.green,
                        style: BorderStyle.solid),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: TextStyle(
                        color: event.status == 'upcoming'
                            ? AppColors.blue
                            : AppColors.green,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
                '${event.startDate.day}–${event.endDate.day} ${_month(event.startDate.month)} ${event.startDate.year}',
                style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionBtn('Edit', AppColors.blue, () {
                  context.push('/organizer/create-event', extra: event);
                }),
                const SizedBox(width: 8),
                _actionBtn('Booth', AppColors.green, () {
                  context.push('/organizer/booth-management/${event.id}');
                }),
                const SizedBox(width: 8),
                _actionBtn('Apps', AppColors.orange, () {
                  context.push('/organizer/review');
                }),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Exhibition?'),
                    content: Text('Delete "${event.name}"?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await eventService.deleteEvent(event.id);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red),
              ),
              child: const Text('Delete', style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _month(int m) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m];
  }
}