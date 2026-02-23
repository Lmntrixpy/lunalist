import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class LunalistVersionApi {
  LunalistVersionApi({
    http.Client? httpClient,
    Uri? baseUri,
    Duration timeout = const Duration(seconds: 6),
  })  : _http = httpClient ?? http.Client(),
        _baseUri = baseUri ?? Uri.parse('https://lunalist-version.rar-home.cloud'),
        _timeout = timeout;

  final http.Client _http;
  final Uri _baseUri;
  final Duration _timeout;

  // optiona, call on close
  void close() => _http.close();

  Uri _u(String path, [Map<String, String>? query]) {
    return _baseUri.replace(
      path: path.startsWith('/') ? path : '/$path',
      queryParameters: query,
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final resp = await _http.get(uri).timeout(_timeout);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw LunalistApiException(
        message: 'HTTP ${resp.statusCode} for $uri',
        statusCode: resp.statusCode,
        uri: uri,
        body: resp.body,
      );
    }

    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw LunalistApiException(
        message: 'Unexpected JSON type (not an object) for $uri',
        statusCode: resp.statusCode,
        uri: uri,
        body: resp.body,
      );
    } catch (e) {
      throw LunalistApiException(
        message: 'Invalid JSON for $uri: $e',
        statusCode: resp.statusCode,
        uri: uri,
        body: resp.body,
      );
    }
  }

  /// GET /health
  Future<HealthResponse> health() async {
    final json = await _getJson(_u('/health'));
    return HealthResponse.fromJson(json);
  }

  /// GET /version
  Future<VersionResponse> version() async {
    final json = await _getJson(_u('/version'));
    return VersionResponse.fromJson(json);
  }

  /// GET /check?current=...
  Future<CheckResponse> check({required String current}) async {
    final json = await _getJson(_u('/check', {'current': current}));
    return CheckResponse.fromJson(json);
  }
}

class LunalistApiException implements Exception {
  LunalistApiException({
    required this.message,
    required this.uri,
    this.statusCode,
    this.body,
  });

  final String message;
  final Uri uri;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    final sc = statusCode == null ? '' : ' (statusCode=$statusCode)';
    final b = body == null ? '' : '\nBody: $body';
    return 'LunalistApiException: $message$sc\nURI: $uri$b';
  }
}

class HealthResponse {
  const HealthResponse({required this.ok});

  final bool ok;

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      ok: json['ok'] == true,
    );
  }
}

class VersionResponse {
  const VersionResponse({
    required this.ok,
    required this.version,
    required this.build,
    required this.raw,
    required this.source,
  });

  final bool ok;
  final String version; // e.g. "1.16.1"
  final int build; // e.g. 1
  final String raw; // e.g. "1.16.1+1"
  final String source; // e.g. "github"

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    final buildVal = json['build'];
    return VersionResponse(
      ok: json['ok'] == true,
      version: (json['version'] ?? '').toString(),
      build: buildVal is int ? buildVal : int.tryParse(buildVal?.toString() ?? '') ?? 0,
      raw: (json['raw'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }
}

class CheckResponse {
  const CheckResponse({
    required this.ok,
    required this.updateAvailable,
    required this.current,
    required this.latest,
  });

  final bool ok;
  final bool updateAvailable;
  final String current; // e.g. "1.16.0+5"
  final String latest; // e.g. "1.16.1+1"

  factory CheckResponse.fromJson(Map<String, dynamic> json) {
    return CheckResponse(
      ok: json['ok'] == true,
      updateAvailable: json['update_available'] == true,
      current: (json['current'] ?? '').toString(),
      latest: (json['latest'] ?? '').toString(),
    );
  }
}