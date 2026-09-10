import 'package:flutter/material.dart';
import '../screens/add_camera_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/storage_screen.dart';
import '../screens/users_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _labels = <String>[
    'Caméras',
    'Ajouter',
    'Alertes',
    'Stockage',
    'Utilisateurs',
    'Réglages',
  ];

  static const _icons = <IconData>[
    Icons.videocam_outlined,
    Icons.add_circle_outline,
    Icons.notifications_outlined,
    Icons.storage_outlined,
    Icons.people_outline,
    Icons.settings_outlined,
  ];

  Widget _page() {
    switch (_index) {
      case 1:
        return const AddCameraScreen();
      case 2:
        return const AlertsScreen();
      case 3:
        return const StorageScreen();
      case 4:
        return const UsersScreen();
      case 5:
        return const SettingsScreen();
      case 0:
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  destinations: List.generate(
                    _labels.length,
                    (i) => NavigationRailDestination(
                      icon: Icon(_icons[i]),
                      selectedIcon: Icon(_icons[i]),
                      label: Text(_labels[i]),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _page()),
              ],
            ),
          );
        }

        return Scaffold(
          body: _page(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: List.generate(
              _labels.length,
              (i) => NavigationDestination(
                icon: Icon(_icons[i]),
                selectedIcon: Icon(_icons[i]),
                label: _labels[i],
              ),
            ),
          ),
        );
      },
    );
  }
}
