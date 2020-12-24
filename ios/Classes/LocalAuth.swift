//
//  BiometricAuth.swift
//  BiometricAuth
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.
//

import UIKit
import LocalAuthentication
class LocalAuth: NSObject {
    // MARK:- Static Values
    static let loginReason = "Son necesarios los datos biométricos para validar que eres tu."
    static let account = "uniqueIdUserPacifico"
    static let identifierApp = "pacificoSeguros"
    
    static let domainPolicyID = "domainBiometricID"
    // MARK:- Local Properties
    private let laContext = LAContext()
    // MARK:- Policy Functions
    func saveDomainPolicy(){
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        let defaults = UserDefaults.standard
        
        if #available(iOS 9.0, *) {
            defaults.set(laContext.evaluatedPolicyDomainState,
                         forKey: LocalAuth.domainPolicyID)
            defaults.synchronize()
        } else {
            // Fallback on earlier versions
        }
    }
    func isSameDomainPolicy()->Bool{
       
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        let defaults = UserDefaults.standard
        let oldDomainState = defaults.object(forKey: LocalAuth.domainPolicyID) as? Data

        if #available(iOS 9.0, *) {
            if let domainState = laContext.evaluatedPolicyDomainState, domainState == oldDomainState  {
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
            defaults.set(laContext.evaluatedPolicyDomainState, forKey: LocalAuth.domainPolicyID)
        }
        return true
    }
    // MARK:- CRUD Functions
    func saveData(value:String, identifierKey:String){
        do {
            let passwordItem = KeychainPasswordItem(service: identifierKey,
                                                    account: LocalAuth.account,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(value)
            print("Success")
        }catch{
            print("error")
        }
    }
    func deleteData(identifierKey:String){
        do {
            let passwordItem = KeychainPasswordItem(service: identifierKey,
                                                    account: LocalAuth.account,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.deleteItem()
            print("Success")
        }catch{
                print("error")
        }
    }
    func readData(identifierKey:String) -> String? {
        do {
            let passwordItem = KeychainPasswordItem(service: identifierKey,
                                                    account: LocalAuth.account,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainValue = try passwordItem.readPassword()
            return keychainValue
        }catch{
            return nil
        }
    }
    // MARK:- Biometric Functions
    func biometricType() -> BiometricType {
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
            if (evaluated || (error?.code != LAError.touchIDNotAvailable.rawValue)) { return .touchID }
        }
        return .none
    }
    func isAvailableInThisApp() -> Bool {
        let isAvailable:Bool = UserDefaults.standard.bool(forKey: LocalAuth.identifierApp)
        return isAvailable;
    }
    func getIcon() -> String {
        if #available(iOS 11.3, *) {
            let touchMe = LocalAuth()
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
    
    func authenticateUser(completion: @escaping (String?,BiometricPrompt) -> Void) {
        var biometricPrompt:BiometricPrompt = .ERROR_NONE
    
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: LocalAuth.loginReason) { (success,
                                                                evaluateError) in
            
            let message: String
            if success {
                DispatchQueue.main.async {
                    // User authenticated successfully, take appropriate action
                    self.saveAvailibilityApp(active: true);
                    completion(nil,.ERROR_NONE)
                }
            } else {
                self.saveAvailibilityApp(active: false);
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
    
    func saveAvailibilityApp(active:Bool) {
        //  UserDefaults.standard.set(active, forKey: BiometricAuth.unique_app)
        UserDefaults.standard.set(active, forKey: LocalAuth.identifierApp)
        UserDefaults.standard.synchronize()
    }
    
    func getPermission(completion: @escaping (NSError?) -> Void){
        var error: NSError?
        let resultPermission = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        guard resultPermission else {
            completion(error)
            return
        }
        laContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: LocalAuth.loginReason) { (success,evaluateError) in
            if evaluateError == nil {
                self.saveAvailibilityApp(active: true);
                completion(nil)
            } else {
                self.saveAvailibilityApp(active: false);
                completion(evaluateError! as NSError)
            }
        }
    }
}

