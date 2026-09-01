import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_model.dart';

class SavedNewsService {
  static const String _savedNewsKey = 'saved_news';

  Future<List<NewsModel>> getSavedNews() async {
    final preferences = await SharedPreferences.getInstance();
    final savedNews = preferences.getStringList(_savedNewsKey) ?? [];

    return savedNews.map((item) {
      final json = jsonDecode(item);

      return NewsModel.fromJson(
        Map<String, dynamic>.from(json),
      );
    }).toList();
  }

  Future<bool> isSaved(NewsModel news) async {
    final savedNews = await getSavedNews();

    return savedNews.any(
          (saved) => saved.url == news.url,
    );
  }

  Future<bool> saveNews(NewsModel news) async {
    final preferences = await SharedPreferences.getInstance();
    final savedNews = preferences.getStringList(_savedNewsKey) ?? [];

    final alreadySaved = savedNews.any((item) {
      final json = jsonDecode(item);

      return json['url'] == news.url;
    });

    if (alreadySaved) {
      return true;
    }

    savedNews.add(
      jsonEncode(news.toJson()),
    );

    await preferences.setStringList(
      _savedNewsKey,
      savedNews,
    );

    return true;
  }

  Future<bool> removeNews(NewsModel news) async {
    final preferences = await SharedPreferences.getInstance();
    final savedNews = preferences.getStringList(_savedNewsKey) ?? [];

    savedNews.removeWhere((item) {
      final json = jsonDecode(item);

      return json['url'] == news.url;
    });

    await preferences.setStringList(
      _savedNewsKey,
      savedNews,
    );

    return false;
  }

  Future<bool> toggleSave(NewsModel news) async {
    final saved = await isSaved(news);

    if (saved) {
      return await removeNews(news);
    }

    return await saveNews(news);
  }

  Future<void> clearSavedNews() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_savedNewsKey);
  }
}