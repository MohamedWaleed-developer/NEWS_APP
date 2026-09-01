import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class ApiServices {
  String apiKey = '4bfb6e39a5404f5c956d67a0fb282d23';

  Future<List<NewsModel>> getNews(String category) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=$category&apiKey=$apiKey',
    );

    final result = await http.get(url);

    if (result.statusCode != 200) {
      throw Exception('Failed to load news');
    }

    final resultAfter = jsonDecode(result.body);
    final news = resultAfter['articles'];

    return news
        .map<NewsModel>(
          (article) => NewsModel.fromJson(article),
    )
        .toList();
  }
}