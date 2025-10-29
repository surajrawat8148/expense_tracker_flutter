import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/home_page.dart';
import 'pages/add_expense_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'widget/network_banner.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const AddExpensePage(),
      const StatsPage(),
      SettingsPage(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: pages[_index == 1 ? 0 : _index]),
          const Positioned(top: 0, left: 0, right: 0, child: NetworkBanner()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 1) {
            Get.to(() => const AddExpensePage())?.then((_) => setState(() {}));
          } else {
            setState(() => _index = i);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
