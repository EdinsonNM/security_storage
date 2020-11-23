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
