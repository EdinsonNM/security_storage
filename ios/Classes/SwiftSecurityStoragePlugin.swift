import Flutter
import UIKit

public class SwiftSecurityStoragePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "security_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftSecurityStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case "read":
            if let args = call.arguments as? Dictionary<String,Any> {
                
                result(SecureStorage.read(args))
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
                    result("Success")
                },{ biometricPrompt in
                    result(FlutterError( code: biometricPrompt!,
                                         message: "",
                                         details: "" ))
                    
                })
            }
            break;
        case "init":
            if let args = call.arguments as? Dictionary<String,Any> {
                SecureStorage.initValues(args["name"]! as! String)
            }
            break;
        case "canAuthenticate":
            result(SecureStorage.canAuthenticate())

            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}

