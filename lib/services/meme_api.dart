import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class MemeApi {
  static Future<Map<String, dynamic>> fetchRandomMeme() async {
    final res = await http.get(Uri.parse('https://meme-api.com/gimme'));
    if (res.statusCode != 200) throw Exception('Failed to fetch meme');
    return jsonDecode(res.body) as Map<String,dynamic>;
  }


  /// download bytes from an image URL
  static Future<Uint8List> fetchImageBytes(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('Failed to fetch image bytes');
    return res.bodyBytes;
  }
}
