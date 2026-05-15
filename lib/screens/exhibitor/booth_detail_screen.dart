import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booth_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class BoothDetailScreen extends StatelessWidget {
  final BoothModel booth;
  final DateTime startDate;
  final DateTime endDate;

  const BoothDetailScreen({
    super.key,
    required this.booth,
    required this.startDate,
    required this.endDate,
  });

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BOOTH DETAILS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grey,
                    letterSpacing: 1)),
            const SizedBox(height: 12),
            Text('Booth ${booth.boothId}:',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailRow('Size', '${booth.size}×${booth.size}m'),
            _detailRow('Price', 'RM ${booth.price.toStringAsFixed(0)}'),
            _detailRow('Type', booth.type.toUpperCase()),
            const SizedBox(height: 16),
            const Text('AMENITIES',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grey,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            ...booth.amenities.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.green),
                  const SizedBox(width: 8),
                  Text('• $a'),
                ],
              ),
            )),
            const Spacer(),
            CustomButton(
              text: 'Add to Cart',
              onPressed: () {
                context.push('/exhibitor/cart', extra: {
                  'booth': booth,
                  'startDate': startDate,
                  'endDate': endDate,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
