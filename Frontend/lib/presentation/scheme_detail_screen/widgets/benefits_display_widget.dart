import 'package:flutter/material.dart';

class BenefitsDisplayWidget extends StatelessWidget {
  final List<String> benefits;

  const BenefitsDisplayWidget({
    super.key,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
