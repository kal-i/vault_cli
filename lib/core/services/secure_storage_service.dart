import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveSalt(String salt) async {
    await _storage.write(key: kSaltKey, value: salt);
  }

  Future<String?> getSalt() async => await _storage.read(key: kSaltKey);

  Future<void> saveMasterPassword(String masterPassword) async {
    await _storage.write(key: kVerifyKey, value: masterPassword);
  }

  Future<String?> getMasterPassword() async =>
      await _storage.read(key: kVerifyKey);

  Future<void> clear() async {
    await _storage.delete(key: kSaltKey);
    await _storage.delete(key: kVerifyKey);
  }
}
