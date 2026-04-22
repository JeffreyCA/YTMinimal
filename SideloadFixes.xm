#import <Foundation/Foundation.h>
#import <Security/Security.h>

// Derived from https://github.com/dayanch96/YTLite/blob/main/Sideloading.x

@interface SSOKeychainHelper : NSObject
@end

@interface SSOKeychainCore : NSObject
@end

%group gSideload

static NSString *accessGroupID(void) {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: @"bundleSeedID",
        (__bridge id)kSecAttrService: @"",
        (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
    };
    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    }
    if (status != errSecSuccess) {
        return nil;
    }
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)kSecAttrAccessGroup];
    if (result) CFRelease(result);
    return accessGroup;
}

// YouTube 18.13.2+
%hook SSOKeychainHelper
+ (NSString *)accessGroup { return accessGroupID(); }
+ (NSString *)sharedAccessGroup { return accessGroupID(); }
%end

// YouTube 17.33.2+
%hook SSOKeychainCore
+ (NSString *)accessGroup { return accessGroupID(); }
+ (NSString *)sharedAccessGroup { return accessGroupID(); }
%end

%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSURL *documentsURL = [[self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig;
}
%end

%end

%ctor {
    BOOL isAppStoreApp = [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] appStoreReceiptURL].path];
    if (!isAppStoreApp) {
        %init(gSideload);
    }
}
