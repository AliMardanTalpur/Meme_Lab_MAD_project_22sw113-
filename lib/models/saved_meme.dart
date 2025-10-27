import 'package:hive/hive.dart';

part 'saved_meme.g.dart';


@HiveType(typeId: 0)
class SavedMeme extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String url;

  @HiveField(3)
  String subreddit;

  @HiveField(4)
  String dataUrl; // base64 or network

  @HiveField(5)
  String createdAt;

  SavedMeme({
    required this.id,
    required this.title,
    required this.url,
    required this.subreddit,
    required this.dataUrl,
    required this.createdAt,
  });
}
