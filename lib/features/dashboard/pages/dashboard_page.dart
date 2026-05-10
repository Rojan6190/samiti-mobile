import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/provider/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = [
      _ModuleItem(
        icon: Icons.people_alt_rounded,
        label: 'Partners',
        color: AppColors.partners,
        route: '/partners',
      ),
      _ModuleItem(
        icon: Icons.directions_car_rounded,
        label: 'Vehicles',
        color: AppColors.vehicles,
        route: '/vehicles',
      ),
      _ModuleItem(
        icon: Icons.inventory_2_rounded,
        label: 'Products',
        color: AppColors.products,
        route: '/products',
      ),
      _ModuleItem(
        icon: Icons.car_crash_rounded,
        label: 'Accidents',
        color: AppColors.accidents,
        route: '/accidents',
      ),
      _ModuleItem(
        icon: Icons.receipt_long_rounded,
        label: 'Invoices',
        color: AppColors.invoices,
        route: '/invoices',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Samiti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Welcome back 👋', style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              const Text(
                'What would you like to manage today?',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.builder(
                  itemCount: modules.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) =>
                      _ModuleCard(module: modules[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  _ModuleItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ModuleCard extends StatelessWidget {
  final _ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(module.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: module.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: module.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(module.icon, color: module.color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.label, style: AppTextStyles.heading3),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('View all',
                          style: TextStyle(
                            fontSize: 12,
                            color: module.color,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 12, color: module.color),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}