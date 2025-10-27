import 'package:hive/hive.dart';
import '../models/saved_meme.dart';

class MemeStorage {
  static const String _boxName = 'saved_memes';

  static Future<Box<SavedMeme>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<SavedMeme>(_boxName);
    }
    return Hive.box<SavedMeme>(_boxName);
  }

  static Future<void> saveMeme(SavedMeme meme) async {
    final box = await _getBox();
    final exists = box.values.any((m) => m.url == meme.url);
    if (!exists) await box.add(meme);
  }

  static Future<List<SavedMeme>> loadMemes() async {
    final box = await _getBox();
    return box.values.toList();
  }

  static Future<void> deleteMeme(int id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  static Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
