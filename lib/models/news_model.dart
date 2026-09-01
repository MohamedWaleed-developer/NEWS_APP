class NewsModel {
  final String title;
  final String urlToImage;
  final String url;

  NewsModel({
    required this.title,
    required this.urlToImage,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'Title not available',
      urlToImage: json['urlToImage'] ?? 'assets/animation/no_news.json',
      url: json['url'] ?? '404 not found',
    );
  }
}