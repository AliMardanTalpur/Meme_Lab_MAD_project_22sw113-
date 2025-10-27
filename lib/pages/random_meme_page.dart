// lib/pages/random_meme_page.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../services/meme_api.dart';
import '../storage/meme_storage.dart';
import '../models/saved_meme.dart';
import '../widgets/gradient_text.dart';

class RandomMemePage extends StatefulWidget {
  const RandomMemePage({super.key});

  @override
  State<RandomMemePage> createState() => _RandomMemePageState();
}

class _RandomMemePageState extends State<RandomMemePage> {
  String? memeUrl;
  String? memeTitle;
  String? memeSubreddit;
  bool isLoading = false;
  bool isImageLoading = false;
  bool isFullScreen = false;

  final List<Map<String, String>> recent = [];

  // --------------------
  // API / storage logic
  // --------------------
  Future<void> fetchMeme({bool addToRecent = true}) async {
    try {
      setState(() {
        isLoading = true;
        isFullScreen = false;
        isImageLoading = true;
      });

      final map = await MemeApi.fetchRandomMeme();
      final url = map['url'] as String?;
      final title = map['title'] as String? ?? '';
      final subreddit = map['subreddit'] as String? ?? '';

      if (url == null) throw Exception('No URL returned from API');

      if (addToRecent) {
        recent.insert(0, {'url': url, 'title': title, 'subreddit': subreddit});
        if (recent.length > 10) recent.removeLast();
      }

      setState(() {
        memeUrl = url;
        memeTitle = title;
        memeSubreddit = subreddit;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching meme: $e')));
    }
  }

  Future<void> saveMeme() async {
    if (memeUrl == null) return;
    try {
      final bytes = await MemeApi.fetchImageBytes(memeUrl!);
      final base64Data = base64Encode(bytes);
      final mime = _guessMimeFromUrl(memeUrl!);
      final dataUrl = 'data:$mime;base64,$base64Data';
      final id = DateTime.now().millisecondsSinceEpoch;
      final saved = SavedMeme(
        id: id,
        title: memeTitle ?? '',
        url: memeUrl!,
        subreddit: memeSubreddit ?? '',
        dataUrl: dataUrl,
        createdAt: DateTime.now().toIso8601String(),
      );
      await MemeStorage.saveMeme(saved);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meme saved!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> downloadMeme() async {
    if (memeUrl == null) return;
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }
    try {
      final bytes = await MemeApi.fetchImageBytes(memeUrl!);
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 90,
        name: 'meme_${DateTime.now().millisecondsSinceEpoch}',
      );
      if ((result is Map &&
              (result['isSuccess'] == true || result['filePath'] != null)) ||
          result == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved to gallery')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  String _guessMimeFromUrl(String url) {
    final u = url.toLowerCase();
    if (u.endsWith('.png')) return 'image/png';
    if (u.endsWith('.webp')) return 'image/webp';
    if (u.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  // --------------------
  // lifecycle
  // --------------------
  @override
  void initState() {
    super.initState();
    fetchMeme();
  }

  // --------------------
  // responsive helpers
  // --------------------
  double _clampedScale(double screenWidth) =>
      (screenWidth / 400).clamp(0.85, 1.6);

  // --------------------
  // build
  // --------------------
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    final scale = _clampedScale(width);
    final gradient = const LinearGradient(
      colors: [Color(0xFF8A56F0), Color(0xFFFF7ACD)],
    );
    const maxContentWidth = 900.0;

    return Scaffold(
      appBar: AppBar(
        title: GradientText(
          'Meme Lab',
          gradient: gradient,
          style: GoogleFonts.poppins(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: max(12, width * 0.05),
              vertical: max(12, height * 0.03),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Meme display (animated, expands to large fraction of screen)
                  GestureDetector(
                    onTap: () {
                      if (memeUrl != null)
                        setState(() => isFullScreen = !isFullScreen);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isFullScreen
                          ? height * 0.72
                          : max(220.0, min(420.0, height * 0.35)),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      child: Stack(
                        children: [
                          if (isLoading)
                            const Center(child: CircularProgressIndicator()),
                          if (!isLoading && memeUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16 * scale),
                              child: Image.network(
                                memeUrl!,
                                fit: isFullScreen
                                    ? BoxFit.contain
                                    : BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (progress == null && isImageLoading) {
                                      setState(() => isImageLoading = false);
                                    }
                                  });
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, e, st) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          if (!isFullScreen && memeTitle != null)
                            Positioned(
                              bottom: 12 * scale,
                              left: 12 * scale,
                              right: 12 * scale,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * scale,
                                  vertical: 10 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(
                                    12 * scale,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memeTitle ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Text(
                                      memeSubreddit ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12 * scale,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // small spacing
                  if (!isFullScreen) SizedBox(height: 14 * scale),

                  // recent thumbnails scroll
                  if (!isFullScreen)
                    SizedBox(
                      height: max(80.0, 92 * scale),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recent.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: 12 * scale),
                        itemBuilder: (context, i) {
                          final item = recent[i];
                          return GestureDetector(
                            onTap: () {
                              // set current from recent
                              setState(() {
                                memeUrl = item['url'];
                                memeTitle = item['title'];
                                memeSubreddit = item['subreddit'];
                              });
                            },
                            onLongPress: () {
                              // same as tap for now
                              setState(() {
                                memeUrl = item['url'];
                                memeTitle = item['title'];
                                memeSubreddit = item['subreddit'];
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12 * scale),
                              child: Image.network(
                                item['url']!,
                                width: max(96.0, 120 * scale),
                                height: max(68.0, 92 * scale),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  if (!isFullScreen) SizedBox(height: 18 * scale),

                  // Buttons area — MATCHED TO HOMEPAGE STYLE (responsive & full-width)
                  if (!isFullScreen)
                    FractionallySizedBox(
                      widthFactor: width < 420 ? 0.95 : 0.78,
                      child: Column(
                        children: [
                          // Generate button (primary purple)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8A56F0),
                                padding: EdgeInsets.symmetric(
                                  vertical: 14 * scale,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    16 * scale,
                                  ),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                                minimumSize: Size(0, 48 * scale),
                              ),
                              onPressed: fetchMeme,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Flexible(
                                    child: Text(
                                      "Generate New Meme",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16 * scale,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 12 * scale),

                          // Download + Save row (Download optional)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12 * scale,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        16 * scale,
                                      ),
                                    ),
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 15 * scale,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    minimumSize: Size(0, 44 * scale),
                                  ),
                                  onPressed: memeUrl == null
                                      ? null
                                      : downloadMeme,
                                  child: Text(
                                    "Download",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 15 * scale,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.orangeAccent,
                                      width: 2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12 * scale,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        16 * scale,
                                      ),
                                    ),
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 15 * scale,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    minimumSize: Size(0, 44 * scale),
                                  ),
                                  onPressed: saveMeme,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.bookmark_add_outlined,
                                        color: Colors.orangeAccent,
                                      ),
                                      SizedBox(width: 8 * scale),
                                      Text(
                                        "Save Meme",
                                        style: GoogleFonts.poppins(
                                          color: Colors.orangeAccent,
                                          fontSize: 15 * scale,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // add bottom padding when fullscreen is toggled off
                  if (!isFullScreen) SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
