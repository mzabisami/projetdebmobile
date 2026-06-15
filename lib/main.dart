import 'package:devmobile/transport_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EcoSafe());
}

class EcoSafe extends StatelessWidget {
  const EcoSafe({super.key});

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
      home: const TransportScreen(),
    );
  }
}
