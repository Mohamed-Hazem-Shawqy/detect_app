import 'package:detector_app/screens/detect.dart';
import 'package:detector_app/screens/picker.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> _pages = [const Detect(), const Picker()];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera), label: 'camera play'),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload), label: 'upload from this devicec'),
        ],
      ),
      body:IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
    );
  }
}
