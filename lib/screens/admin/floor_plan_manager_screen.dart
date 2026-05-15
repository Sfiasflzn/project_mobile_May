import 'package:flutter/material.dart';
import '../../models/booth_model.dart';
import '../../services/booth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class FloorPlanManagerScreen extends StatefulWidget {
  const FloorPlanManagerScreen({super.key});

  @override
  State<FloorPlanManagerScreen> createState() =>
      _FloorPlanManagerScreenState();
}

class _FloorPlanManagerScreenState extends State<FloorPlanManagerScreen> {
  final _boothService = BoothService();
  final _boothIdCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _rowCtrl = TextEditingController();
  final _colCtrl = TextEditingController();
  String _selectedEventId = '';
  bool _isLoading = false;

  final List<String> _amenities = [];
  final _amenityCtrl = TextEditingController();

  Future<void> _saveBooth() async {
    if (_boothIdCtrl.text.isEmpty ||
        _typeCtrl.text.isEmpty ||
        _selectedEventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the required information')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final booth = BoothModel(
        id: '',
        eventId: _selectedEventId,
        boothId: _boothIdCtrl.text.trim().toUpperCase(),
        type: _typeCtrl.text.trim().toLowerCase(),
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
          const SnackBar(content: Text('Booth added successfully')),
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
    _typeCtrl.clear();
    _sizeCtrl.clear();
    _priceCtrl.clear();
    _rowCtrl.clear();
    _colCtrl.clear();
    _amenities.clear();
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
        title: const Text('Floor Plans'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Floor Plan Management',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // Event ID input
            TextFormField(
              onChanged: (v) => setState(() => _selectedEventId = v),
              decoration: InputDecoration(
                labelText: 'Event ID',
                hintText: 'Enter the event ID from Firestore',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Floor plan preview box
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.lightGrey,
              ),
              child: _selectedEventId.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file,
                        size: 40, color: AppColors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Please enter the event ID to view the floor plan',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              )
                  : StreamBuilder<List<BoothModel>>(
                stream: _boothService
                    .getBoothsForEvent(_selectedEventId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No booth available for this event',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    );
                  }

                  final booths = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: _buildBoothGrid(booths),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'MAP BOOTHS ON PLAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            // Booth ID
            _buildField('Booth ID (Example: A1, B3)', _boothIdCtrl),

            // Type
            _buildField('Type (standard/premium/corner)', _typeCtrl),

            // Size & Price row
            Row(
              children: [
                Expanded(
                  child: _buildField('Size (sqm)', _sizeCtrl,
                      type: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('Price (MYR)', _priceCtrl,
                      type: TextInputType.number),
                ),
              ],
            ),

            // Row & Col
            Row(
              children: [
                Expanded(
                  child: _buildField('Row (0,1,2...)', _rowCtrl,
                      type: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('Col (0,1,2...)', _colCtrl,
                      type: TextInputType.number),
                ),
              ],
            ),

            // Amenities
            const Text(
              'Amenities',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amenityCtrl,
                    decoration: InputDecoration(
                      hintText: 'Example: Power, Wi-Fi',
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

            // Amenity chips
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

            const SizedBox(height: 24),

            // Save button
            CustomButton(
              text: 'Save Booth',
              onPressed: _saveBooth,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 16),

            // List existing booths
            if (_selectedEventId.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'BOOTH LIST',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<BoothModel>>(
                stream:
                _boothService.getBoothsForEvent(_selectedEventId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No booth available');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, i) {
                      final booth = snapshot.data![i];
                      return ListTile(
                        title: Text('Booth ${booth.boothId}'),
                        subtitle: Text(
                            '${booth.type} · ${booth.size}sqm · RM${booth.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: booth.status == 'available'
                                    ? AppColors.green.withOpacity(0.1)
                                    : AppColors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                booth.status,
                                style: TextStyle(
                                  color: booth.status == 'available'
                                      ? AppColors.green
                                      : AppColors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.red, size: 20),
                              onPressed: () =>
                                  _confirmDelete(booth),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBoothGrid(List<BoothModel> booths) {
    if (booths.isEmpty) return [];

    final maxRow =
    booths.map((b) => b.row).reduce((a, b) => a > b ? a : b);
    final maxCol =
    booths.map((b) => b.col).reduce((a, b) => a > b ? a : b);

    return List.generate(maxRow + 1, (row) {
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
            return const SizedBox(width: 36, height: 36);
          }

          return Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: booth.status == 'booked'
                  ? AppColors.grey.withOpacity(0.5)
                  : Colors.white,
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                booth.boothId,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      );
    });
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

  Future<void> _confirmDelete(BoothModel booth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Booth?'),
        content: Text('Delete booth ${booth.boothId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _boothService.deleteBooth(booth.id);
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
    _typeCtrl.dispose();
    _sizeCtrl.dispose();
    _priceCtrl.dispose();
    _rowCtrl.dispose();
    _colCtrl.dispose();
    _amenityCtrl.dispose();
    super.dispose();
  }
}
