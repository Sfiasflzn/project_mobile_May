import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/event_card_widget.dart';

class EventDirectoryScreen extends StatefulWidget {
  const EventDirectoryScreen({super.key});

  @override
  State<EventDirectoryScreen> createState() => _EventDirectoryScreenState();
}

class _EventDirectoryScreenState extends State<EventDirectoryScreen> {
  final _eventService = EventService();
  String _searchQuery = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExhibitSpace',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Login', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
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

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Upcoming', 'Ongoing', 'Ended'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.blue.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Events list
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: _eventService.getPublishedEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events available'));
                }

                var events = snapshot.data!;

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  events = events
                      .where((e) => e.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Filter by status
                if (_filter != 'All') {
                  events = events
                      .where((e) =>
                  e.status.toLowerCase() == _filter.toLowerCase())
                      .toList();
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (ctx, i) => EventCardWidget(
                    event: events[i],
                    onTap: () => context.push('/event/${events[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Login'),
        ],
        onTap: (i) {
          if (i == 2) context.push('/login');
        },
      ),
    );
  }
}
