import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Color.fromARGB(255, 219, 219, 219),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      child: NavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: selectedIndex,
        onDestinationSelected: onIndexChanged, // Callback untuk update index
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Produk'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histori'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
