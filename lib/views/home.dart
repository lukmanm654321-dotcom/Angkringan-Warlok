import 'package:flutter/material.dart';
import '../controllers/bottom_navigation.dart';
import '../views/pages/index0.dart';
import '../views/pages/index1.dart';
import '../views/pages/index2.dart';
import '../views/pages/index3.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0; // Default halaman pertama
  final screens = [
    Index0Page(),
    const ProdukPage(),
    const HistoriTransaksiPage(),
    const Index3Page(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: index,
        onIndexChanged: (newIndex) {
          setState(() {
            index = newIndex; // Update tampilan saat tab berubah
          });
        },
      ),
    );
  }
}
