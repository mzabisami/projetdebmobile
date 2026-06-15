import 'package:devmobile/carte.dart';
import 'package:devmobile/config/theme.dart';
import 'package:devmobile/screens/profile_screen.dart';
import 'package:devmobile/screens/safety_screen.dart';
import 'package:devmobile/screens/shop_screen.dart';
import 'package:flutter/material.dart';

class TabNav extends StatefulWidget {
  const TabNav({super.key, this.initialIndex = 4});

  final int initialIndex;

  @override
  State<TabNav> createState() => _TabNavState();
}

class _TabNavState extends State<TabNav> {
  static const _demoUserId = 'demo-user';

  late int _selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bus_outlined),
            selectedIcon: Icon(Icons.directions_bus),
            label: 'Transport',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Sécurité',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Boutique',
          ),
        ],
      ),
    );
  }

  Widget _currentPage() {
    switch (_selectedIndex) {
      case 0:
        return const CartePage();
      case 1:
        return const _PlaceholderScreen(
          title: 'Transport',
          icon: Icons.directions_bus,
          message: 'Écran transport à intégrer avec le travail Dev 2.',
        );
      case 2:
        return const SafetyScreen(userId: _demoUserId);
      case 3:
        return const ProfileScreen(userId: _demoUserId);
      case 4:
      default:
        return const ShopScreen();
    }
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.secondary, size: 36),
              ),
              const SizedBox(height: 18),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
