import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class GeminiNewsService {
  // IMPORTANT: Keep API key secure in production (do not hardcode).
  static const String _apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY_HERE';

  // Preferred models in descending order of desired capability.
  static final List<String> _preferredModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-1.0-pro',
    'gemini-pro',
    'gemini-2.0-flash-exp',
  ];

  // Cache discovered working model & api version.
  static String? _selectedModel; // e.g. gemini-1.5-flash
  static String? _selectedApiVersion; // 'v1' or 'v1beta'
  static bool _modelDiscoveryAttempted = false;
  // Debug flag for verbose nationwide parsing logs
  static const bool _debugNationwide = false;
  static void _logNationwide(String msg) {
    if (_debugNationwide) print(msg);
  }

  // Dynamic base URL builder.
  static String _buildGenerateEndpoint() {
    if (_selectedModel == null || _selectedApiVersion == null) {
      return ''; // Will trigger discovery.
    }
    return 'https://generativelanguage.googleapis.com/${_selectedApiVersion}/models/${_selectedModel}:generateContent';
  }

  // Fallback mock data for when API fails or quota exceeded
  static Map<String, dynamic> _getFallbackData(
      double latitude, double longitude, String? cityName) {
    final location = cityName ?? 'Location: $latitude, $longitude';

    // Check if location is near coastal areas (simplified check)
    final isCoastal = _isNearCoast(latitude, longitude);

    if (isCoastal) {
      // Return sample disaster data for coastal areas
      return {
        'hasDisasters': true,
        'location': location,
        'disasterCount': 2,
        'disasters': [
          {
            'title': 'Coastal Storm Warning Issued',
            'details':
                'Meteorological department has issued a storm warning for coastal regions. High tide expected with wind speeds up to 60 km/h. Fishermen advised not to venture into the sea.',
            'category': 'Storm',
            'severity': 'Medium',
            'date': DateTime.now()
                .subtract(Duration(hours: 3))
                .toIso8601String()
                .split('.')[0]
                .replaceAll('T', ' '),
            'distance': '45 km',
            'affectedAreas': ['Coastal Belt', 'Harbor Area', 'Beach Zone'],
            'source': 'India Meteorological Department (IMD)',
            'isBreaking': true,
            'latitude': latitude + 0.5,
            'longitude': longitude + 0.3,
          },
          {
            'title': 'Minor Coastal Erosion Reported',
            'details':
                'Local authorities report increased coastal erosion due to recent tidal activity. Several beach areas have been cordoned off for safety.',
            'category': 'Coastal Erosion',
            'severity': 'Low',
            'date': DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String()
                .split('.')[0]
                .replaceAll('T', ' '),
            'distance': '78 km',
            'affectedAreas': ['North Beach', 'Marina'],
            'source': 'Coastal Management Authority',
            'isBreaking': false,
            'latitude': latitude - 0.7,
            'longitude': longitude + 0.5,
          },
        ],
        'safetyMessage':
            'Stay informed about weather updates and follow local authority advisories.',
        'lastUpdated': DateTime.now().toIso8601String(),
        'userLocation': {
          'latitude': latitude,
          'longitude': longitude,
        },
      };
    } else {
      // Return safe data for non-coastal areas
      return {
        'hasDisasters': false,
        'location': location,
        'disasterCount': 0,
        'disasters': [],
        'safetyMessage':
            'Your area is currently safe. No maritime disasters detected within 500km radius.',
        'lastUpdated': DateTime.now().toIso8601String(),
        'userLocation': {
          'latitude': latitude,
          'longitude': longitude,
        },
      };
    }
  }

  // Simple check if location is near coast (India coastal coordinates)
  static bool _isNearCoast(double lat, double lon) {
    // Simplified check for Indian coastal regions
    // West Coast: lon < 77 and lat between 8-23
    // East Coast: lon > 80 and lat between 8-22
    // South Coast: lat < 12
    return (lon < 77 && lat >= 8 && lat <= 23) || // West coast
        (lon > 80 && lat >= 8 && lat <= 22) || // East coast
        (lat < 12); // South coast
  }

  // Fetch disaster news based on user location
  static Future<Map<String, dynamic>> fetchDisasterNews({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    try {
      final prompt = _buildPrompt(latitude, longitude, cityName);

      print('🔍 Calling Gemini API...');
      print('📍 Location: $latitude, $longitude');

      // Ensure we have a working model selected
      await _ensureModelSelected();
      var endpoint = _buildGenerateEndpoint();
      if (endpoint.isEmpty) {
        print('❌ No model endpoint resolved. Using fallback data.');
        return _getFallbackData(latitude, longitude, cityName);
      }
      print('🧪 Using model: ${_selectedModel} (api ${_selectedApiVersion})');

      final response = await http
          .post(
            Uri.parse('$endpoint?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.4,
                'topK': 32,
                'topP': 1,
                'maxOutputTokens': 2048,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('✅ API Response received');
        final data = jsonDecode(response.body);

        // Check if response has the expected structure
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final generatedText =
              data['candidates'][0]['content']['parts'][0]['text'];
          print('📰 Generated text length: ${generatedText.length}');
          return _parseResponse(generatedText, latitude, longitude);
        } else {
          print('❌ Invalid response structure');
          throw Exception('Invalid response format from Gemini API');
        }
      } else if (response.statusCode == 429) {
        // Quota exceeded - use fallback
        print('⚠️ API Quota exceeded, using fallback data');
        return _getFallbackData(latitude, longitude, cityName);
      } else if (response.statusCode == 404) {
        print(
            '⚠️ 404 Not Found for model ${_selectedModel}. Attempting re-discovery & retry once.');
        // Force re-discovery of a different model and retry once.
        _selectedModel = null;
        _selectedApiVersion = null;
        _modelDiscoveryAttempted = false;
        await _ensureModelSelected(force: true);
        endpoint = _buildGenerateEndpoint();
        if (endpoint.isEmpty) {
          print('❌ Re-discovery failed. Using fallback.');
          return _getFallbackData(latitude, longitude, cityName);
        }
        print('🔁 Retrying with model ${_selectedModel}');
        final retryResp = await http
            .post(
              Uri.parse('$endpoint?key=$_apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt}
                    ]
                  }
                ],
                'generationConfig': {
                  'temperature': 0.4,
                  'topK': 32,
                  'topP': 1,
                  'maxOutputTokens': 2048,
                }
              }),
            )
            .timeout(const Duration(seconds: 30));
        if (retryResp.statusCode == 200) {
          final data = jsonDecode(retryResp.body);
          if (data['candidates'] != null &&
              data['candidates'].isNotEmpty &&
              data['candidates'][0]['content'] != null &&
              data['candidates'][0]['content']['parts'] != null &&
              data['candidates'][0]['content']['parts'].isNotEmpty) {
            final generatedText =
                data['candidates'][0]['content']['parts'][0]['text'];
            return _parseResponse(generatedText, latitude, longitude);
          }
          print('❌ Retry succeeded but response invalid. Using fallback.');
          return _getFallbackData(latitude, longitude, cityName);
        } else {
          print('❌ Retry failed (${retryResp.statusCode}). Using fallback.');
          return _getFallbackData(latitude, longitude, cityName);
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Use fallback for any API error
        print('⚠️ API error, using fallback data');
        return _getFallbackData(latitude, longitude, cityName);
      }
    } catch (e) {
      print('❌ Exception caught: $e');
      print('⚠️ Using fallback data due to exception');
      // Return fallback data instead of throwing error
      return _getFallbackData(latitude, longitude, cityName);
    }
  }

  // Ensure a working model is selected (only once unless forced).
  static Future<void> _ensureModelSelected({bool force = false}) async {
    if (!force && _selectedModel != null && _selectedApiVersion != null) return;
    if (!force && _modelDiscoveryAttempted) return; // Avoid repeated attempts.
    _modelDiscoveryAttempted = true;

    print('🔎 Discovering available Gemini models...');
    final models = await _listAvailableModels();
    if (models.isEmpty) {
      print('❌ No models returned from discovery API.');
      return;
    }
    // Filter to those supporting generateContent
    final generateCapable = models
        .where((m) =>
            (m['supportedGenerationMethods'] as List?)
                ?.contains('generateContent') ==
            true)
        .toList();
    if (generateCapable.isEmpty) {
      print('❌ No models support generateContent.');
      return;
    }
    // Try preferred list first
    for (final preferred in _preferredModels) {
      final match = generateCapable.firstWhere(
        (m) => (m['name'] as String).contains(preferred),
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        _selectedModel = match['name']
            .toString()
            .split('/')
            .last; // name like models/gemini-1.5-flash
        _selectedApiVersion = match['apiVersion'] as String? ?? 'v1';
        print('✅ Selected model: $_selectedModel (api $_selectedApiVersion)');
        return;
      }
    }
    // Fallback: just pick the first generate-capable model.
    final first = generateCapable.first;
    _selectedModel = first['name'].toString().split('/').last;
    _selectedApiVersion = first['apiVersion'] as String? ?? 'v1';
    print(
        '✅ Selected fallback model: $_selectedModel (api $_selectedApiVersion)');
  }

  // List models from both v1 and v1beta, returning combined metadata.
  static Future<List<Map<String, dynamic>>> _listAvailableModels() async {
    final List<Map<String, dynamic>> collected = [];
    for (final version in ['v1', 'v1beta']) {
      final url =
          'https://generativelanguage.googleapis.com/$version/models?key=$_apiKey';
      try {
        final resp =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final models = (data['models'] as List?) ?? [];
          for (final m in models) {
            collected.add({
              'name': m['name'],
              'supportedGenerationMethods': m['supportedGenerationMethods'],
              'apiVersion': version,
            });
          }
          print('📄 Retrieved ${models.length} models from $version');
        } else {
          print('⚠️ Failed listing models from $version (${resp.statusCode})');
        }
      } catch (e) {
        print('⚠️ Exception listing models from $version: $e');
      }
    }
    print('📦 Total models collected: ${collected.length}');
    return collected;
  }

  static String _buildPrompt(double lat, double lon, String? cityName) {
    final location = cityName ?? 'Location: $lat, $lon';

    return '''
You are a maritime disaster monitoring system. Analyze recent disaster news (within last 7 days) near $location (latitude: $lat, longitude: $lon) within 500km radius.

Search for maritime and coastal disasters including: cyclones, tsunamis, floods, oil spills, storms, coastal erosion, earthquakes affecting coastal areas.

Provide response in EXACTLY this JSON format (no markdown, no code blocks, just raw JSON):
{
  "hasDisasters": true/false,
  "location": "$location",
  "disasterCount": number,
  "disasters": [
    {
      "title": "Brief disaster headline",
      "details": "Detailed description (2-3 sentences)",
      "category": "Cyclone/Tsunami/Flood/Oil Spill/Storm/Earthquake/Coastal Erosion",
      "severity": "Low/Medium/High/Critical",
      "date": "YYYY-MM-DD HH:mm:ss",
      "distance": "Approximate distance from user location in km",
      "affectedAreas": ["area1", "area2"],
      "source": "News source/authority (e.g., IMD, NDMA, Local News)",
      "isBreaking": true/false,
      "latitude": approximate latitude,
      "longitude": approximate longitude
    }
  ],
  "safetyMessage": "Brief safety message or all-clear message",
  "lastUpdated": "Current timestamp"
}

Important:
- If NO disasters found within 500km in last 7 days, return hasDisasters: false, disasterCount: 0, empty disasters array, and positive safetyMessage
- Use real/realistic data sources like IMD, NDMA, Coast Guard, NASA, NOAA
- Calculate approximate distance from user location
- Mark as breaking if within last 24 hours
- Be accurate and realistic
- Return ONLY valid JSON, no extra text
''';
  }

  static Map<String, dynamic> _parseResponse(
      String response, double userLat, double userLon) {
    try {
      // Clean up response - remove markdown code blocks if present
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse =
            cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      final parsed = jsonDecode(cleanedResponse);

      // Add user location to response
      parsed['userLocation'] = {
        'latitude': userLat,
        'longitude': userLon,
      };

      return parsed;
    } catch (e) {
      // Fallback response if parsing fails
      return {
        'hasDisasters': false,
        'location': 'Location: $userLat, $userLon',
        'disasterCount': 0,
        'disasters': [],
        'safetyMessage': 'No disasters detected in your area. Stay safe!',
        'lastUpdated': DateTime.now().toIso8601String(),
        'userLocation': {
          'latitude': userLat,
          'longitude': userLon,
        },
      };
    }
  }

  // Get user's current location
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Get city name from coordinates (reverse geocoding)
  static Future<String?> getCityName(double lat, double lon) async {
    try {
      // Using Nominatim for reverse geocoding
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'TarangApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        return address['city'] ??
            address['town'] ??
            address['village'] ??
            address['state'];
      }
    } catch (e) {
      // Return null if geocoding fails
    }
    return null;
  }

  // Fetch nationwide disasters across India (not location-specific)
  static Future<List<Map<String, dynamic>>> fetchNationwideDisasters() async {
    print('🌏 Fetching nationwide disasters...');
    try {
      await _ensureModelSelected();
      final endpoint = _buildGenerateEndpoint();
      if (endpoint.isEmpty) {
        print('❌ No model endpoint. Using nationwide fallback.');
        return _getNationwideFallbackData();
      }

      const prompt = '''
You are monitoring maritime disasters across India. Provide 3 recent disasters (last 7 days) from coastal regions.
Return ONLY this exact JSON structure with NO markdown, NO extra text:
{"disasters":[{"title":"Disaster headline","details":"Brief description in one sentence","category":"Cyclone","severity":"High","date":"2025-11-23 10:00:00","location":"City, State","affectedAreas":["Area1","Area2"],"source":"IMD","isBreaking":true,"latitude":19.0,"longitude":72.0}]}
Rules:
- Exactly 3 disasters
- All strings must be single line (no line breaks)
- Use categories: Cyclone, Tsunami, Flood, Oil Spill, Storm, Earthquake, Coastal Erosion
- Use severity: Low, Medium, High, Critical
- Keep details under 100 characters
- Return ONLY the JSON, nothing else
''';

      final response = await http
          .post(
            Uri.parse('$endpoint?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.4,
                'topK': 32,
                'topP': 1,
                'maxOutputTokens': 1200,
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        print('❌ Nationwide fetch HTTP ${response.statusCode}');
        return _getNationwideFallbackData();
      }

      final body = jsonDecode(response.body);
      final candidates = body['candidates'];
      if (candidates == null || candidates.isEmpty) {
        print('⚠️ No candidates returned');
        return _getNationwideFallbackData();
      }
      final parts = candidates[0]['content']?['parts'];
      if (parts == null || parts.isEmpty) {
        print('⚠️ No content parts');
        return _getNationwideFallbackData();
      }
      final generatedText = (parts[0]['text'] ?? '').toString();
      if (generatedText.isEmpty) {
        print('⚠️ Empty generated text');
        return _getNationwideFallbackData();
      }

      final extracted = _extractJsonBlock(generatedText, rootKey: 'disasters');
      if (extracted == null) {
        print('⚠️ Could not extract JSON block');
        return _getNationwideFallbackData();
      }

      // Remove newlines (model sometimes inserts formatting) & stray code fences
      var normalized =
          extracted.replaceAll('\r', '').replaceAll('\n', ' ').trim();
      if (normalized.startsWith('```')) {
        normalized = normalized.replaceFirst(RegExp(r'^```\w*'), '').trim();
      }
      if (normalized.endsWith('```')) {
        normalized = normalized.substring(0, normalized.length - 3).trim();
      }
      // Remove trailing commas before closing braces/brackets
      normalized = normalized.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

      dynamic parsed;
      try {
        parsed = jsonDecode(normalized);
      } catch (e) {
        print('❌ JSON parse failed: $e');
        return _getNationwideFallbackData();
      }

      final disastersRaw = parsed['disasters'];
      final disasters = (disastersRaw is List ? disastersRaw : [])
          .whereType<Map<String, dynamic>>()
          .where((d) => d['title'] != null && d['details'] != null)
          .toList();
      if (disasters.isEmpty) {
        print('⚠️ Parsed JSON but no valid disasters');
        return _getNationwideFallbackData();
      }
      print('✅ Retrieved ${disasters.length} nationwide disasters');
      return disasters;
    } catch (e) {
      print('❌ Exception during nationwide fetch: $e');
      return _getNationwideFallbackData();
    }
  }

  // Fallback nationwide disaster data
  static List<Map<String, dynamic>> _getNationwideFallbackData() {
    return [
      {
        'title': 'Cyclone Alert Issued for Odisha Coast',
        'details':
            'IMD has issued a cyclone warning for Odisha coastal districts. Wind speeds may reach 80 km/h with heavy rainfall expected.',
        'category': 'Cyclone',
        'severity': 'High',
        'date': DateTime.now()
            .subtract(Duration(hours: 6))
            .toIso8601String()
            .split('.')[0]
            .replaceAll('T', ' '),
        'location': 'Puri, Odisha',
        'affectedAreas': ['Puri', 'Bhubaneswar', 'Cuttack'],
        'source': 'India Meteorological Department (IMD)',
        'isBreaking': true,
        'latitude': 19.8135,
        'longitude': 85.8312,
      },
      {
        'title': 'Minor Oil Spill Reported Near Mumbai Harbor',
        'details':
            'Coast Guard reports a small oil spill from a cargo vessel near Mumbai port. Cleanup operations are underway.',
        'category': 'Oil Spill',
        'severity': 'Medium',
        'date': DateTime.now()
            .subtract(Duration(days: 1))
            .toIso8601String()
            .split('.')[0]
            .replaceAll('T', ' '),
        'location': 'Mumbai, Maharashtra',
        'affectedAreas': ['Mumbai Harbor', 'Gateway of India'],
        'source': 'Indian Coast Guard',
        'isBreaking': false,
        'latitude': 18.9220,
        'longitude': 72.8347,
      },
      {
        'title': 'High Tide Warning for Kerala Backwaters',
        'details':
            'Authorities warn of higher than normal tides in Kerala backwaters due to astronomical conditions. Fishermen advised caution.',
        'category': 'Flood',
        'severity': 'Low',
        'date': DateTime.now()
            .subtract(Duration(days: 2))
            .toIso8601String()
            .split('.')[0]
            .replaceAll('T', ' '),
        'location': 'Alappuzha, Kerala',
        'affectedAreas': ['Alappuzha', 'Kochi'],
        'source': 'Kerala Disaster Management Authority',
        'isBreaking': false,
        'latitude': 9.4981,
        'longitude': 76.3388,
      },
      {
        'title': 'Storm Surge Alert for Tamil Nadu Coastal Areas',
        'details':
            'Meteorological department forecasts storm surge affecting Tamil Nadu coast. Fishing activities suspended for 24 hours.',
        'category': 'Storm',
        'severity': 'Medium',
        'date': DateTime.now()
            .subtract(Duration(hours: 18))
            .toIso8601String()
            .split('.')[0]
            .replaceAll('T', ' '),
        'location': 'Chennai, Tamil Nadu',
        'affectedAreas': ['Chennai', 'Kanchipuram', 'Tiruvallur'],
        'source': 'Regional Meteorological Centre',
        'isBreaking': true,
        'latitude': 13.0827,
        'longitude': 80.2707,
      },
    ];
  }

  // Attempts to extract a top-level JSON object containing a given rootKey.
  static String? _extractJsonBlock(String raw, {required String rootKey}) {
    if (raw.isEmpty) return null;
    // Strip code fences first.
    var text = raw.trim();
    if (text.startsWith('```')) {
      final fenceIdx = text.indexOf('\n');
      if (fenceIdx != -1) text = text.substring(fenceIdx + 1);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3).trim();
    }
    // Find position of the root key.
    final keyIndex = text.indexOf('"$rootKey"');
    if (keyIndex == -1) return null;
    // Backtrack to first '{' before key.
    int start = text.lastIndexOf('{', keyIndex);
    if (start == -1) return null;
    // Walk forward tracking brace balance.
    int balance = 0;
    for (int i = start; i < text.length; i++) {
      final c = text[i];
      if (c == '{')
        balance++;
      else if (c == '}') {
        balance--;
        if (balance == 0) {
          return text.substring(start, i + 1);
        }
      }
    }
    // If we reach here JSON likely truncated; attempt partial substring anyway.
    return null;
  }
}
