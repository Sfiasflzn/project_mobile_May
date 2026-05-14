import 'package:flutter/material.dart';
import '../../services/booth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class BoothTypesScreen extends StatefulWidget {
  const BoothTypesScreen({super.key});

  @override
  State<BoothTypesScreen> createState() => _BoothTypesScreenState();
}

class _BoothTypesScreenState extends State<BoothTypesScreen> {
  final _boothService = BoothService();
  final _nameCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _addType() async {
    setState(() => _isLoading = true);
    try {
      await _boothService.addBoothType(
        name: _nameCtrl.text.trim(),
        size: double.tryParse(_sizeCtrl.text) ?? 0,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        available: true,
      );
      _nameCtrl.clear();
      _sizeCtrl.clear();
      _priceCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth type added!')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booths')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booth Types',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            // Existing types
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _boothService.getBoothTypes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Table(
                  border: TableBorder.all(color: AppColors.lightGrey),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: AppColors.lightGrey),
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(8), child: Text('SIZE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(8), child: Text('PRICE(MYR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(padding: EdgeInsets.all(8), child: Text('AVAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                      ],
                    ),
                    ...snapshot.data!.map((type) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8), child: Text(type['name'] ?? '')),
                        Padding(padding: const EdgeInsets.all(8), child: Text('${type['size']} sqm')),
                        Padding(padding: const EdgeInsets.all(8), child: Text('${type['price']}')),
                        Padding(padding: const EdgeInsets.all(8),
                            child: Text(type['available'] == true ? 'Yes' : 'No',
                                style: TextStyle(
                                    color: type['available'] == true
                                        ? AppColors.green
                                        : AppColors.red))),
                      ],
                    )),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            const Text('ADD / EDIT TYPE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.grey)),
            const SizedBox(height: 8),

            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Size (sqm)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (MYR)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Save',
              onPressed: _addType,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}