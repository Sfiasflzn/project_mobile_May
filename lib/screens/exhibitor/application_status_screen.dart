import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class ApplicationStatusScreen extends StatelessWidget {
  final String bookingId;

  const ApplicationStatusScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/exhibitor'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Application\nSubmitted!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time,
                      color: AppColors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Status: Pending Review',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Booking ID: $bookingId',
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),

            const Text(
              'Your application is currently being reviewed by the organizer.\n'
                  'You will be notified once your application has been approved',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 40),

            CustomButton(
              text: 'Go to My Application',
              onPressed: () => context.go('/exhibitor/applications'),
            ),
            const SizedBox(height: 12),

            CustomButton(
              text: 'Start New Application',
              onPressed: () => context.go('/exhibitor'),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}