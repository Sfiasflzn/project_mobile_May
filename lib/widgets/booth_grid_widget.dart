import 'package:flutter/material.dart';
import '../models/booth_model.dart';
import '../utils/app_colors.dart';

class BoothGridWidget extends StatelessWidget {
  final List<BoothModel> booths;
  final bool isReadOnly;
  final Function(BoothModel)? onBoothTap;
  final String? selectedBoothId;

  const BoothGridWidget({
    super.key,
    required this.booths,
    this.isReadOnly = false,
    this.onBoothTap,
    this.selectedBoothId,
  });

  Color _boothColor(BoothModel booth) {
    if (booth.boothId == selectedBoothId) return AppColors.blue;
    switch (booth.status) {
      case 'booked':
        return AppColors.grey.withOpacity(0.5);
      case 'available':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {

    final maxRow = booths.isEmpty
        ? 0
        : booths.map((b) => b.row).reduce((a, b) => a > b ? a : b);
    final maxCol = booths.isEmpty
        ? 0
        : booths.map((b) => b.col).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Legend
        Row(
          children: [
            _legendItem(Colors.white, 'Available', border: true),
            const SizedBox(width: 12),
            _legendItem(AppColors.blue, 'Selected'),
            const SizedBox(width: 12),
            _legendItem(AppColors.grey.withOpacity(0.5), 'Booked'),
          ],
        ),
        const SizedBox(height: 8),

        // Grid
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: List.generate(maxRow + 1, (row) {
              return Row(
                children: List.generate(maxCol + 1, (col) {
                  final booth = booths.firstWhere(
                        (b) => b.row == row && b.col == col,
                    orElse: () => BoothModel(
                      id: '',
                      eventId: '',
                      boothId: '',
                      type: '',
                      size: 0,
                      price: 0,
                      amenities: [],
                      row: row,
                      col: col,
                    ),
                  );

                  if (booth.boothId.isEmpty) {
                    return const SizedBox(width: 44, height: 44);
                  }

                  return GestureDetector(
                    onTap: (!isReadOnly && booth.status == 'available')
                        ? () => onBoothTap?.call(booth)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _boothColor(booth),
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          booth.boothId,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: booth.boothId == selectedBoothId
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: border ? Border.all(color: AppColors.grey) : null,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }
}