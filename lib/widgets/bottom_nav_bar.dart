import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Column(children: [Icon(Icons.home), Text("Accueil")]),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Column(children: [Icon(Icons.delivery_dining), Text("Livreurs")]),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Column(children: [Icon(Icons.shopping_bag), Text("Commandes")]),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Column(children: [Icon(Icons.person), Text("Comptes")]),
          label: '',
        ),
      ],
    );
  }
}
