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
    static let username = "unique_id_user_pacifico"
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
    if biometricType() == .none {
        return false
    }else{
        return true
    }
//      let context = LAContext()
//      return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
   }
    func saveDomainPolicy(){
        let context = LAContext()
            context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        let defaults = UserDefaults.standard
       
        if #available(iOS 9.0, *) {
            defaults.set(context.evaluatedPolicyDomainState, forKey: "domainTouchID")
            defaults.synchronize()
        } else {
            // Fallback on earlier versions
        }
    }
    func isSameDomainPolicy()->Bool{
        let context = LAContext()
            context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

            let defaults = UserDefaults.standard
            let oldDomainState = defaults.object(forKey: "domainTouchID") as? Data
    

        if #available(iOS 9.0, *) {
            if let domainState = context.evaluatedPolicyDomainState, domainState == oldDomainState  {
                // Enrollment state the same
                print("nothing change")
                return true
            } else if(oldDomainState != nil){
                // Enrollment state changed
               
                return false
            }
        } else {
            // Fallback on earlier versions
        }

            // save the domain state for the next time
        if #available(iOS 9.0, *) {
            defaults.set(context.evaluatedPolicyDomainState, forKey: "domainTouchID")
        } else {
            // Fallback on earlier versions
        }
        return true
    }
    func authenticateUser(completion: @escaping (String?,BiometricPrompt) -> Void) {
        var biometricPrompt:BiometricPrompt = .ERROR_NONE
        let context = LAContext()
           
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: loginReason) { (success,
                                                                evaluateError) in
     
            let message: String
            if success {
            DispatchQueue.main.async {
              // User authenticated successfully, take appropriate action
              BiometricAuth.saveAvailibilityApp(active: true);
               completion(nil,.ERROR_NONE)
            }
          } else {
            BiometricAuth.saveAvailibilityApp(active: false);
            if #available(iOS 11.0, *) {
               
               switch evaluateError {
                      case LAError.authenticationFailed?:
                           message = "There was a problem verifying your identity."
                           biometricPrompt = .ERROR_FAILED
                       break
                      case LAError.userCancel?:
                           message = "You pressed cancel."
                           biometricPrompt = .ERROR_CANCELED
                       break
                      case LAError.userFallback?:
                           message = "You pressed password."
                           biometricPrompt = .ERROR_CANCELED
                       break
                      case LAError.biometryNotAvailable?:
                           message = "Face ID/Touch ID is not available."
                           biometricPrompt = .ERROR_DENIED_PERMISSION
                       break
                      case LAError.biometryNotEnrolled?:
                           message = "Face ID/Touch ID is not set up."
                           biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                       break
                      case LAError.biometryLockout?:
                           message = "Face ID/Touch ID is locked."
                           biometricPrompt = .ERROR_LOCKOUT
                       break
                      default:
                           message = "Face ID/Touch ID may not be configured"
                           biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                       
                      }
                     
                      completion(message,biometricPrompt)
            } else {
               message = "Face ID/not available"
               completion(message,BiometricPrompt.ERROR_NOT_BIOMETRIC_ENROLLED)
            }
          }
        }
    }

   func authenticateUserOld(completion: @escaping (String?,BiometricPrompt) -> Void) {
     guard canEvaluatePolicy() else {
//        let error:BiometricPrompt = nil
        completion("Touch ID not available",.ERROR_DENIED_PERMISSION)
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
            completion(nil,.ERROR_NONE)
         }
       } else {
         BiometricAuth.saveAvailibilityApp(active: false);
         if #available(iOS 11.0, *) {
            var biometricPrompt:BiometricPrompt = .ERROR_NONE
            switch evaluateError {
                   case LAError.authenticationFailed?:
                        message = "There was a problem verifying your identity."
                        biometricPrompt = .ERROR_FAILED
                    break
                   case LAError.userCancel?:
                        message = "You pressed cancel."
                        biometricPrompt = .ERROR_CANCELED
                    break
                   case LAError.userFallback?:
                        message = "You pressed password."
                        biometricPrompt = .ERROR_CANCELED
                    break
                   case LAError.biometryNotAvailable?:
                        message = "Face ID/Touch ID is not available."
                        biometricPrompt = .ERROR_DENIED_PERMISSION
                    break
                   case LAError.biometryNotEnrolled?:
                        message = "Face ID/Touch ID is not set up."
                        biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                    break
                   case LAError.biometryLockout?:
                        message = "Face ID/Touch ID is locked."
                        biometricPrompt = .ERROR_LOCKOUT
                    break
                   default:
                        message = "Face ID/Touch ID may not be configured"
                        biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                    
                   }
                  
                   completion(message,biometricPrompt)
         } else {
            message = "Face ID/not available"
            completion(message,BiometricPrompt.ERROR_NOT_BIOMETRIC_ENROLLED)
         }
       }
     }
   }
   static func saveAvailibilityApp(active:Bool) {
     //  UserDefaults.standard.set(active, forKey: BiometricAuth.unique_app)
       UserDefaults.standard.set(active, forKey: BiometricAuth.unique_app)
       UserDefaults.standard.synchronize()
   }
    func getPermission(completion: @escaping (String?,BiometricPrompt) -> Void){
    let context = LAContext()
    let resultPermission = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    guard resultPermission else {
       completion("Biometric not available",.ERROR_DENIED_PERMISSION)
      return
    }
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: "Son necesarios los datos biométricos para validar que eres tu.") { (success,
                                                            evaluateError) in
    let message: String
     if success {
        DispatchQueue.main.async {
          // User authenticated successfully, take appropriate action
          BiometricAuth.saveAvailibilityApp(active: true);
           completion(nil,.ERROR_NONE)
        }
      } else {
        BiometricAuth.saveAvailibilityApp(active: false);
        if #available(iOS 11.0, *) {
           var biometricPrompt:BiometricPrompt = .ERROR_NONE
           switch evaluateError {
                  case LAError.authenticationFailed?:
                       message = "There was a problem verifying your identity."
                       biometricPrompt = .ERROR_FAILED
                   break
                  case LAError.userCancel?:
                       message = "You pressed cancel."
                       biometricPrompt = .ERROR_DENIED_PERMISSION
                   break
                  case LAError.userFallback?:
                       message = "You pressed password."
                       biometricPrompt = .ERROR_CANCELED
                   break
                  case LAError.biometryNotAvailable?:
                       message = "Face ID/Touch ID is Rejected."
                       biometricPrompt = .ERROR_DENIED_PERMISSION
                   break
                  case LAError.biometryNotEnrolled?:
                       message = "Face ID/Touch ID is not set up."
                       biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                   break
                  case LAError.biometryLockout?:
                       message = "Face ID/Touch ID is locked."
                       biometricPrompt = .ERROR_LOCKOUT
                   break
                  default:
                       message = "Face ID/Touch ID may not be configured"
                       biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                   
                  }
                 
                  completion(message,biometricPrompt)
        } else {
           message = "Face ID/not available"
           completion(message,BiometricPrompt.ERROR_NOT_BIOMETRIC_ENROLLED)
        }
      }
    }
   }
}

