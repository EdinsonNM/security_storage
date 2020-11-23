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
   
    
    @objc public class func canAuthenticate() -> String {
        
//        let result = ResultData(Success: "true",
//                                ErrorHwUnavailable: "noerror",
//                                ErrorNoBiometricEnrolled: "asd",
//                                ErrorNoHardware: "asd",
//                                ErrorUnknown: "asd")
        if Biometric.isBiometricAvailable() {
            return "Success"
        }else{
            return "ErrorUnsupported"
        }
//        return self.toJson(result)
        
    }
    @objc public class func read(_ data:Dictionary<String, Any>) -> String {
        return Biometric.readPasswordForService(serviceName: data["name"]! as! String)
    }
    @objc public class func delete(_ data:Dictionary<String, Any>) -> String {
        Biometric.deletePassword(serviceName: data["name"]! as! String)
        return ""
    }
    @objc public class func write(_ data:Dictionary<String, Any>) -> String {
        Biometric.savePasswordForService(password: data["content"]! as! String, serviceName: data["name"]! as! String, {
           
        }, { error in
            print(error?.description)
            
        })
        return ""
    }
    @objc public class func initValues(_ data:String) {
        print(data)
        if Biometric.checkLoginForService("", serviceName: data,
                                          { result in
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
            // and decode it back
//            let decodedSentences = try JSONDecoder().decode([ResultData].self, from: jsonData)
//            print(decodedSentences)
        } catch { print(error) }
        return "asda"
    }
}

/* prompt
 'title': title,
       'subtitle': subtitle,
       'description': description,
       'negativeButton': negativeButton,
       'confirmationRequired': confirmationRequired,
 */
/*
 'Success': CanAuthenticateResponse.success,
   'ErrorHwUnavailable': CanAuthenticateResponse.errorHwUnavailable,
   'ErrorNoBiometricEnrolled': CanAuthenticateResponse.errorNoBiometricEnrolled,
   'ErrorNoHardware': CanAuthenticateResponse.errorNoHardware,
   'ErrorUnknown': CanAuthenticateResponse.unknown,
   'ErrorSecurityUpdateRequired':
       CanAuthenticateResponse.errorSecurityUpdateRequired,
   'ErrorUnsupported': CanAuthenticateResponse.unsupported
 
 */
