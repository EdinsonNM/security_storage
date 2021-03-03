import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _logger = Logger('SecurityStorage');
enum CanAuthenticateResponse {
  success,
  errorHwUnavailable,
  errorNoBiometricEnrolled,
  errorNoHardware,
  unsupported,
  unknown,
  errorSecurityUpdateRequired,
  deniedPermission,
}

const _canAuthenticateMapping = {
  'Success': CanAuthenticateResponse.success,
  'ErrorHwUnavailable': CanAuthenticateResponse.errorHwUnavailable,
  'ErrorNoBiometricEnrolled': CanAuthenticateResponse.errorNoBiometricEnrolled,
  'ErrorNoHardware': CanAuthenticateResponse.errorNoHardware,
  'ErrorUnknown': CanAuthenticateResponse.unknown,
  'ErrorSecurityUpdateRequired':
      CanAuthenticateResponse.errorSecurityUpdateRequired,
  'ErrorUnsupported': CanAuthenticateResponse.unsupported,
  'DeniedPermission': CanAuthenticateResponse.deniedPermission,
};

enum AuthExceptionCode {
  userCanceled,
  unknown,
  timeout,
  negativeButton,
  lockout,
  lockoutPermanent,
  failed,
  notInitialized,
  keyPermanentlyInvalidated,
  noBiometricEnrolled,
  deniedPermission,
}

class AuthException implements Exception {
  AuthException(this.code, this.message);

  final AuthExceptionCode code;
  final String message;

  @override
  String toString() {
    return 'AuthException{code: $code, message: $message}';
  }
}

const _authErrorCodeMapping = {
  'UserCanceled': AuthExceptionCode.userCanceled,
  'Timeout': AuthExceptionCode.timeout,
  'Lockout': AuthExceptionCode.lockout,
  'LockoutPermanent': AuthExceptionCode.lockoutPermanent,
  'NegativeButton': AuthExceptionCode.negativeButton,
  'Failed': AuthExceptionCode.failed,
  'NotInitialized': AuthExceptionCode.notInitialized,
  'KeyPermanentlyInvalidated': AuthExceptionCode.keyPermanentlyInvalidated,
  'NoBiometricEnrolled': AuthExceptionCode.noBiometricEnrolled,
  'DeniedPermission': AuthExceptionCode.deniedPermission,
};

class AndroidPromptInfo {
  const AndroidPromptInfo({
    this.title = 'Authenticate to unlock data',
    this.subtitle,
    this.description,
    this.negativeButton = 'Cancel',
    this.confirmationRequired = true,
  })  : assert(title != null),
        assert(negativeButton != null),
        assert(confirmationRequired != null);

  final String title;
  final String subtitle;
  final String description;
  final String negativeButton;
  final bool confirmationRequired;

  static const defaultValues = AndroidPromptInfo();

  Map<String, dynamic> _toJson() => <String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'negativeButton': negativeButton,
        'confirmationRequired': confirmationRequired,
      };
}

class StorageInitOptions {
  StorageInitOptions({
    this.authenticationValidityDurationSeconds = 10,
    this.authenticationRequired = true,
  });

  final int authenticationValidityDurationSeconds;

  /// Whether an authentication is required. if this is
  /// false NO BIOMETRIC CHECK WILL BE PERFORMED! and the value
  /// will simply be save encrypted. (default: true)
  final bool authenticationRequired;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'authenticationValidityDurationSeconds':
            authenticationValidityDurationSeconds,
        'authenticationRequired': authenticationRequired,
      };
}

class SecurityStorage {
  static const MethodChannel _channel = const MethodChannel('security_storage');
  String name;
  AndroidPromptInfo androidPromptInfo;
  SecurityStorage(this.name, this.androidPromptInfo);

  static Future<CanAuthenticateResponse> canAuthenticate() async {
    if (Platform.isAndroid) {
      var result = await _channel.invokeMethod<String>('canAuthenticate');
      print(result);
      return _canAuthenticateMapping[result];
    }else{
      var result = await _channel.invokeMethod<String>('canAuthenticate');
      print(result);
      return _canAuthenticateMapping[result];
    }

    //return CanAuthenticateResponse.unsupported;
  }

  static Future<SecurityStorage> init(
    String name, {
    StorageInitOptions options,
    AndroidPromptInfo androidPromptInfo = AndroidPromptInfo.defaultValues,
  }) async {
    assert(name != null);
    try {
      _channel.invokeMethod<bool>(
        'init',
        {
          'name': name,
          'options': options?.toJson() ?? StorageInitOptions().toJson(),
        },
      );
      return SecurityStorage(
        name,
        androidPromptInfo,
      );
    } catch (e, stackTrace) {
      _logger.warning(
          'Error while initializing security storage.', e, stackTrace);
    }
    return null;
  }
  // Future<String> getIconString() =>
  //     _channel.invokeMethod<String>('getIconString');
  static Future<String> getIconString() async {

    var result = await _channel.invokeMethod<String>('getIconString');
    print(result);
    return result;

  }
  static Future<bool> isAvailableInApp()async{
    var result = await _channel.invokeMethod<bool>('isAvailableInApp');
    return result;
  }
  static Future<bool> isAvailableBiometricBanner()async{
    var result = await _channel.invokeMethod<bool>('isAvailableBiometricBanner');
    return result;
  }

  static Future<CanAuthenticateResponse> getPermission() async {

      var result = await _channel.invokeMethod<String>('getPermission');

      return _canAuthenticateMapping[result];
  }
  Future<String> read() async {
    final value = await _transformErrors(_channel.invokeMethod<String>('read', <String, dynamic>{
      'name': this.name,
      'androidPromptInfo': androidPromptInfo._toJson()
    }));
    if(value == null){
      return value;
    }else{
      var isNew = (value.length<=44) ? true : false;
      SecureTokenStorage().isLastVersion = isNew;
      if(isNew){
        SecureTokenStorage().Key32 = value;
        var key32 = SecureTokenStorage().Key32;
        final keyRandom = SecureTokenStorage.keyFromString(key32);
        final token = await SecureTokenStorage.readToken(keyRandom,'token');
        //return alway a randomKey or oldUser return Token Value
        return token;
      }else{
        return value;
      }

    }
  }
  Future<String> write(String content) async {
    final value = await _transformErrors(_channel.invokeMethod('write', <String, dynamic>{
      'name': this.name,
      'content': content,
      'androidPromptInfo': androidPromptInfo._toJson()
    }));
    return value;
  }

  Future<bool> delete() =>
      _transformErrors(_channel.invokeMethod<bool>('delete', <String, dynamic>{
        'name': this.name,
        'androidPromptInfo': androidPromptInfo._toJson()
      }));

  Future<T> _transformErrors<T>(Future<T> future) =>
      future.catchError((dynamic error, StackTrace stackTrace) {
        _logger.warning(
            'Error during plugin operation (details: ${error.details})',
            error,
            stackTrace);
        if (error is PlatformException) {
          return Future<T>.error(
            AuthException(
              _authErrorCodeMapping[error.code] ?? AuthExceptionCode.unknown,
              error.message,
            ),
            stackTrace,
          );
        }
        return Future<T>.error(error, stackTrace);
      });
}


class SecureTokenStorage {
  bool authenticationRequired = false;
  bool isLastVersion = true;
  String Key32;//Cipher Biometric Prompt para Android TokenRefresh Enroll
  static final SecureTokenStorage _singleton = SecureTokenStorage._internal();
  factory SecureTokenStorage() {
    return _singleton;
  }
  SecureTokenStorage._internal();
  static Key randomValue(){
    return Key.fromSecureRandom(32);
  }
  static Key keyFromString(String keyBase64){
    return Key.fromBase64(keyBase64);
  }
  static String encryptToken(Key key32,String plainText){

    final iv = IV.fromLength(16);
    final encrypting = Encrypter(AES(key32));
    final encrypted = encrypting.encrypt(plainText, iv: iv);
    return encrypted.base64 ;
  }
  static void saveData(Key key32, String value,String keyValue) async {
    if(key32 != null){
      final tokenEncrypted = SecureTokenStorage.encryptToken(key32,value);
      final _storage = FlutterSecureStorage();
      await _storage.write(key: keyValue, value: tokenEncrypted);
    }
  }
  static Future<String> readToken(Key key32,String keyValue) async {
    final _storage = FlutterSecureStorage();
    var token = await _storage.read(key: keyValue);
    final iv = IV.fromLength(16);
    final encrypting = Encrypter(AES(key32));
    final decrypted = encrypting.decrypt64(token,iv: iv);
    return decrypted;
  }

}