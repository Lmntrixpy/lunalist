import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final instance = SecureStorageService._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> saveSecret(String provider, String token) {
    return _secure.write(key: 'token_$provider', value: token);
  }

  Future<void> saveId(String provider, String token) {
    return _secure.write(key: 'id_$provider', value: token);
  }

  Future<String> getSecret(String provider) async {
    final String? secret = await _secure.read(key: "token_$provider");
    if (secret == null) {
      return "";
    } else {
      return secret;
    }
  }

  Future<String> getId(String provider) async {
    final String? id = await _secure.read(key: "id_$provider");
    if (id == null) {
      return "";
    } else {
      return id;
    }
  }
}