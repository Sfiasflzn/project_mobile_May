import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/app_colors.dart';

class AllExhibitionsScreen extends StatelessWidget {
  const AllExhibitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibitions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/organizer/create-event'),
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: eventService.getAllEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (ctx, i) {
                    final event = events[i];
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text('${event.venue} · ${event.startDate.day}/${event.startDate.month}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.isPublished ? 'ON' : 'OFF',
                            style: TextStyle(
                              color: event.isPublished
                                  ? AppColors.green
                                  : AppColors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: event.isPublished,
                            onChanged: (val) =>
                                eventService.togglePublish(event.id, val),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: AppColors.red, size: 20),
                            onPressed: () =>
                                eventService.deleteEvent(event.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}