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
          icon: Icon(Icons.search),
          title: Text('Explore'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text('Profile'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text('My Hives'),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.yellow,
      onTap: _onItemTapped,
    );
  }
}
