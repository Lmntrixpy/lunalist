import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:path_provider/path_provider.dart';

typedef DownloadProgressCallback = void Function(int received, int? total);

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

  Future<void> _downloadToFile(
    Uri uri,
    File file, {
    Duration timeout = const Duration(minutes: 5),
    DownloadProgressCallback? onProgress,
  }) async {
    final request = http.Request('GET', uri);
    final response = await _http.send(request).timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw LunalistApiException(
        message: 'HTTP ${response.statusCode} for $uri',
        statusCode: response.statusCode,
        uri: uri,
        body: body,
      );
    }

    final total = response.contentLength;
    var received = 0;

    final sink = file.openWrite();

    try {
      await for (final chunk in response.stream.timeout(timeout)) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, total);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  Future<HealthResponse> health() async {
    final json = await _getJson(_u('/health'));
    return HealthResponse.fromJson(json);
  }

  Future<VersionResponse> version() async {
    final json = await _getJson(_u('/version'));
    return VersionResponse.fromJson(json);
  }

  Future<CheckResponse> check({required String current}) async {
    final json = await _getJson(_u('/check', {'current': current}));
    return CheckResponse.fromJson(json);
  }

  Future<DownloadedInstaller> downloadLatestInstaller({
    String? platform,
    String? androidApplicationId,
    Duration downloadTimeout = const Duration(minutes: 5),
    DownloadProgressCallback? onProgress,
  }) async {
    final resolvedPlatform = platform ?? _defaultPlatform();

    if (resolvedPlatform != 'android' && resolvedPlatform != 'windows') {
      throw ArgumentError.value(
        resolvedPlatform,
        'platform',
        'Only "android" and "windows" are supported.',
      );
    }

    final uri = _u('/download', {'platform': resolvedPlatform});

    final Directory targetDir;
    final String fileName;

    switch (resolvedPlatform) {
      case 'android':
        final dir = await getExternalStorageDirectory();
        if (dir == null) {
          throw const FileSystemException(
            'External storage directory not available.',
          );
        }
        targetDir = dir;
        fileName = 'lunalist_update.apk';
        break;
      case 'windows':
        targetDir = await _getWindowsDownloadsDirectory();
        fileName = 'lunalist_update.exe';
        break;
      default:
        throw StateError('Unsupported platform: $resolvedPlatform');
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final file = File('${targetDir.path}${Platform.pathSeparator}$fileName');

    await _downloadToFile(
      uri,
      file,
      timeout: downloadTimeout,
      onProgress: onProgress,
    );

    String? installResult;
    if (resolvedPlatform == 'android') {
      if (androidApplicationId == null || androidApplicationId.isEmpty) {
        throw ArgumentError(
          'androidApplicationId is required on Android to start APK installation.',
        );
      }

      installResult = await InstallPlugin.installApk(
        file.path,
        androidApplicationId,
      );
    }

    return DownloadedInstaller(
      platform: resolvedPlatform,
      file: file,
      installResult: installResult,
    );
  }

  String _defaultPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';

    throw UnsupportedError(
      'This device is not supported for installer downloads. Supported: Android, Windows.',
    );
  }

  Future<Directory> _getWindowsDownloadsDirectory() async {
    final home = Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty) {
      throw const FileSystemException(
        'Could not determine the Windows user directory.',
      );
    }

    return Directory('$home${Platform.pathSeparator}Downloads');
  }
}

class DownloadedInstaller {
  const DownloadedInstaller({
    required this.platform,
    required this.file,
    this.installResult,
  });

  final String platform;
  final File file;
  final String? installResult;
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
  final String version;
  final int build;
  final String raw;
  final String source;

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
  final String current;
  final String latest;

  factory CheckResponse.fromJson(Map<String, dynamic> json) {
    return CheckResponse(
      ok: json['ok'] == true,
      updateAvailable: json['update_available'] == true,
      current: (json['current'] ?? '').toString(),
      latest: (json['latest'] ?? '').toString(),
    );
  }
}