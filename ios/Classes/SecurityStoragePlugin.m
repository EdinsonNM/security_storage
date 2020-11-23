#import "SecurityStoragePlugin.h"
#if __has_include(<security_storage/security_storage-Swift.h>)
#import <security_storage/security_storage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "security_storage-Swift.h"
#endif

@implementation SecurityStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSecurityStoragePlugin registerWithRegistrar:registrar];
}
@end
