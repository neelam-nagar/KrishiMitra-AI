import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/language_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/location_provider.dart';

class LocationSelectorBottomSheet extends StatefulWidget {
  const LocationSelectorBottomSheet({super.key});

  @override
  State<LocationSelectorBottomSheet> createState() =>
      _LocationSelectorBottomSheetState();
}

class _LocationSelectorBottomSheetState
    extends State<LocationSelectorBottomSheet> {
  String? selectedDistrict;
  String? selectedTehsil;
  String? selectedVillage;

  List<String> districts = [];
  List<String> tehsils = [];
  List<String> villages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() => isLoading = true);
    final res = await http.get(Uri.parse('http://127.0.0.1:5001/locations/districts'));
    districts = List<String>.from(json.decode(res.body));
    setState(() => isLoading = false);
  }

  Future<void> _loadTehsils(String district) async {
    setState(() => isLoading = true);
    final res = await http.get(
      Uri.parse('http://127.0.0.1:5001/locations/tehsils?district=$district'),
    );
    tehsils = List<String>.from(json.decode(res.body));
    setState(() => isLoading = false);
  }

  Future<void> _loadVillages(String district, String tehsil) async {
    setState(() => isLoading = true);
    final res = await http.get(
      Uri.parse('http://127.0.0.1:5001/locations/villages?district=$district&tehsil=$tehsil'),
    );
    villages = List<String>.from(json.decode(res.body));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                lang == 'en' ? 'Select Location' : 'स्थान चुनें',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// 🟢 District Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              hint: Text(lang == 'en' ? 'Select District' : 'जिला चुनें'),
              items: districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  selectedDistrict = value;
                  selectedTehsil = null;
                  selectedVillage = null;
                  tehsils = [];
                  villages = [];
                });
                await _loadTehsils(value!);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// 🟢 Tehsil Dropdown
            DropdownButtonFormField<String>(
              value: selectedTehsil,
              hint: Text(lang == 'en' ? 'Select Tehsil' : 'तहसील चुनें'),
              items: tehsils
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: selectedDistrict == null
                  ? null
                  : (value) async {
                      setState(() {
                        selectedTehsil = value;
                        selectedVillage = null;
                        villages = [];
                      });
                      await _loadVillages(selectedDistrict!, value!);
                    },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// 🟢 Village Dropdown
            DropdownButtonFormField<String>(
              value: selectedVillage,
              hint: Text(lang == 'en' ? 'Select Village' : 'गांव चुनें'),
              items: villages
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: selectedTehsil == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedVillage = value;
                      });
                    },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedVillage == null
                    ? null
                    : () {
                        context.read<LocationProvider>().updateLocation(
                          district: selectedDistrict!,
                          tehsil: selectedTehsil!,
                          village: selectedVillage!,
                        );
                        Navigator.pop(context);
                      },
                child: Text(lang == 'en' ? 'Apply Location' : 'स्थान लागू करें'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}