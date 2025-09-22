import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entity/master_password_entity.dart';
import '../../config/app_constants.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveSalt(String salt) async {
    await _storage.write(key: kSaltKey, value: salt);
  }

  Future<String?> getSalt() async => await _storage.read(key: kSaltKey);

  Future<void> saveMasterPasswordEntity({
    required MasterPasswordEntity masterPasswordEntity,
  }) async {
    await _storage.write(key: kVerifyKey, value: masterPasswordEntity.password);
    await _storage.write(
      key: kRecoveryQuestion,
      value: masterPasswordEntity.recoveryQuestion,
    );
    await _storage.write(
      key: kRecoveryAnswer,
      value: masterPasswordEntity.recoveryAnswer,
    );
  }

  Future<String?> getMasterPassword() async =>
      await _storage.read(key: kVerifyKey);

  Future<String?> getRecoveryQuestion() async =>
      await _storage.read(key: kRecoveryQuestion);

  Future<String?> getRecoveryAnswer() async =>
      await _storage.read(key: kRecoveryAnswer);

  Future<void> clear() async {
    await _storage.delete(key: kSaltKey);
    await _storage.delete(key: kVerifyKey);
  }
}
