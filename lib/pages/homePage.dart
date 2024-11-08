import 'package:flutter/material.dart';
import 'package:heimdal/pages/gemini.dart';
import 'package:heimdal/pages/maps_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.index});

  final int? index;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinations = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
  ];

  final _screens = const [
    MapPage(),
    GeminiClass(),
  ];

  late int _currentScreenIndex;

  @override
  void initState() {
    super.initState();
    // Inisialisasi _currentScreenIndex dengan widget.index, atau 0 jika widget.index null
    _currentScreenIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentScreenIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 8,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        destinations: _destinations,
        selectedIndex: _currentScreenIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentScreenIndex = index;
          });
        },
      ),
    );
  }
}
