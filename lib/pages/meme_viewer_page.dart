import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../storage/meme_storage.dart';
import '../models/saved_meme.dart';

class MemeViewerPage extends StatefulWidget {
  final SavedMeme savedMeme;
  const MemeViewerPage({super.key, required this.savedMeme});

  @override
  State<MemeViewerPage> createState() => _MemeViewerPageState();
}

class _MemeViewerPageState extends State<MemeViewerPage> {
  bool isDownloading = false;

  Future<void> _downloadBase64() async {
    setState(() => isDownloading = true);
    try {
      final parts = widget.savedMeme.dataUrl.split(',');
      final bytes = base64Decode(parts[1]);
      final result = await ImageGallerySaver.saveImage(bytes, name: 'meme_${widget.savedMeme.id}');
      if (result['isSuccess'] == true || result['filePath'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to gallery')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isDownloading = false);
    }
  }

  Future<void> _delete() async {
    await MemeStorage.deleteMeme(widget.savedMeme.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.savedMeme;
    return Scaffold(
      appBar: AppBar(title: Text('View Meme', style: GoogleFonts.poppins())),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(base64Decode(m.dataUrl.split(',').last), fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(m.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(m.subreddit, style: GoogleFonts.poppins(color: Colors.grey[600])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(onPressed: isDownloading ? null : _downloadBase64, child: Text(isDownloading ? 'Saving...' : 'Download', style: GoogleFonts.poppins())),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(onPressed: _delete, child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
