import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final Function animateToPage;
  BottomBar(this.animateToPage);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        widget.animateToPage(0);

        break;
      case 1:
        widget.animateToPage(1);
        break;
      case 2:
        widget.animateToPage(2);
        break;
      case 3:
        widget.animateToPage(3);
        break;
      case 4:
        widget.animateToPage(4);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Map'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          title: Text('Scanner'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          title: Text('Bonus'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          title: Text('Ranking'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          title: Text('Shop'),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green[800],
      onTap: _onItemTapped,
    );
  }
}
