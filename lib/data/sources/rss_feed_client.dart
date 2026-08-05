import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:flutter/foundation.dart';
import '../../domain/models/news_item.dart';

class RssFeedClient {
  final http.Client _client;

  RssFeedClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NewsItem>> fetchMigrationNews() async {
    final List<NewsItem> parsedItems = [];
    const url = 'https://immi.homeaffairs.gov.au/what-we-do/whm-program/latest-news';

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        
        final container = document.getElementById('ctl00_PlaceHolderMain_ctl06__ControlWrapper_RichHtmlField');
        if (container != null) {
          String currentTitle = '';
          String currentDesc = '';
          
          for (final node in container.children) {
            if (node.localName == 'h3') {
              if (currentTitle.isNotEmpty) {
                parsedItems.add(NewsItem(
                  title: currentTitle,
                  link: url,
                  pubDate: 'ACTUALIZADO',
                  description: currentDesc.trim(),
                  category: 'oficial',
                ));
              }
              currentTitle = node.text.trim();
              currentDesc = '';
            } else if (node.localName == 'p' && currentTitle.isNotEmpty) {
              final pText = node.text.trim();
              if (pText.isNotEmpty) {
                currentDesc += '$pText\n\n';
              }
            }
          }
          
          if (currentTitle.isNotEmpty) {
            parsedItems.add(NewsItem(
              title: currentTitle,
              link: url,
              pubDate: 'ACTUALIZADO',
              description: currentDesc.trim(),
              category: 'oficial',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error procesando el HTML: $e');
    }

    if (parsedItems.isEmpty) {
      parsedItems.add(NewsItem(
        title: 'Error de conexión',
        link: url,
        pubDate: 'AHORA',
        description: 'No pudimos obtener la información en vivo. Toca aquí para abrir la página oficial en el navegador.',
        category: 'oficial',
      ));
    }

    return parsedItems;
  }
}
