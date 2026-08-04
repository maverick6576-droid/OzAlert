class NewsItem {
  final String title;
  final String link;
  final String pubDate;
  final String description;
  final String? imageUrl;
  final String category; // 'oficial', 'guia', 'comunidad'

  const NewsItem({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.description,
    this.imageUrl,
    this.category = 'oficial',
  });

  NewsItem copyWith({
    String? title,
    String? link,
    String? pubDate,
    String? description,
    String? imageUrl,
    String? category,
  }) {
    return NewsItem(
      title: title ?? this.title,
      link: link ?? this.link,
      pubDate: pubDate ?? this.pubDate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
