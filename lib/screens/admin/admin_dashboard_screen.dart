import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {'icon': Icons.map, 'title': 'Floor Plan Manager', 'route': '/admin/floor-plan'},
      {'icon': Icons.event, 'title': 'All Exhibitions', 'route': '/admin/exhibitions'},
      {'icon': Icons.store, 'title': 'Booth Types & Pricing', 'route': '/admin/booth-types'},
      {'icon': Icons.people, 'title': 'User Management', 'route': '/admin/users'},
      {'icon': Icons.book_online, 'title': 'All Reservations', 'route': '/admin/reservations'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menus.length,
        itemBuilder: (ctx, i) {
          final menu = menus[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(menu['icon'] as IconData, color: AppColors.blue),
              title: Text(menu['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(menu['route'] as String),
            ),
          );
        },
      ),
    );
  }
}
