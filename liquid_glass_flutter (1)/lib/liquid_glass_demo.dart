// Demo: the iOS 26 App Store glass tab bar (5 tabs) floating over a
// colourful scrolling page. Swap `LiquidGlassStyle.glass` for
// `LiquidGlassStyle.dark` to get the opaque Photos-style bar.
//
// Run with:  flutter run -t lib/liquid_glass_demo.dart
// (after registering both shaders in pubspec.yaml — see README).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'liquid_glass/liquid_glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.precache(); // first frame is already glass
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black),
      home: const StoreLikeScreen(),
    );
  }
}

class StoreLikeScreen extends StatefulWidget {
  const StoreLikeScreen({super.key});

  @override
  State<StoreLikeScreen> createState() => _StoreLikeScreenState();
}

class _StoreLikeScreenState extends State<StoreLikeScreen> {
  int _tab = 2;

  static const _items = [
    LiquidGlassTabItem(icon: CupertinoIcons.today_fill, label: 'Today'),
    LiquidGlassTabItem(icon: CupertinoIcons.rocket_fill, label: 'Games'),
    LiquidGlassTabItem(icon: CupertinoIcons.square_stack_3d_up_fill, label: 'Apps'),
    LiquidGlassTabItem(icon: CupertinoIcons.gamecontroller_fill, label: 'Arcade'),
    LiquidGlassTabItem(icon: CupertinoIcons.search, label: 'Search'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final glass = LiquidGlass.backdropActive;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: _Page(tab: _tab, bottomPadding: 62 + 24 + bottomInset),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(23, 0, 23, bottomInset > 0 ? bottomInset : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!glass)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Glass shader inactive (needs Impeller) — showing fallback',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ),
            LiquidGlassTabBar(
              style: LiquidGlassStyle.glass,
              currentIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
              items: _items,
            ),
          ],
        ),
      ),
    );
  }
}

/// A colourful App Store-like page so the glass has something to bend.
class _Page extends StatelessWidget {
  const _Page({required this.tab, required this.bottomPadding});
  final int tab;
  final double bottomPadding;

  static const _palettes = [
    [Color(0xFF7BD63B), Color(0xFF2E7D1E)],
    [Color(0xFFFF9F1C), Color(0xFFB23A00)],
    [Color(0xFF1E88E5), Color(0xFF0B2F6B)],
    [Color(0xFFE53935), Color(0xFF6A0D0D)],
    [Color(0xFFFFD54F), Color(0xFF8D6E00)],
    [Color(0xFF8E24AA), Color(0xFF2B0A3D)],
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['Today', 'Games', 'Apps', 'Arcade', 'Search'];
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 12),
            child: Text(titles[tab],
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = _palettes[(i + tab) % _palettes.length];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: p,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.isEven ? 'Score!' : 'BUSINESS',
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                        const Spacer(),
                        Text('Game ${i + 1}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              },
              childCount: 24,
            ),
          ),
        ),
      ],
    );
  }
}
