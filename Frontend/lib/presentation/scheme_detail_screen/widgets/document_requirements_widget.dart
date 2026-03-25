import 'package:flutter/material.dart';

class DocumentRequirementsWidget extends StatelessWidget {
  final List<String> documents;

  const DocumentRequirementsWidget({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: documents.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.description, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
