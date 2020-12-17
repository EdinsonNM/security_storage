import Flutter
import UIKit
import LocalAuthentication
public class SwiftSecurityStoragePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "security_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftSecurityStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "read":
            if Biometric.isAvailableInApp() {
                if let args = call.arguments as? Dictionary<String,Any> {
                    let readResult = SecureStorage.read(args)
                    if readResult == "null" {
                        DispatchQueue.main.async {
                          // your code here
                            result(FlutterError( code: "KeyPermanentlyInvalidated",
                                                 message: "",
                                                 details: "" ))
                        }
                    }else{
                        result(readResult)
                    }
                    
                }
            }else{
                result("null")
                
            }
          
            break;
        case "delete":
            if let args = call.arguments as? Dictionary<String,Any> {
                result(SecureStorage.delete(args))
            }
            break;
        case "write":
            if let args = call.arguments as? Dictionary<String,Any> {
                SecureStorage.write(args,{
                   
                    DispatchQueue.main.async {
                      // your code here
                        result("Success")
                    }
                },{ biometricPrompt in
                    DispatchQueue.main.async {
                      // your code here
                        result(FlutterError( code: biometricPrompt!,
                                             message: "",
                                             details: "" ))
                    }
                    
                    
                })
            }
            break;
        case "init":
            if let args = call.arguments as? Dictionary<String,Any> {
                SecureStorage.initValues(args["name"]! as! String)
            }
            break;
        case "canAuthenticate":
            //Alway succes because don't need validate ios 11 is alway available biometric hardaware
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                result("Success")
            } else {
                result("DeniedPermission")
            }
            result( SecureStorage.canAuthenticate())
            
            break;
        case "getPermission":
            SecureStorage.getPermission({
                result("Success")
            }, { errorMessage in
                result(errorMessage)
            })
            break;
        case "isAvailableInApp":
            let resultValue = SecureStorage.isAvailableInApp()
            result(resultValue)
            break;
        case "getIconString":
            let resultValue = SecureStorage.getIconString()
            result(resultValue)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}

