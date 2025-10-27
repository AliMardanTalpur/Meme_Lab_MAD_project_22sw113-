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

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Delete all?'), content: const Text('Are you sure you want to delete all saved memes?'), actions: [
        TextButton(onPressed: null, child: Text('Cancel')),
      ]),
    );
    // simplified confirmation: we'll call deleteAll right away
    await MemeStorage.deleteAll();
    await load();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Memes", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: const BackButton(),
        actions: [
          if (memes.isNotEmpty)
            TextButton(onPressed: () async { await MemeStorage.deleteAll(); await load(); }, child: Text('Delete All', style: GoogleFonts.poppins(color: Colors.redAccent))),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : memes.isEmpty
          ? Center(child: Text('No saved memes yet', style: GoogleFonts.poppins()))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
        itemCount: memes.length,
        itemBuilder: (context, index) {
          final m = memes[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MemeViewerPage(savedMeme: m))).then((_) => load()),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(base64Decode(m.dataUrl.split(',').last), width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(m.title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                    child: Text(m.subreddit, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
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
