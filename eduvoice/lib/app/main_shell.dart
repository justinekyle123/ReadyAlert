import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_palette.dart';
import '../features/alerts/presentation/screens/alerts_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/groups/presentation/screens/groups_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'add_menu.dart';

/// Height of the docked `+` button.
const double _addButtonSize = 56;

/// How far the `+` button sinks into the bottom bar.
const double _addButtonDock = _addButtonSize / 2;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _addMenuOpen = false;

  late final List<Widget> _pages = [
    const DashboardScreen(),
    AlertsScreen(onBack: () => _selectTab(0)),
    GroupsScreen(onBack: () => _selectTab(0)),
    ProfileScreen(onBack: () => _selectTab(0)),
  ];

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _addMenuOpen = false;
    });
  }

  void _toggleAddMenu() => setState(() => _addMenuOpen = !_addMenuOpen);

  void _closeAddMenu() {
    if (!_addMenuOpen) {
      return;
    }
    setState(() => _addMenuOpen = false);
  }

  void _showAddMessage(String action) {
    _closeAddMenu();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$action will be available soon.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarHeight = Theme.of(context).navigationBarTheme.height ?? 68;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: palette.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                _AnimatedTabStack(
                  selectedIndex: _selectedIndex,
                  children: _pages,
                ),
                IgnorePointer(
                  ignoring: !_addMenuOpen,
                  child: AnimatedOpacity(
                    opacity: _addMenuOpen ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeAddMenu,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectTab,
                destinations: const [
                  NavigationDestination(
                    key: Key('nav-home'),
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    key: Key('nav-alerts'),
                    icon: Icon(Icons.campaign_outlined),
                    selectedIcon: Icon(Icons.campaign_rounded),
                    label: 'Alerts',
                  ),
                  NavigationDestination(
                    key: Key('nav-groups'),
                    icon: Icon(Icons.groups_2_outlined),
                    selectedIcon: Icon(Icons.groups_2_rounded),
                    label: 'Groups',
                  ),
                  NavigationDestination(
                    key: Key('nav-profile'),
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
          // Docked on the bottom bar: sits half over it so it reads as part
          // of the bar instead of floating above the page content.
          Positioned(
            left: 0,
            right: 0,
            bottom: navBarHeight + bottomInset - _addButtonDock,
            child: Center(
              child: AddMenu(
                open: _addMenuOpen,
                onToggle: _toggleAddMenu,
                onAddUser: () => _showAddMessage('Adding users'),
                onAddGroup: () => _showAddMessage('Creating groups'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTabStack extends StatelessWidget {
  const _AnimatedTabStack({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < children.length; index++)
          ExcludeFocus(
            excluding: index != selectedIndex,
            child: IgnorePointer(
              ignoring: index != selectedIndex,
              child: ExcludeSemantics(
                excluding: index != selectedIndex,
                child: AnimatedOpacity(
                  opacity: index == selectedIndex ? 1 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSlide(
                    offset: index == selectedIndex
                        ? Offset.zero
                        : const Offset(0.015, 0),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    child: children[index],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
