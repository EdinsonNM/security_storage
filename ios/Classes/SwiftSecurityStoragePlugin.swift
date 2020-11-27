import Flutter
import UIKit

public class SwiftSecurityStoragePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "security_storage", binaryMessenger: registrar.messenger())
        let instance = SwiftSecurityStoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //result("iOS " + UIDevice.current.systemVersion)
        
        switch call.method {
        case "read":
            if let args = call.arguments as? Dictionary<String,Any> {
                
                result(SecureStorage.read(args))
            }
            break;
        case "delete":
            if let args = call.arguments as? Dictionary<String,Any> {
                SecureStorage.delete(args)
                result("Success")
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
            if SecureStorage.canAuthenticate() == "Success" {
                result("Success")
            }else{
                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                let alert = UIAlertController(title: "Mi Espacio Pacifico", message: "Cambiar la configuración de \nFace ID o Touch ID.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ir a la configuración", style:  UIAlertAction.Style.default, handler: { action in
                    if let url = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
                        result("ErrorUnsupported")
                        UIApplication.shared.openURL(url)
                        
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.cancel, handler: { action in
                    result("ErrorUnsupported")
                    
                }))

                rootViewController?.present(alert, animated: true, completion: nil)
            }
            
            
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

