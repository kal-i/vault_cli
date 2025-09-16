import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  CryptoService({
    FlutterSecureStorage? secureStorage,
    int pbkdf2Iterations = 200_000,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _pbkdf2Iterations = pbkdf2Iterations;

  final FlutterSecureStorage _secureStorage;
  final int _pbkdf2Iterations;
  final _rng = Random.secure();
  final _aesGcm = AesGcm.with256bits();

  /// Derives a PBKDF2 key and returns it as a [SecretKey]
  Future<SecretKey> deriveKey(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pbkdf2Iterations,
      bits: 256,
    );

    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  /// Encrypt a string using AES-GCM
  /// Returns a base64 encoded string: nonce:ciphertext
  Future<String> encryptString(SecretKey key, String plainText) async {
    print('key: $key - encryptedData: $plainText');
    final nonce = _generateNonce();
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
      nonce: nonce,
    );
    print('nonce: $nonce - secretBox: $secretBox');

    // Store nonce + cipherText + mac together
    final combined = {
      'nonce': base64Encode(secretBox.nonce),
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    };

    print('combined: $combined');

    return jsonEncode(combined);
  }

  /// Decrypt a previously encrypted string using AES-GCM
  Future<String> decryptString(SecretKey key, String encryptedData) async {
    print('key: $key - encryptedData: $encryptedData');
    final decoded = jsonDecode(encryptedData);
    print('decoded: $decoded');
    final nonce = base64Decode(decoded['nonce']);
    final cipherText = base64Decode(decoded['cipherText']);
    final mac = Mac(base64Decode(decoded['mac']));
    print('nonce: $nonce - cipherText: $cipherText - mac: $mac');

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    print('secretBox: $secretBox');

    final clearText = await _aesGcm.decrypt(secretBox, secretKey: key);
    print('clearText: $clearText');

    return utf8.decode(clearText);
  }

  /// Generate a random 12-byte nonce
  List<int> _generateNonce() => _generate(length: 12);

  /// Generate a random salt for PBKDF2
  List<int> generateSalt({int length = 16}) => _generate(length: length);

  List<int> _generate({required int length}) =>
      List<int>.generate(length, (_) => _rng.nextInt(256));

  /// Converts bytes to base64 string for storage
  String bytesToBase64(List<int> bytes) => base64Encode(bytes);

  /// Converts base64 string back to bytes
  List<int> base64ToBytes(String data) => base64Decode(data);
}
