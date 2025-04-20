import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:healthor/providers/symptom_provider.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:logger/logger.dart';
  import 'dart:convert';

  class SymptomCheckerScreen extends StatefulWidget {
    const SymptomCheckerScreen({super.key});

    @override
    SymptomCheckerScreenState createState() => SymptomCheckerScreenState();
  }

  class SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
    Map<String, dynamic>? _remedies;
    bool _remediesLoadFailed = false;
    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
      super.initState();
      _loadRemedies();
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    Future<void> _loadRemedies() async {
      try {
        final String response = await DefaultAssetBundle.of(context).loadString('assets/remedies.json');
        setState(() {
          _remedies = jsonDecode(response);
          _remediesLoadFailed = false;
        });
      } catch (e) {
        setState(() {
          _remediesLoadFailed = true;
        });
        Logger().e('Failed to load remedies.json: $e');
      }
    }

    @override
    Widget build(BuildContext context) {
      final logger = Logger();

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Symptom Checker',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF007BFF),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<SymptomProvider>(
                builder: (context, symptomProvider, child) {
                  logger.d('SymptomCheckerScreen build: isLoading=${symptomProvider.isLoading}, conditions=${symptomProvider.conditions.length}');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search symptoms',
                          hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF007BFF)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFF007BFF)),
                                  onPressed: () {
                                    _searchController.clear();
                                    symptomProvider.filterFeatures('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF007BFF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF007BFF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                        onChanged: (value) {
                          symptomProvider.filterFeatures(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select symptoms:',
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<void>(
                        future: symptomProvider.featuresFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error loading symptoms: ${snapshot.error}',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                            );
                          }
                          if (symptomProvider.features.isEmpty) {
                            return Text(
                              'No symptoms match your search.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: symptomProvider.features.map((feature) {
                              return ChoiceChip(
                                label: Text(
                                  feature,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                selected: symptomProvider.symptoms.contains(feature),
                                onSelected: (selected) {
                                  if (selected) {
                                    symptomProvider.addSymptom(feature);
                                  } else {
                                    symptomProvider.removeSymptom(feature);
                                  }
                                },
                                selectedColor: const Color(0xFF007BFF),
                                labelStyle: GoogleFonts.poppins(
                                  color: symptomProvider.symptoms.contains(feature)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: symptomProvider.isLoading
                                ? null
                                : () {
                                    if (symptomProvider.symptoms.isNotEmpty) {
                                      symptomProvider.checkSymptoms();
                                    }
                                  },
                            child: Text(
                              'Check Symptoms',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: symptomProvider.isLoading ? null : () => symptomProvider.clear(),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (symptomProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (symptomProvider.conditions.isEmpty)
                        Text(
                          'No conditions found. Select symptoms to check.',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: symptomProvider.conditions.length,
                          itemBuilder: (context, index) {
                            final condition = symptomProvider.conditions[index];
                            final remedy = _remedies != null ? _remedies![condition.name] : null;
                            logger.d('Rendering condition: ${condition.name}');
                            return ListTile(
                              title: Text(
                                condition.name,
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Probability: ${(condition.probability * 100).toStringAsFixed(1)}%',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  Text(
                                    'Triage: ${condition.triage}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  if (_remediesLoadFailed)
                                    Text(
                                      'Remedies unavailable: Failed to load data.',
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                                    ),
                                  if (remedy != null)
                                    Text(
                                      'Remedy: ${remedy['remedy']}\nRest: ${remedy['rest']}',
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }