import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../storage/meme_storage.dart';
import '../models/saved_meme.dart';
import 'meme_viewer_page.dart';

class SavedMemesPage extends StatefulWidget {
  const SavedMemesPage({super.key});

  @override
  State<SavedMemesPage> createState() => _SavedMemesPageState();
}

class _SavedMemesPageState extends State<SavedMemesPage> {
  List<SavedMeme> memes = [];
  bool isLoading = true;

  Future<void> load() async {
    setState(() => isLoading = true);
    memes = await MemeStorage.loadMemes();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  // Calculate responsive grid layout
  SliverGridDelegate _getGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine device type
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isLargeDesktop = screenWidth >= 1800;

    if (isMobile) {
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      );
    } else if (isTablet) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      );
    } else if (isLargeDesktop) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      );
    } else {
      // Regular desktop
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 0.8,
      );
    }
  }

  // Alternative: Dynamic grid that adapts to available space
  SliverGridDelegate _getDynamicGridDelegate(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate optimal number of columns based on screen width
    final itemWidth = 200.0; // Minimum width for each item
    final crossAxisCount = (screenWidth / itemWidth).floor().clamp(2, 6);

    // Adjust aspect ratio based on column count
    final childAspectRatio = crossAxisCount <= 2 ? 0.75 : 0.8;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Memes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isLargeScreen ? 24 : 20,
          ),
        ),
        leading: const BackButton(),
        actions: [
          if (memes.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(
                      'Delete All Memes?',
                      style: GoogleFonts.poppins(),
                    ),
                    content: Text(
                      'This will permanently remove all your saved memes.',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel', style: GoogleFonts.poppins()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Delete All',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await MemeStorage.deleteAll();
                  await load();
                }
              },
              child: Text(
                'Delete All',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: isLargeScreen ? 16 : 14,
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : memes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved memes yet',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 18 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save memes to see them here',
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
              child: GridView.builder(
                gridDelegate: _getGridDelegate(context),
                // Alternatively use dynamic version:
                // gridDelegate: _getDynamicGridDelegate(context),
                itemCount: memes.length,
                itemBuilder: (context, index) {
                  final m = memes[index];
                  return _buildMemeCard(context, m);
                },
              ),
            ),
    );
  }

  Widget _buildMemeCard(BuildContext context, SavedMeme m) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MemeViewerPage(savedMeme: m)),
      ).then((_) => load()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.memory(
                  base64Decode(m.dataUrl.split(',').last),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.subreddit,
                    style: GoogleFonts.poppins(
                      fontSize: isLargeScreen ? 12 : 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
