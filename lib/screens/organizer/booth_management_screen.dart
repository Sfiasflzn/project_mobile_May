import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/booth_model.dart';
import '../../services/booth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class BoothManagementScreen extends StatefulWidget {
  final String eventId;

  const BoothManagementScreen({super.key, required this.eventId});

  @override
  State<BoothManagementScreen> createState() =>
      _BoothManagementScreenState();
}

class _BoothManagementScreenState extends State<BoothManagementScreen> {
  final _boothService = BoothService();
  final _boothIdCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _rowCtrl = TextEditingController();
  final _colCtrl = TextEditingController();
  String _selectedType = 'standard';
  bool _isLoading = false;
  final List<String> _amenities = [];
  final _amenityCtrl = TextEditingController();

  final List<String> _boothTypes = ['standard', 'premium', 'corner'];

  Future<void> _addBooth() async {
    if (_boothIdCtrl.text.isEmpty ||
        _sizeCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the required information')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final booth = BoothModel(
        id: '',
        eventId: widget.eventId,
        boothId: _boothIdCtrl.text.trim().toUpperCase(),
        type: _selectedType,
        size: double.tryParse(_sizeCtrl.text) ?? 9,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        amenities: _amenities,
        status: 'available',
        row: int.tryParse(_rowCtrl.text) ?? 0,
        col: int.tryParse(_colCtrl.text) ?? 0,
      );

      await _boothService.createBooth(booth);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth successfully added')),
        );
        _clearFields();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _boothIdCtrl.clear();
    _sizeCtrl.clear();
    _priceCtrl.clear();
    _rowCtrl.clear();
    _colCtrl.clear();
    setState(() => _amenities.clear());
  }

  void _addAmenity() {
    if (_amenityCtrl.text.isNotEmpty) {
      setState(() {
        _amenities.add(_amenityCtrl.text.trim());
        _amenityCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            StreamBuilder<List<BoothModel>>(
              stream: _boothService.getBoothsForEvent(widget.eventId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No booth available. Add a booth below',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  );
                }

                final booths = snapshot.data!;

                // Group by type
                final Map<String, List<BoothModel>> grouped = {};
                for (final booth in booths) {
                  grouped.putIfAbsent(booth.type, () => []).add(booth);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...grouped.entries.map((entry) {
                      final type = entry.key;
                      final typeBooths = entry.value;
                      final available = typeBooths
                          .where((b) => b.status == 'available')
                          .length;
                      final total = typeBooths.length;
                      final price = typeBooths.first.price;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    type.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'RM ${price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${typeBooths.first.size} sqm — Available $available/$total',
                                style: const TextStyle(
                                    color: AppColors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 8),

                              // Progress bar
                              LinearProgressIndicator(
                                value: total > 0 ? available / total : 0,
                                backgroundColor:
                                AppColors.grey.withOpacity(0.2),
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.green),
                              ),
                              const SizedBox(height: 12),

                              // Booth list within type
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: typeBooths.map((booth) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: booth.status == 'available'
                                          ? AppColors.green.withOpacity(0.1)
                                          : AppColors.grey.withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      border: Border.all(
                                        color: booth.status == 'available'
                                            ? AppColors.green
                                            : AppColors.grey,
                                      ),
                                    ),
                                    child: Text(
                                      booth.boothId,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: booth.status == 'available'
                                            ? AppColors.green
                                            : AppColors.grey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _confirmDeleteType(
                                          context, typeBooths);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppColors.red),
                                    ),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: AppColors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const Divider(),
            const SizedBox(height: 8),

            // Add booth type section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.blue.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '+ Add Booth Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Booth ID
                  _buildField('Booth ID (Example: A1)', _boothIdCtrl),

                  // Type dropdown
                  const Text('Type',
                      style:
                      TextStyle(fontSize: 13, color: AppColors.grey)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _boothTypes
                        .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toUpperCase()),
                    ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 14),

                  // Size & Price
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                            'Size (sqm)', _sizeCtrl,
                            type: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                            'Price (MYR)', _priceCtrl,
                            type: TextInputType.number),
                      ),
                    ],
                  ),

                  // Row & Col
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('Row', _rowCtrl,
                            type: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField('Col', _colCtrl,
                            type: TextInputType.number),
                      ),
                    ],
                  ),

                  // Amenities
                  const Text('Amenities',
                      style:
                      TextStyle(fontSize: 13, color: AppColors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amenityCtrl,
                          decoration: InputDecoration(
                            hintText: 'example: Power, Wi-Fi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addAmenity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                        ),
                        child: const Text('+',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_amenities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _amenities
                          .map((a) => Chip(
                        label: Text(a),
                        onDeleted: () =>
                            setState(() => _amenities.remove(a)),
                      ))
                          .toList(),
                    ),

                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Save Booth',
                    onPressed: _addBooth,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteType(
      BuildContext context, List<BoothModel> booths) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Booth Type?'),
        content: Text('Delete all ${booths.length} this booth type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final booth in booths) {
        await _boothService.deleteBooth(booth.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth successfully deleted')),
        );
      }
    }
  }

  @override
  void dispose() {
    _boothIdCtrl.dispose();
    _sizeCtrl.dispose();
    _priceCtrl.dispose();
    _rowCtrl.dispose();
    _colCtrl.dispose();
    _amenityCtrl.dispose();
    super.dispose();
  }
}
