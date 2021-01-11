import Flutter
import UIKit
import LocalAuthentication
public class SwiftSecurityStoragePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "security_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftSecurityStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
        let success = "Success"
        switch call.method {
        case "read":
            if Biometric.isAvailableInApp() {
                if let args = call.arguments as? Dictionary<String,Any> {
                    SecureStorage.read(args,
                                       value: { value in
                                        let readResult:String = value
                                            if BiometricPrompt.ERROR_DENIED_PERMISSION.rawValue == readResult {
                                            result(FlutterError( code: "KeyPermanentlyInvalidated",
                                                                 message: "",
                                                                 details: "" ))
                                            }else{ 
                                                result(readResult)
                                            }
                                        
                                       }, errorType: {error in
                                        let biometricTypeError = SwiftSecurityStoragePlugin.convertErrorTo(error!)
                                      
                                            if biometricTypeError == BiometricPrompt.ERROR_LOCKOUT.rawValue {
                                     
                                                result(FlutterError( code: biometricTypeError,
                                                                     message: "",
                                                                     details: "" ))
                                            }else{
                                                result(FlutterError( code: biometricTypeError,
                                                                     message: "",
                                                                     details: "" ))
                                            }
                                       })
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
                    result(success)
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
            result(success)
            break;
        case "getPermission":
            SecureStorage.getPermission({
                result(success)
            }, { error in
                let biometricTypeError = SwiftSecurityStoragePlugin.convertErrorTo(error!)
                DispatchQueue.main.async{
                    if biometricTypeError == BiometricPrompt.ERROR_DENIED_PERMISSION.rawValue {
                        result(biometricTypeError)
                    }else if biometricTypeError == BiometricPrompt.ERROR_LOCKOUT.rawValue {
                        Biometric.getPasscodeForReactivateFlow({
                            result(success)
                        }, {error in
//                            let biometricTypeError = SwiftSecurityStoragePlugin.convertErrorTo(error!)
                            result(BiometricPrompt.ERROR_LOCKOUT.rawValue)
                        })
                        
                    }else{
                        result(FlutterError( code: biometricTypeError,
                                             message: "",
                                             details: "" ))
                    }
                }
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
    
    public static func convertErrorTo(_ evaluateError:NSError) -> String {
        var biometricPrompt:BiometricPrompt = .ERROR_NONE
        var message:String = ""
        if #available(iOS 11.0, *) {
            switch evaluateError {
            case LAError.authenticationFailed:
                message = "There was a problem verifying your identity."
                biometricPrompt = .ERROR_FAILED
                break
            case LAError.userCancel:
                message = "You pressed cancel."
                biometricPrompt = .ERROR_CANCELED
                break
            case LAError.userFallback:
                message = "You pressed password."
                biometricPrompt = .ERROR_LOCKOUT
                break
            case LAError.biometryNotAvailable:
                message = "Face ID/Touch ID is not available."
                biometricPrompt = .ERROR_DENIED_PERMISSION
                break
            case LAError.biometryNotEnrolled:
                message = "Face ID/Touch ID is not set up."
                biometricPrompt = .ERROR_NOT_BIOMETRIC_ENROLLED
                break
            case LAError.biometryLockout:
                message = "Face ID/Touch ID is locked."
                biometricPrompt = .ERROR_LOCKOUT
                break
            default:
                message = "Face ID/Touch ID may not be configured"
                biometricPrompt = .ERROR_CANCELED
            }
        }
        print(message)
        return biometricPrompt.rawValue
    }
}

