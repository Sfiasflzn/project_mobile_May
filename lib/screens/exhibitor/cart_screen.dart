import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booth_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  final BoothModel booth;
  final DateTime startDate;
  final DateTime endDate;

  const CartScreen({
    super.key,
    required this.booth,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _removed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart ${_removed ? "" : "1 item"}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _removed
            ? const Center(child: Text('Cart is empty'))
            : Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booth ${widget.booth.boothId}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    _row('Size', '${widget.booth.size}×${widget.booth.size}m'),
                    _row('Price',
                        'RM ${widget.booth.price.toStringAsFixed(0)}'),
                    _row('Date',
                        '${widget.startDate.day}–${widget.endDate.day} ${_monthName(widget.startDate.month)}'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => _removed = true),
                      child: const Text('Remove',
                          style: TextStyle(color: AppColors.red)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                    'RM ${widget.booth.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Proceed to Application',
              onPressed: () {
                context.push('/exhibitor/application-form', extra: {
                  'booth': widget.booth,
                  'startDate': widget.startDate,
                  'endDate': widget.endDate,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value),
        ],
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
