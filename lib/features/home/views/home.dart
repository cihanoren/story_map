import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_map/core/theme/theme_provider.dart';
import 'package:story_map/features/home/views/explore_page.dart';
import 'package:story_map/features/home/views/map_view.dart';
import 'package:story_map/features/home/views/profile/profile_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const MapView(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // 🔄 Sağ üst köşede animasyonlu tema butonu (sadece Home sayfasında)
          if (_selectedIndex == 0)
            Positioned(
              top: 30,
              right: 10,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: IconButton(
                  key: ValueKey<bool>(isDark),
                  icon: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 28,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          gap: 12,
          activeColor: Colors.white,
          color: Colors.grey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          tabBackgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.all(14),
          tabMargin: const EdgeInsets.symmetric(horizontal: 10),
          tabs: const [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.public, text: "Explore"),
            GButton(icon: Icons.location_on, text: "Maps"),
            GButton(icon: Icons.person, text: "Profile"),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              if (index < _pages.length) {
                _selectedIndex = index;
              }
            });
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Welcome to Home Page",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
