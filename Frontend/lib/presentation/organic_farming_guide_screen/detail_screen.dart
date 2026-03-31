import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final dynamic content;

  const DetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  String extractText(BuildContext context, dynamic data) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).currentLanguage;

    if (data is Map) {
      if (data.containsKey(lang)) {
        return data[lang].toString();
      }
      return data.values.map((e) => extractText(context, e)).join("\n\n");
    } else if (data is List) {
      return data.map((e) => extractText(context, e)).join("\n\n");
    } else {
      return data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = extractText(context, content);

    return Scaffold(
      appBar: AppBar(
        title: Text(title.replaceAll("_", " ").toUpperCase()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}