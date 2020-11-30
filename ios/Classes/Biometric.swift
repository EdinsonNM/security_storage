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
    and current use two object BiometricAuth and KeychainPasswordItem
 */
@objc
public class Biometric: NSObject {
    private var passwordItems: [KeychainPasswordItem] = []
    
    // MARK: UI Interface
    /*
     This function return if Touch or Face ID is available Policy
     */
    @objc public class func isBiometricAvailable() -> Bool {
        let touchMe = BiometricAuth()
        return touchMe.canEvaluatePolicy()
    }
    /*
    This function return Touch or Face ID icon
     return two values:
     - face_icon or touch_icon
     you need setUp this images in assets module
    */
    @objc public class func getImageIconBiometric() -> String {
         let touchMe = BiometricAuth()
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
    @objc public class func checkLoginForService(_ password: String, serviceName: String,_ success: @escaping (Bool) -> Void,_ errorMessagge: @escaping (String?) -> Void) -> Bool {
       
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
    @objc public class func savePasswordForService(password:String,
                                                   serviceName:String, _ success: @escaping () -> Void,_ errorMessagge: @escaping (String?) -> Void) {
        let touchMe = BiometricAuth()
             touchMe.authenticateUser() { message,biometricPrompt in
                if biometricPrompt != .ERROR_NONE {
                    errorMessagge(biometricPrompt.rawValue)
             } else {
                 do {
                            let passwordItem = KeychainPasswordItem(service: serviceName,
                                                                    account: BiometricAuth.username,
                                                                    accessGroup: KeychainConfiguration.accessGroup)
                            try passwordItem.savePassword(password)
                            success()
                        }catch{
                            errorMessagge(biometricPrompt.rawValue)
                            
                        }
             }
           }
       
       
    }
    /*
      * This function receive one param for read your password and interact with you biometric
      *
      * @param serviceName A String for example  = "com.pe.pacifico"
        this function return your password biometric is available
     /// - parameter serviceName: is a String Value
    */
    @objc public class func readPasswordForService(serviceName:String) -> String {
        do {
          let passwordItem = KeychainPasswordItem(service: serviceName,
                                                  account: BiometricAuth.username,
                                                  accessGroup: KeychainConfiguration.accessGroup)
          let keychainPassword = try passwordItem.readPassword()
          return keychainPassword
        } catch {
           return "null"
        }
    }
    /*
         * This function receive one param for read your password and interact with you biometric
         *
         * @param serviceName A String for example  = "com.pe.pacifico"
           this function return your password biometric is available
        /// - parameter serviceName: is a String Value
       */
    @objc public class func deletePassword(serviceName:String) -> Bool {
        do {
          let passwordItem = KeychainPasswordItem(service: serviceName,
                                                  account: BiometricAuth.username,
                                                  accessGroup: KeychainConfiguration.accessGroup)
          try passwordItem.deleteItem()
          BiometricAuth.saveAvailibilityApp(active: false)
          return true
        } catch {
           return false
        }
    }
    /*
         * This function return true if the app is biometric auth completed and available
         *
       */
    @objc public class func isAvailableInApp() -> Bool {
         let touchMe = BiometricAuth()
        return touchMe.isAvailableInThisApp();
    }
 
}

