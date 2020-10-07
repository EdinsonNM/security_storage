import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SecurityStorage');
enum CanAuthenticateResponse {
  success,
  errorHwUnavailable,
  errorNoBiometricEnrolled,
  errorNoHardware,
  unsupported,
  unknown,
  errorSecurityUpdateRequired
}

const _canAuthenticateMapping = {
  'Success': CanAuthenticateResponse.success,
  'ErrorHwUnavailable': CanAuthenticateResponse.errorHwUnavailable,
  'ErrorNoBiometricEnrolled': CanAuthenticateResponse.errorNoBiometricEnrolled,
  'ErrorNoHardware': CanAuthenticateResponse.errorNoHardware,
  'ErrorUnknown': CanAuthenticateResponse.unknown,
  'ErrorSecurityUpdateRequired':
      CanAuthenticateResponse.errorSecurityUpdateRequired,
  'ErrorUnsupported': CanAuthenticateResponse.unsupported
};

enum AuthExceptionCode {
  userCanceled,
  unknown,
  timeout,
  negativeButton,
  lockout,
  lockoutPermanent
  failed
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
  'Failed': AuthExceptionCode.failed
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
    }
    return CanAuthenticateResponse.unsupported;
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

  Future<String> read() =>
      _transformErrors(_channel.invokeMethod<String>('read', <String, dynamic>{
        'name': this.name,
        'androidPromptInfo': androidPromptInfo._toJson()
      }));

  Future<bool> delete() =>
      _transformErrors(_channel.invokeMethod<bool>('delete', <String, dynamic>{
        'name': this.name,
        'androidPromptInfo': androidPromptInfo._toJson()
      }));

  Future<void> write(String content) =>
      _transformErrors(_channel.invokeMethod('write', <String, dynamic>{
        'name': this.name,
        'content': content,
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
