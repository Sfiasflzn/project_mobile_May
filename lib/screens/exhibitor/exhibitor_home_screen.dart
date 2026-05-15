import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/event_card_widget.dart';

class ExhibitorHomeScreen extends StatelessWidget {
  const ExhibitorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exhibition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => context.push('/exhibitor/applications'),
            tooltip: 'My Applications',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: eventService.getPublishedEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, i) {
              final event = snapshot.data![i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${event.startDate.day}–${event.endDate.day} ${_monthName(event.startDate.month)} | ${event.venue}'),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        context.push('/exhibitor/select-booth/${event.id}'),
                    child: const Text('Select Booth'),
                  ),
                ),
              );
            },
          );
        },
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
