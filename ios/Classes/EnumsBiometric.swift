//
//  EnumsBiometric.swift
//  BiometricAuth
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.

import UIKit
enum BiometricType {
    case none
    case touchID
    case faceID
    case unknown
}
enum BiometryState {
    case available
    case notAvailable
    case locked
}

enum BiometricPrompt:String {
    case ERROR_CANCELED = "UserCanceled"
    case ERROR_TIMEOUT = "Timeout"
    case ERROR_LOCKOUT = "Lockout"
    case ERROR_LOCKOUT_PERMANENT = "LockoutPermanent"
    case ERROR_NEGATIVE_BUTTON = "NegativeButton"
    case ERROR_FAILED = "Failed"
    case ERROR_NOT_INITIALIZED = "NotInitialized"
    case ERROR_KEY_PERMANENTLY_INVALIDATED = "KeyPermanentlyInvalidated"
    case ERROR_NOT_BIOMETRIC_ENROLLED = "NoBiometricEnrolled"
}
//ERROR_FINGERPRINT_NO_REGISTER
