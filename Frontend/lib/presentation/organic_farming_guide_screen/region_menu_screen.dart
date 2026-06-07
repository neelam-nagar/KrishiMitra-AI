import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';


class RegionMenuScreen extends StatefulWidget {
  final String regionKey;

  const RegionMenuScreen({super.key, required this.regionKey});

  @override
  State<RegionMenuScreen> createState() => _RegionMenuScreenState();
}

class _RegionMenuScreenState extends State<RegionMenuScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final path =
          'assets/organic_guide/regions/${widget.regionKey}.json';

      print("📂 Loading JSON from: $path");

      final jsonString = await rootBundle.loadString(path);

      final jsonData = json.decode(jsonString);

      print("✅ JSON Loaded Successfully");

      setState(() {
        data = jsonData;
        loading = false;
      });
    } catch (e) {
      print("❌ ERROR LOADING JSON: $e");

      setState(() {
        loading = false;
      });
    }
  }

  String formatData(Map<String, dynamic> data) {
    String result = "";

    data.forEach((key, value) {
      if (['area', 'districts'].contains(key)) return;

      // Format heading nicely
      String heading = key
          .replaceAll("_", " ")
          .toUpperCase();

      result += "\n\n$heading\n";

      if (value is Map && value.containsKey('en')) {
        if (value['en'] is List) {
          for (var item in value['en']) {
            result += "• $item\n";
          }
        } else {
          result += "${value['en']}\n";
        }
      } else if (value is Map) {
        value.forEach((subKey, subValue) {
          if (subValue is Map && subValue.containsKey('en')) {
            if (subValue['en'] is List) {
              for (var item in subValue['en']) {
                result += "• $item\n";
              }
            } else {
              result += "${subValue['en']}\n";
            }
          }
        });
      }

      result += "\n";
    });

    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No Data Found")),
      );
    }

    final excludedKeys = ['area', 'districts', 'introduction', 'crop_wise_detailed_guidance'];

    final menuKeys = data!.keys
        .where((key) => !excludedKeys.contains(key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.regionKey.replaceAll("_", " ").toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // INTRO CARD
            if (data!['introduction'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "INTRODUCTION",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data!['introduction']['hi'] ?? '',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),

            // SECTIONS
            ...data!.entries
                .where((entry) =>
                    !['area', 'districts', 'introduction', 'crop_wise_detailed_guidance']
                        .contains(entry.key))
                .map((entry) {
              final key = entry.key;
              final value = entry.value;

              String title =
                  key.replaceAll("_", " ").toUpperCase();

              List<String> content = [];

              if (value is Map) {
                // ✅ Try Hindi first
                if (value.containsKey('hi')) {
                  if (value['hi'] is List) {
                    content = List<String>.from(value['hi']);
                  } else {
                    content = [value['hi']];
                  }
                }
                // 🔁 Fallback to English if Hindi not available
                else if (value.containsKey('en')) {
                  if (value['en'] is List) {
                    content = List<String>.from(value['en']);
                  } else {
                    content = [value['en']];
                  }
                } else {
                  value.forEach((_, subValue) {
                    if (subValue is Map) {
                      if (subValue.containsKey('hi')) {
                        if (subValue['hi'] is List) {
                          content.addAll(List<String>.from(subValue['hi']));
                        } else {
                          content.add(subValue['hi']);
                        }
                      } else if (subValue.containsKey('en')) {
                        if (subValue['en'] is List) {
                          content.addAll(List<String>.from(subValue['en']));
                        } else {
                          content.add(subValue['en']);
                        }
                      }
                    }
                  });
                }
              }

              // 🌿 Fixed green theme for all sections
              Color sectionColor;
              IconData sectionIcon;
              sectionColor = Colors.green;
              sectionIcon = Icons.eco;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      sectionColor.withOpacity(0.08),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: sectionColor.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: sectionColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: sectionColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(sectionIcon, color: sectionColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: sectionColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 📌 Content
                      ...content.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: sectionColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}