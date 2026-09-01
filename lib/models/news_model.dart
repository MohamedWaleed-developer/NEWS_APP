class NewsModel {
  final String title;
  final String description;
  final String content;
  final String author;
  final String publishedAt;
  final String urlToImage;
  final String url;

  NewsModel({
    required this.title,
    required this.description,
    required this.content,
    required this.author,
    required this.publishedAt,
    required this.urlToImage,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'Title not available',
      description: json['description'] ?? 'No description available',
      content: json['content'] ?? 'No content available',
      author: json['author'] ?? 'Unknown author',
      publishedAt: json['publishedAt'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'publishedAt': publishedAt,
      'urlToImage': urlToImage,
      'url': url,
    };
  }
}