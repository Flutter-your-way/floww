// Demo: the iOS 26 Photos bottom bar — "Library | Collections" glass tab bar
// plus the round search button — over a scrolling photo grid.
//
// Run with:  flutter run -t lib/liquid_glass_demo.dart
// (after registering the shader in pubspec.yaml — see README).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'liquid_glass/liquid_glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.precache(); // first press is already glass
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black),
      home: const PhotosLikeScreen(),
    );
  }
}

class PhotosLikeScreen extends StatefulWidget {
  const PhotosLikeScreen({super.key});

  @override
  State<PhotosLikeScreen> createState() => _PhotosLikeScreenState();
}

class _PhotosLikeScreenState extends State<PhotosLikeScreen> {
  int _tab = 0;
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    final style = _dark ? LiquidGlassStyle.dark : LiquidGlassStyle.light;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _dark ? Colors.black : Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _tab,
        children: [
          _Grid(dark: _dark, bottomPadding: 62 + 24 + bottomInset),
          _Collections(dark: _dark, bottomPadding: 62 + 24 + bottomInset),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset : 16),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: LiquidGlassTabBar(
                style: style,
                currentIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                items: const [
                  LiquidGlassTabItem(
                    icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                    label: 'Library',
                  ),
                  LiquidGlassTabItem(
                    icon: CupertinoIcons.rectangle_stack_fill,
                    label: 'Collections',
                  ),
                ],
              ),
            ),
            const Spacer(),
            LiquidGlassButton(
              style: style,
              icon: CupertinoIcons.search,
              semanticLabel: 'Search',
              onPressed: () => setState(() => _dark = !_dark), // demo: toggles theme
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.dark, required this.bottomPadding});
  final bool dark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 90,
      itemBuilder: (context, i) {
        final h = (i * 37) % 360;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(1, h.toDouble(), 0.55, dark ? 0.35 : 0.65).toColor(),
                HSLColor.fromAHSL(1, (h + 40) % 360.0, 0.6, dark ? 0.2 : 0.8).toColor(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Collections extends StatelessWidget {
  const _Collections({required this.dark, required this.bottomPadding});
  final bool dark;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 80, 20, bottomPadding),
      children: [
        Text('Collections',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: fg)),
        const SizedBox(height: 16),
        for (final t in ['Recent Days', 'People & Pets', 'Memories', 'Trips', 'Albums'])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: dark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: Text(t,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fg)),
            ),
          ),
      ],
    );
  }
}
