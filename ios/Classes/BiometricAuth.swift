//
//  BiometricAuth.swift
//  BiometricAuth
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.
//

import UIKit
import LocalAuthentication
class BiometricAuth: NSObject {
    var loginReason = "Logging in with Touch ID"
    static let username = "unique_id_user"
    static let unique_app = "biometric_available_in_app"

   func biometricType() -> BiometricType {
     let laContext = LAContext()
     var error: NSError?
     let evaluated = laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
     if let laError = error {
         print("laError - \(laError)")
         return .none
     }
     if #available(iOS 11.0, *) {
         if laContext.biometryType == .faceID { return .faceID }
         if laContext.biometryType == .touchID { return .touchID }
     } else {
         if (evaluated || (error?.code != LAError.touchIDNotAvailable.rawValue)) {
             return .touchID
         }
     }
     return .none
   }
   func isAvailableInThisApp() -> Bool {
       let isAvailable:Bool = UserDefaults.standard.bool(forKey: BiometricAuth.unique_app)
       return isAvailable;
   }
   func getIcon() -> String {
       if #available(iOS 11.3, *) {
           let touchMe = BiometricAuth()
                      switch touchMe.biometricType() {
                         case .faceID:
                           return "face_icon"
                         default:
                            return "touch_icon"
                         }
       }else{
          return "touch_icon"
       }
     
   }
   func canEvaluatePolicy() -> Bool {
      let context = LAContext()
     return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
   }


   func authenticateUser(completion: @escaping (String?) -> Void) {
     guard canEvaluatePolicy() else {
       completion("Touch ID not available")
       return
     }
     let context = LAContext()
     context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                            localizedReason: loginReason) { (success,
                                                             evaluateError) in
         let message: String
         if success {
         DispatchQueue.main.async {
           // User authenticated successfully, take appropriate action
           BiometricAuth.saveAvailibilityApp(active: true);
           completion(nil)
         }
       } else {
         BiometricAuth.saveAvailibilityApp(active: false);
         if #available(iOS 11.0, *) {
            switch evaluateError {
                   case LAError.authenticationFailed?:
                     message = "There was a problem verifying your identity."
                   case LAError.userCancel?:
                     message = "You pressed cancel."
                   case LAError.userFallback?:
                     message = "You pressed password."
                   case LAError.biometryNotAvailable?:
                     message = "Face ID/Touch ID is not available."
                   case LAError.biometryNotEnrolled?:
                     message = "Face ID/Touch ID is not set up."
                   case LAError.biometryLockout?:
                     message = "Face ID/Touch ID is locked."
                   default:
                     message = "Face ID/Touch ID may not be configured"
                   }
                  
                   completion(message)
         } else {
             message = "Face ID/not available"
             completion(message)
         }
       }
     }
   }
   static func saveAvailibilityApp(active:Bool) {
     //  UserDefaults.standard.set(active, forKey: BiometricAuth.unique_app)
       UserDefaults.standard.set(active, forKey: BiometricAuth.unique_app)
       UserDefaults.standard.synchronize()
   }

}
