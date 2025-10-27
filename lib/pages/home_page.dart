import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_text.dart';
import 'random_meme_page.dart';
import 'saved_memes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  double _clampedScale(double screenWidth) {
    // base reference width 400. clamp so it doesn't get tiny or ginormous
    return (screenWidth / 400).clamp(0.8, 1.6);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;
    final scale = _clampedScale(width);
    final gradient = const LinearGradient(colors: [Color(0xFF8A56F0), Color(0xFFFF7ACD)]);

    // Limit the content width for very wide screens (desktop/tablet)
    const double maxContentWidth = 720;

    return Scaffold(
      // allow the scaffold to adjust when keyboard is open
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: max(16, width * 0.06),
              vertical: max(12, height * 0.04),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min, // keeps content centered vertically in scroll
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  GradientText(
                    'Meme Lab',
                    style: GoogleFonts.poppins(
                      fontSize: 32 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                    gradient: gradient,
                  ),
                  SizedBox(height: 8 * scale),

                  // Subtitle
                  Text(
                    'Find hilarious memes in seconds',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 28 * scale),

                  // Buttons column with constrained widths so they don't explode
                  FractionallySizedBox(
                    widthFactor: width < 380 ? 0.92 : 0.75, // narrower on phones, tighter on wide screens
                    child: Column(
                      children: [
                        // Generate button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A56F0),
                              padding: EdgeInsets.symmetric(vertical: 14 * scale),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                              textStyle: GoogleFonts.poppins(fontSize: 16 * scale),
                              minimumSize: Size(0, 44 * scale),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RandomMemePage()),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, size: 20, color: Colors.yellow,),
                                SizedBox(width: 8 * scale),
                                Flexible(
                                  child: Text(
                                    "Find New Meme",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 14 * scale),

                        // Saved memes button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orangeAccent, width: 2),
                              padding: EdgeInsets.symmetric(vertical: 14 * scale),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                              textStyle: GoogleFonts.poppins(fontSize: 15 * scale),
                              minimumSize: Size(0, 44 * scale),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SavedMemesPage()),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.grid_view_rounded, color: Colors.orangeAccent, size: 20),
                                SizedBox(width: 8 * scale),
                                Flexible(
                                  child: Text(
                                    "View Saved Memes",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(color: Colors.orangeAccent, fontSize: 15 * scale),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30 * scale),

                  // Footer text
                  Text(
                    "Find unlimited memes, save your favorites",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13 * scale, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 12 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
