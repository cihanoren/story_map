import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:story_map/features/home/services.dart/connectivity_service.dart';
import 'package:story_map/features/home/views/card_details.dart';
import 'package:story_map/features/home/views/explore_page.dart';
import 'package:story_map/features/home/views/map_view.dart';
import 'package:story_map/features/home/views/profile/profile_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(connectivityServiceProvider).isOffline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? 100 : 0,
      width: double.infinity,
      color: Colors.grey,
      alignment: Alignment.center,
      child: isOffline
          ? const Text(
              'İnternet bağlantısı yok',
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          : const SizedBox.shrink(),
    );
  }
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
    return Scaffold(
      body: Column(
        children: [
          const ConnectionBanner(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 330;

              return GNav(
                gap: isSmallScreen ? 4 : 12,
                padding: const EdgeInsets.all(12),
                tabMargin: const EdgeInsets.symmetric(horizontal: 6),
                activeColor: Colors.white,
                color: Colors.grey,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                tabBackgroundColor: Colors.deepPurple,
                tabs: const [
                  GButton(icon: Icons.home, text: "Home"),
                  GButton(icon: Icons.public, text: "Explore"),
                  GButton(icon: Icons.location_on, text: "Map"),
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
              );
            },
          ),
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
  final RefreshController _refreshController = RefreshController();

  bool isLoading = true;
  List<String> routeTitles = [];
  List<String> routeIds = [];
  List<List<String>> placeImageUrlsList = [];
  List<List<String>> placeNamesList = [];

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    setState(() => isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final routesQuery = await FirebaseFirestore.instance
            .collection('routes')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        if (routesQuery.docs.isNotEmpty) {
          List<String> allRouteTitles = [];
          List<String> allRouteIds = [];
          List<List<String>> allPlaceImageUrls = [];
          List<List<String>> allPlaceNames = [];

          for (var routeDoc in routesQuery.docs) {
            final routeData = routeDoc.data();
            final List<dynamic> places = routeData['places'];

            allRouteTitles.add(routeData['title'] ?? 'İsimsiz Rota');
            allRouteIds.add(routeDoc.id);

            allPlaceImageUrls.add(places
                .skip(1)
                .take(5)
                .map((e) => (e['image'] ?? '') as String)
                .toList());

            allPlaceNames
                .add(places.map((e) => (e['name'] ?? '') as String).toList());
          }

          setState(() {
            routeTitles = allRouteTitles;
            routeIds = allRouteIds;
            placeImageUrlsList = allPlaceImageUrls;
            placeNamesList = allPlaceNames;
          });
        }
      } catch (e) {
        print('Veri çekme hatası: $e');
      }
    }

    setState(() => isLoading = false);
    _refreshController.refreshCompleted(); // Bunu ekle
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      header: const WaterDropMaterialHeader(
        backgroundColor: Colors.deepPurple,
        color: Colors.white,
      ),
      onRefresh: _loadPageData,
      child: isLoading
          ? const Center()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: routeTitles.length,
              itemBuilder: (context, index) {
                final routeTitle = routeTitles[index];
                final placeImageUrls = placeImageUrlsList[index];
                final placeNames = placeNamesList[index];
                final routeId = routeIds[index];

                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetails(
                        routeId:
                            routeId, // Veya uygun routeId'yi burada kullanın
                        routeTitle: routeTitle,
                        placeNames: placeNames,
                        imagesUrls: placeImageUrls,
                      ),
                    ),
                  ),
                  child: Card(
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
                            children: List.generate(
                              4,
                              (i) {
                                final imageUrl = i < placeImageUrls.length
                                    ? placeImageUrls[i]
                                    : null;

                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      image: imageUrl != null &&
                                              imageUrl.isNotEmpty
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
                              },
                            ),
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
                            placeNames.skip(1).join(' - '),
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
