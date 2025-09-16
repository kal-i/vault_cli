import 'package:cryptography/cryptography.dart';

import '../../features/password_vault_console/domain/entities/vault_entry_entity.dart';
import '../services/crypto_service.dart';

class VaultEntryCryptoMapper {
  const VaultEntryCryptoMapper({
    required this.cryptoService,
    required this.secretKey,
  });

  final CryptoService cryptoService;
  final SecretKey secretKey;

  Future<VaultEntryEntity> encryptEntity(VaultEntryEntity e) => _mapEntityFields(e, _encryptIfNotNull);

  Future<VaultEntryEntity> decryptEntity(VaultEntryEntity e) => _mapEntityFields(e, _decryptIfNotNull);

  Future<VaultEntryEntity> _mapEntityFields(
    VaultEntryEntity e,
    Future<String?> Function(String?) operation,
  ) async {
    final password = await operation(e.password);
    final username = await operation(e.username);
    final email = await operation(e.email);
    final contactNo = await operation(e.contactNo);
    final notes = await operation(e.notes);

    return VaultEntryEntity(
      id: e.id,
      title: e.title,
      password: password!,
      username: username,
      email: email,
      contactNo: contactNo,
      notes: notes,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  Future<String?> _encryptIfNotNull(String? plainText) => _executeIfNotEmpty(
    plainText,
    (value) async => await cryptoService.encryptString(secretKey, value),
  );

  Future<String?> _decryptIfNotNull(String? encodedText) =>
      _executeIfNotEmpty(
        encodedText,
        (value) async => await cryptoService.decryptString(secretKey, value),
      );

  Future<String?> _executeIfNotEmpty(
    String? data,
    Future<String> Function(String) operation,
  ) async {
    if (data == null || data.isEmpty) return null;
    return await operation(data);
  }
}
