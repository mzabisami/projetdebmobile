import 'package:devmobile/fonctionnalites/carte/carte_page.dart';
import 'package:devmobile/transport_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EcoSafe());
}

class EcoSafe extends StatefulWidget {
  const EcoSafe({super.key});

  @override
  State<EcoSafe> createState() => _EcoSafeState();
}

class _EcoSafeState extends State<EcoSafe> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    CartePage(),
    TransportScreen(),
    _PlaceholderPage(title: 'Sécurité'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 183, 131),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Carte'),
            NavigationDestination(icon: Icon(Icons.directions_bus), label: 'Transport'),
            NavigationDestination(icon: Icon(Icons.shield_outlined), label: 'Sécurité'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
