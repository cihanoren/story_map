import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          if (_selectedIndex == 0)
            Positioned(
              top: 45,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Kullanıcı fotoğrafı
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Hata: ${snapshot.error}');
                          }

                          if (snapshot.hasData && snapshot.data != null) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            final displayName =
                                data?['displayName'] ?? 'Kullanıcı';
                            final profileImageUrl = data?['profileImageUrl'];

                            return Row(
                              children: [
                                // Eğer profil fotoğrafı varsa, göster
                                if (profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty)
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage:
                                        NetworkImage(profileImageUrl),
                                  )
                                else
                                  const SizedBox(
                                      width: 36), // Fotoğraf yoksa boşluk bırak
                                const SizedBox(width: 8),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ],
                            );
                          }

                          return const Text('Kullanıcı Bulunamadı');
                        },
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    setState(() {
      isLoading = true;
    });

    // Örn. Firebase’den tur bilgisi vs çekilebilir burada
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return RefreshIndicator(
    onRefresh: () async {
      await _loadPageData(); // Sayfayı yenile
      setState(() {
        isLoading = false; // Yenileme tamamlandığında yükleme durumunu kapat
      });
    },
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
              isLoading
                  ? const CircularProgressIndicator() // Yükleniyor durumunda göster
                  : Column(
                      children: [
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
                        const Text(
                          "Tur Bilgileri Buraya Gelecek",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}
}