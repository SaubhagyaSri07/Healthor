import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:healthor/models/condition.dart';
  import 'package:logger/logger.dart';
  import 'dart:convert';

  class SymptomProvider with ChangeNotifier {
    List<String> _symptoms = [];
    List<Condition> _conditions = [];
    bool _isLoading = false;
    String? _sessionId;
    List<String> _features = [];
    List<String> _displayedFeatures = [];
    Future<void>? _featuresFuture;
    final logger = Logger();

    List<String> get features => _displayedFeatures;
    List<String> get symptoms => _symptoms;
    List<Condition> get conditions => _conditions;
    bool get isLoading => _isLoading;
    Future<void> get featuresFuture => _featuresFuture ??= _fetchFeatures();

    static const Map<String, String> _featureIds = {
      'HistoryFever': '17',
      'Sneezing': '37',
      'HeadacheFrontal': '241',
      'HeadacheOther': '247',
      'Chills': '16',
      'SoreThroatROS': '49',
      'Cough': '92',
      'RunnyNoseCongestion': '41',
      'LossOfSmell': '38',
      'LossOfTaste': '39',
    };

    void addSymptom(String symptom) {
      if (!_symptoms.contains(symptom) && _featureIds.containsKey(symptom)) {
        _symptoms.add(symptom);
        notifyListeners();
      }
    }

    void removeSymptom(String symptom) {
      _symptoms.remove(symptom);
      notifyListeners();
    }

    void filterFeatures(String query) {
      if (query.isEmpty) {
        _displayedFeatures = List.from(_features);
      } else {
        _displayedFeatures = _features
            .where((feature) => feature.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      logger.d('Filtered features: $_displayedFeatures');
      notifyListeners();
    }

    Future<void> _acceptTermsOfUse() async {
      final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? 'your_rapidapi_key';
      final apiHost = dotenv.env['RAPIDAPI_HOST'] ?? 'endlessmedicalapi1.p.rapidapi.com';
      final passphrase = dotenv.env['ENDLESS_PASSPHRASE'] ?? 'default_passphrase';
      if (_sessionId == null) await _initSession();
      final url = Uri.parse(
        'https://endlessmedicalapi1.p.rapidapi.com/AcceptTermsOfUse?SessionID=$_sessionId&passphrase=${Uri.encodeQueryComponent(passphrase)}',
      );

      final response = await http.post(
        url,
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': apiHost,
          'useQueryString': 'true',
        },
      );

      logger.d('AcceptTermsOfUse Response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        logger.e('Failed to accept terms: ${response.body}');
        throw Exception('Failed to accept terms: ${response.body}');
      }
    }

    Future<void> _initSession() async {
      final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? 'your_rapidapi_key';
      final apiHost = dotenv.env['RAPIDAPI_HOST'] ?? 'endlessmedicalapi1.p.rapidapi.com';
      final url = Uri.parse('https://endlessmedicalapi1.p.rapidapi.com/InitSession');

      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': apiHost,
          'useQueryString': 'true',
        },
      );

      logger.d('InitSession Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionId = data['SessionID'];
      } else {
        logger.e('Failed to initialize session: ${response.body}');
        throw Exception('Failed to initialize session: ${response.body}');
      }
    }

    Future<void> _fetchFeatures() async {
      if (_sessionId == null) {
        await _initSession();
        await _acceptTermsOfUse();
      }
      final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? 'your_rapidapi_key';
      final apiHost = dotenv.env['RAPIDAPI_HOST'] ?? 'endlessmedicalapi1.p.rapidapi.com';
      final url = Uri.parse('https://endlessmedicalapi1.p.rapidapi.com/GetFeatures?SessionID=$_sessionId');
      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': apiHost,
          'useQueryString': 'true',
        },
      );

      logger.d('GetFeatures Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final allFeatures = (responseData['data'] as List).cast<String>();
        _features = allFeatures.where((feature) => _featureIds.containsKey(feature)).toList();
        _displayedFeatures = List.from(_features);
        notifyListeners();
      } else {
        logger.e('Failed to fetch features: ${response.body}');
        throw Exception('Failed to fetch features: ${response.body}');
      }
    }

    Future<void> fetchFeatures() async {
      _featuresFuture ??= _fetchFeatures();
      await _featuresFuture;
    }

    Future<void> checkSymptoms() async {
      if (_symptoms.isEmpty) {
        _conditions = [];
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        if (_sessionId == null) {
          await _initSession();
          await _acceptTermsOfUse();
        }

        final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? 'your_rapidapi_key';
        final apiHost = dotenv.env['RAPIDAPI_HOST'] ?? 'endlessmedicalapi1.p.rapidapi.com';

        for (var symptom in _symptoms) {
          final featureId = _featureIds[symptom];
          if (featureId == null) continue;
          final updateUrl = Uri.parse(
            'https://endlessmedicalapi1.p.rapidapi.com/UpdateFeature?SessionID=$_sessionId&name=${Uri.encodeQueryComponent(symptom)}&value=$featureId',
          );
          final updateResponse = await http.post(
            updateUrl,
            headers: {
              'X-RapidAPI-Key': apiKey,
              'X-RapidAPI-Host': apiHost,
              'useQueryString': 'true',
            },
          );

          logger.d('UpdateFeature Response for $symptom: ${updateResponse.statusCode} ${updateResponse.body}');

          if (updateResponse.statusCode != 200) {
            logger.e('Failed to update symptom $symptom: ${updateResponse.body}');
            throw Exception('Failed to update symptom $symptom: ${updateResponse.body}');
          }
        }

        final analyzeUrl = Uri.parse('https://endlessmedicalapi1.p.rapidapi.com/Analyze?SessionID=$_sessionId');
        final analyzeResponse = await http.get(
          analyzeUrl,
          headers: {
            'X-RapidAPI-Key': apiKey,
            'X-RapidAPI-Host': apiHost,
            'useQueryString': 'true',
          },
        );

        logger.d('Analyze Response: ${analyzeResponse.statusCode} ${analyzeResponse.body}');

        if (analyzeResponse.statusCode == 200) {
          final data = jsonDecode(analyzeResponse.body);
          final diseases = data['Diseases'] as List<dynamic>;
          _conditions = diseases.asMap().entries.map((entry) {
            final disease = entry.value as Map<String, dynamic>;
            if (disease.isEmpty || disease.keys.isEmpty) {
              logger.w('Skipping invalid disease entry: $disease');
              return null;
            }
            final diseaseName = disease.keys.first;
            try {
              final probability = double.parse(disease[diseaseName]);
              return Condition(
                id: 'c_${entry.key}',
                name: diseaseName,
                probability: probability,
                triage: probability > 0.7 ? 'See a doctor immediately' : 'Monitor symptoms',
              );
            } catch (e) {
              logger.w('Failed to parse disease $diseaseName: $e');
              return null;
            }
          }).where((condition) => condition != null).cast<Condition>().toList();

          if (_conditions.isEmpty) {
            logger.w('No valid conditions parsed from Diseases');
            _conditions = [
              Condition(
                id: 'error',
                name: 'No valid diagnoses found',
                probability: 0.0,
                triage: 'N/A',
              )
            ];
          }
        } else {
          logger.e('Analyze failed: ${analyzeResponse.body}');
          _conditions = [
            Condition(
              id: 'error',
              name: 'API Error: ${analyzeResponse.body}',
              probability: 0.0,
              triage: 'N/A',
            )
          ];
        }
      } catch (e, stackTrace) {
        logger.e('Error in checkSymptoms: $e\n$stackTrace');
        _conditions = [
          Condition(
            id: 'error',
            name: 'Error: $e',
            probability: 0.0,
            triage: 'N/A',
          )
        ];
      } finally {
        _isLoading = false;
        logger.d('checkSymptoms completed: isLoading=$_isLoading, conditions=${_conditions.length}');
        notifyListeners();
      }
    }

    void clear() {
      _symptoms = [];
      _conditions = [];
      _sessionId = null;
      _features = [];
      _displayedFeatures = [];
      _featuresFuture = null;
      _isLoading = false;
      notifyListeners();
    }
  }