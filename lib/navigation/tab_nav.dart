import 'package:devmobile/screens/carte_screen.dart';
import 'package:devmobile/screens/profile_screen.dart';
import 'package:devmobile/screens/safety_screen.dart';
import 'package:devmobile/screens/shop_screen.dart';
import 'package:devmobile/screens/transport_screen.dart';
import 'package:flutter/material.dart';

class TabNav extends StatefulWidget {
  const TabNav({super.key, this.initialIndex = 0});

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
        return const TransportScreen();
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
