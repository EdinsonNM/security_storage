//
//  SecureStorage.swift
//  Pods
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.
//

import Foundation

/*
    author: Raul Samuel Quispe Mamani
    **strong * (Table of contents)**
    this class is a facade pattern to use a SecureStorage
    and current use one object Biometric
 */

@objc
public class SecureStorage: NSObject,Parceable {
    @objc public class func getPasscodeForReactivateFlow(_ success: @escaping Success,_ errorType: @escaping ErrorType){
        Biometric.getPasscodeForReactivateFlow(success,errorType)
    }
    @objc public class func getIconString()-> String {
        return Biometric.getImageIconBiometric()
    }
    @objc public class func getPermission( _ success: @escaping Success,_ errorType: @escaping ErrorType) {
        Biometric.getPermission(success, errorType)
    }
    @objc public class func isAvailableInApp()->Bool {
        return Biometric.isAvailableInApp()
    }
    @objc public class func isAvailableBiometricBanner()->Bool{
        return Biometric.isAvailableBiometricBanner()
    }
    @objc public class func canAuthenticate() -> String {
        if Biometric.isBiometricAvailable() {
            return "Success"
        }else{
            return BiometricPrompt.ERROR_LOCKOUT.rawValue
        }
    }
    @objc public class func read(_ data:Dictionary<String, Any>,
                                 value: @escaping Value,
                                 errorType: @escaping ErrorType) {
        Biometric.readPasswordForService(serviceName: data["name"]! as! String,
                                                value: value,
                                                errorType: errorType)
    }
    @objc public class func delete(_ data:Dictionary<String, Any>) -> Bool {
        
        return Biometric.deletePassword(serviceName: data["name"]! as! String)
    }
    @objc public class func write(_ data:Dictionary<String, Any>, _ success: @escaping Success)  {
        Biometric.saveData(value: data["content"]! as! String,
                           identifierKey: data["name"]! as! String,
                           success)
    }
    @objc public class func initValues(_ data:String) {
        if Biometric.checkLoginForService("", serviceName: data,{ result in
                                            if result {
                                                print("No Init Storage")
                                            }else{
                                                print("Init Storage")
                                            }

                                          }, {error in
                                            if error != nil {

                                            }
                                          }) {

        }

    }
}

struct ResultData : Codable {
    let Success : String
    let ErrorHwUnavailable : String
    let ErrorNoBiometricEnrolled:String
    let ErrorNoHardware:String
    let ErrorUnknown:String
    
}
protocol Parceable {
    static func toJson(_ obj: ResultData) -> String
}
extension Parceable {
    static func toJson(_ obj: ResultData) -> String {
  
        do {
            let jsonData = try JSONEncoder().encode(obj)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        } catch { print(error) }
        return "asda"
    }
}

