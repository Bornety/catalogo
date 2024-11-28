import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'catalogo_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: const FirebaseOptions(
      apiKey: "AIzaSyDF-ixl_QjLeDjWFT2mbtA-NinDt74zats",
      authDomain: "projeto-teste-f6fa9.firebaseapp.com",
      projectId: "projeto-teste-f6fa9",
      storageBucket: "projeto-teste-f6fa9.firebasestorage.app",
      messagingSenderId: "883119253666",
      appId: "1:883119253666:web:1670ebbdd018df405e0ffb",
      measurementId: "G-SH6VS5BQ9Y",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
         scaffoldBackgroundColor: const Color(0xFFF3F3E0),
        appBarTheme: const AppBarTheme(color: Color(0xFF608BC1))
    
        
      ),
           home:  CatalogoPage(),
    );
  }
}
