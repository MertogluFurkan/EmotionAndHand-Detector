import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/analysis_result.dart';

class ApiService {
  /// Geliştirme ortamına göre değiştir:
  /// - iOS Simulator  → http://localhost:8000
  /// - Android Emulator → http://10.0.2.2:8000
  /// - Fiziksel cihaz → http://<bilgisayar-IP>:8000
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static const Duration _timeout = Duration(seconds: 60);

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// Backend'in çalışıp çalışmadığını kontrol eder
  static Future<bool> isReachable() async {
    try {
      final res = await http.get(_uri('/health')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Görüntü byte'larını backend'e göndererek analiz sonucu alır
  static Future<AnalysisResult> analyze(
    Uint8List imageBytes, {
    String filename = 'capture.jpg',
  }) async {
    final request = http.MultipartRequest('POST', _uri('/analyze'))
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: filename,
        ),
      );

    final streamedResponse = await request.send().timeout(_timeout);
    final body = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      final err = _parseError(body);
      throw ApiException(err, statusCode: streamedResponse.statusCode);
    }

    final json = jsonDecode(body) as Map<String, dynamic>;

    if (json['success'] == true && json['data'] != null) {
      return AnalysisResult.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw ApiException(json['detail']?.toString() ?? 'Bilinmeyen sunucu hatası');
  }

  static String _parseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['detail']?.toString() ?? body;
    } catch (_) {
      return body.isEmpty ? 'Sunucuya ulaşılamıyor' : body;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
