//
//  Biometric.swift
//  BiometricAuth
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.
//

import UIKit
import Foundation
/*
    author: Raul Samuel Quispe Mamani
    **strong * (Table of contents)**
    this class is a facade pattern to use a Biometric authentication
    and current use two object LocalAuth and KeychainPasswordItem
 */
public typealias Result = (Bool) -> Void
public typealias Success = () -> Void
public typealias ErrorType = (NSError?) -> Void
public typealias Value = (String) -> Void
@objc
public class Biometric: NSObject {
    private var passwordItems: [KeychainPasswordItem] = []
    @objc public class func getPasscodeForReactivateFlow(_ success: @escaping Success,_ errorType: @escaping ErrorType) {
        let localAuth = LocalAuth()
        localAuth.getAuthorizationUser(result: success, errorType: errorType)
    }
    @objc public class func getPermission( _ success: @escaping Success,_ errorType: @escaping ErrorType) {
        let localAuth = LocalAuth()
        localAuth.getPermission(completion: { error in
            guard let currentError = error else {
                success()
                return
            }
            errorType(currentError)
        })
    }
    // MARK: UI Interface
    /*
     This function return if Touch or Face ID is available Policy
     */
    @objc public class func isBiometricAvailable() -> Bool {
        let touchMe = LocalAuth()
        return touchMe.canEvaluatePolicy()
    }
    /*
    This function return Touch or Face ID icon
     return two values:
     - face_icon or touch_icon
     you need setUp this images in assets module
    */
    @objc public class func getImageIconBiometric() -> String {
         let touchMe = LocalAuth()
         return touchMe.getIcon()
    }
 
    /*
          * This function receive two params for check review
          *
          * @param password A String for example  = "com.pe.pacifico"
          * @param  * @param password A String input for user
          * @param success A Completion Handler
          * @param errorMessagge(String?) A Completion Handler
        */
    @objc public class func checkLoginForService(_ password: String,
                                                 serviceName: String,
                                                 _ success: @escaping (Bool) -> Void,
                                                 _ errorMessagge: @escaping (String?) -> Void) -> Bool {
       
       let username = "unique_id_user"
       guard username == UserDefaults.standard.value(forKey: "username") as? String else {
        success(false)
        return false
       }
       
        do {
            let passwordItem = KeychainPasswordItem(service: serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            success(password == keychainPassword)
       } catch {
            errorMessagge(error.localizedDescription)
       }
      return false
     }
    /*
        * This function receive two params for save your password
        *
        * @param password A String for example  = "com.pe.pacifico"
        * @param  * @param password A String for example  = "com.pe.pacifico" A String for example  = "com.pe.pacifico"
        * @param success A Completion Handler
        * @param errorMessagge(String?) A Completion Handler
      */
    @objc public class func saveData(value:String,
                                     identifierKey:String,
                                     _ success: @escaping Success) {
        let localAuth = LocalAuth()
        localAuth.deleteData(identifierKey: identifierKey)
        localAuth.saveData(value: value, identifierKey: identifierKey)
        localAuth.saveDomainPolicy()
        success()
    }
    /*
      * This function receive one param for read your password and interact with you biometric
      *
      * @param serviceName A String for example  = "com.pe.pacifico"
        this function return your password biometric is available
     /// - parameter serviceName: is a String Value
    */
    @objc public class func readPasswordForService(serviceName:String, value: @escaping Value, errorType: @escaping ErrorType) {
        let localAuth = LocalAuth()
        localAuth.isSameDomainPolicy(success: {result in
            if result == true {
                localAuth.readData(identifierKey: serviceName, value: value, errorType: errorType)
            }else{
                value(BiometricPrompt.ERROR_DENIED_PERMISSION.rawValue)
            }
            
        }, errorType: errorType)
    }
    /*
         * This function receive one param for read your password and interact with you biometric
         *
         * @param serviceName A String for example  = "com.pe.pacifico"
           this function return your password biometric is available
        /// - parameter serviceName: is a String Value
       */
    @objc public class func deletePassword(serviceName:String) -> Bool {
        let localAuth = LocalAuth()
        localAuth.saveAvailibilityApp(active: false)
        localAuth.deleteData(identifierKey: serviceName)
        return true
    }
    /*
         * This function return true if the app is biometric auth completed and available
         *
       */
    @objc public class func isAvailableInApp() -> Bool {
         let touchMe = LocalAuth()
        return touchMe.isAvailableInThisApp();
    }
     /*
             * This function return true if the app is BiometricBanner auth completed and available
             *
           */
    @objc public class func isAvailableBiometricBanner() -> Bool {
         let touchMe = LocalAuth()
         return touchMe.isAvailableBiometricBanner();
    }

}

