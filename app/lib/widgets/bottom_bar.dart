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
          title: Text(
            'Map',
            style: TextStyle(fontSize: 14),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text(
            'Explore',
            style: TextStyle(fontSize: 14),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          title: Text(
            'My Hives',
            style: TextStyle(fontSize: 14),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text(
            'Profile',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.yellow,
      onTap: _onItemTapped,
    );
  }
}
