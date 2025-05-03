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
  List<String> routeTitles = [];
  List<List<String>> placeImageUrlsList = [];
  List<List<String>> placeNamesList = [];

  @override
  void initState() {
    super.initState();
    _loadPageData(); // İlk veri yükleme
    setState(() {}); // State'i güncellemek için çağırıyoruz
  }

  Future<void> _loadPageData() async {
    setState(() => isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final routesQuery = await FirebaseFirestore.instance
            .collection('routes')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt',
                descending: true) // Tüm rotaları tarih sırasına göre alıyoruz
            .get();

        if (routesQuery.docs.isNotEmpty) {
          List<String> allRouteTitles = [];
          List<List<String>> allPlaceImageUrls = [];
          List<List<String>> allPlaceNames = [];

          // Tüm rotalar için verileri alıyoruz
          for (var routeDoc in routesQuery.docs) {
            final routeData = routeDoc.data();
            final List<dynamic> places = routeData['places'];

            allRouteTitles.add(routeData['title'] ?? 'İsimsiz Rota');

            // Her rota için 1. ila 5. yerin görsellerini alıyoruz
            allPlaceImageUrls.add(places
                .skip(1)
                .take(5)
                .map((e) => (e['image'] ?? '') as String)
                .toList());

            // Yer adlarını alıyoruz
            allPlaceNames
                .add(places.map((e) => (e['name'] ?? '') as String).toList());
          }

          setState(() {
            routeTitles = allRouteTitles;
            placeImageUrlsList = allPlaceImageUrls;
            placeNamesList = allPlaceNames;
          });
        }
      } catch (e) {
        // Hata oluşursa hata mesajı gösterebiliriz
        print('Veri çekme hatası: $e');
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPageData,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: routeTitles.length,
              itemBuilder: (context, index) {
                final routeTitle = routeTitles[index];
                final placeImageUrls = placeImageUrlsList[index];
                final placeNames = placeNamesList[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(4, (i) {
                            final imageUrl = i < placeImageUrls.length
                                ? placeImageUrls[i]
                                : null;

                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  image: imageUrl != null && imageUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: imageUrl == null || imageUrl.isEmpty
                                    ? const Center(child: Text("Boş"))
                                    : null,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            routeTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          placeNames.join(' - '),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
