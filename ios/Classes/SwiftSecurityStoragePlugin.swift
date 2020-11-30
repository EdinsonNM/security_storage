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
            print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNN READ")
            if let args = call.arguments as? Dictionary<String,Any> {
                
                result(SecureStorage.read(args))
            }
            break;
        case "delete":
            print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNN delete")
            if let args = call.arguments as? Dictionary<String,Any> {
                result(SecureStorage.delete(args))
            }
            break;
        case "write":
            print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNN write")
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
            print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNN init")
            if let args = call.arguments as? Dictionary<String,Any> {
                SecureStorage.initValues(args["name"]! as! String)
            }
            break;
        case "canAuthenticate":
            let resultValue = SecureStorage.canAuthenticate()
            result(resultValue)
            print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNN canAuthenticate")
            result("Success")
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}

