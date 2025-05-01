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

          ..._selectedIndex == 0
    ? [
        Positioned(
          top: 45,
          left: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 👤 Kullanıcı Profili
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        AssetImage("assets/images/avatar.jpg"),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Ahmet Yılmaz",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
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
            ],
          ),
        ),
      ]
    : [],

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst kısım: 4 eş parça görsel alanı
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text("Resim ${index + 1}"),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Devamı gelecek alanlar
                const Text(
                  "Tur Bilgileri Buraya Gelecek",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
