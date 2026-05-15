import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';

class EventCardWidget extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCardWidget({super.key, required this.event, required this.onTap});

  Color _statusColor() {
    switch (event.status) {
      case 'upcoming':
        return AppColors.blue;
      case 'ongoing':
        return AppColors.green;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${event.venue} · ${fmt.format(event.startDate)}–${fmt.format(event.endDate)}',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
