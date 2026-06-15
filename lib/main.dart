import 'package:devmobile/carte.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDjLBOSvOVWTOGFr5KBWGJO537PiKxxPFo',
      appId: '1:288865912062:android:c03cbb6f13362b5ded91af',
      messagingSenderId: '288865912062',
      projectId: 'ecosafe-e08ca',
      authDomain: 'ecosafe-e08ca.firebaseapp.com',
      storageBucket: 'ecosafe-e08ca.firebasestorage.app',
    ),
  );
  runApp(const EcoSafe());
}

class EcoSafe extends StatelessWidget {
  const EcoSafe({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 183, 131)),
      ),
      home: const CartePage(),
    );
  }
}
