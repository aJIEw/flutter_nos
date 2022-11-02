#import "FlutterNosPlugin.h"
#if __has_include(<flutter_nos/flutter_nos-Swift.h>)
#import <flutter_nos/flutter_nos-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_nos-Swift.h"
#endif

#import "NosFactory.h"

@implementation FlutterNosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[NosFactory alloc] initWithMessenger:registrar.messenger];
}
@end
