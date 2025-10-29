import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/home_page.dart';
import 'pages/add_expense_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'widget/network_banner.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;
    final pages = [
      const HomePage(),
      const AddExpensePage(),
      const StatsPage(),
      SettingsPage(),
    ];

    return Obx(() {
      return Scaffold(
        body: Column(
          children: [
            const NetworkBanner(),
            Expanded(child: pages[currentIndex.value]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex.value,
          onDestinationSelected: (i) => currentIndex.value = i,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.add_circle), label: 'Add'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
            NavigationDestination(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
    });
  }
}
