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
    @objc public class func getIconString()-> String {
        return Biometric.getImageIconBiometric()
    }
    @objc public class func getPermission(_ success: @escaping () -> Void,_ errorMessagge: @escaping (String?) -> Void) {
        Biometric.getPermission(success, errorMessagge)
    }
    @objc public class func isAvailableInApp()->Bool {
        return Biometric.isAvailableInApp()
    }
    @objc public class func canAuthenticate() -> String {
        if Biometric.isBiometricAvailable() {
            return "Success"
//            if Biometric.isAvailableInApp() {
//                return "Success"
//            }else{
//                return "ErrorUnsupported"
//            }
        }else{
            return "ErrorUnsupported"
        }
    }
    @objc public class func read(_ data:Dictionary<String, Any>) -> String {
        return Biometric.readPasswordForService(serviceName: data["name"]! as! String)
    }
    @objc public class func delete(_ data:Dictionary<String, Any>) -> Bool {
        
        return Biometric.deletePassword(serviceName: data["name"]! as! String)
    }
    @objc public class func write(_ data:Dictionary<String, Any>, _ success: @escaping () -> Void,_ errorMessagge: @escaping (String?) -> Void)  {
        Biometric.savePasswordForService(password: data["content"]! as! String, serviceName: data["name"]! as! String, success, errorMessagge)
        
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
    @objc public class func createAlert(_ success: @escaping (String) -> Void){
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let alert = UIAlertController(title: "Mi Espacio Pacifico", message: "Para usar Face ID o Touch ID\n debe autorizar su uso en configuraciones.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ir a configuraciones", style:  UIAlertAction.Style.default, handler: { action in
            if let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
//                success("ErrorUnsupported")
                success(BiometricPrompt.ERROR_NOT_BIOMETRIC_ENROLLED.rawValue)
                UIApplication.shared.openURL(url)
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.cancel, handler: { action in
            success(BiometricPrompt.ERROR_NOT_BIOMETRIC_ENROLLED.rawValue)
            
        }))

        rootViewController?.present(alert, animated: true, completion: nil)
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

