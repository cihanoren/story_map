import 'package:flutter/material.dart';
import 'package:story_map/features/home/views/explore_routes_tab.dart';
import 'package:story_map/l10n/app_localizations.dart';
import 'explore_places_tab.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int selectedIndex = 0;

  final List<Widget> tabViews = const [ExplorePlacesTab(), ExploreRoutesTab()];

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = [
      AppLocalizations.of(context)!.exploreTabPlaceTitle, // Mekanlar sekmesi başlığı
      AppLocalizations.of(context)!.exploreTabRouteTitle // Rotalar sekmesi başlığı
    ];
    return Column(
      children: [
        const SizedBox(height: 48), // status bar + boşluk
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabTitles.length, (index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabTitles[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(child: tabViews[selectedIndex]),
      ],
    );
  }
}
