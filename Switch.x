#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>
#include <dlfcn.h>
static NSString * const PREF_PATH = @"/var/mobile/Library/Preferences/net.mtvg.BacklightSwitch.plist";
static NSString * const kSwitchKey = @"BacklightIsOn";

@interface BacklightSwitch : NSObject <FSSwitchDataSource>
@end

@implementation BacklightSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id existBacklightIsOn = [dict objectForKey:kSwitchKey];
    BOOL backlightIsOn = existBacklightIsOn ? [existBacklightIsOn boolValue] : YES;
    return backlightIsOn ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    NSMutableDictionary *mutableDict = dict ? [[dict mutableCopy] autorelease] : [NSMutableDictionary dictionary];

    int (*SBSSpringBoardServerPort)() = (int (*)())dlsym(RTLD_DEFAULT, "SBSSpringBoardServerPort");
    int port = SBSSpringBoardServerPort();
    void (*SBDimScreen)(int _port,BOOL shouldDim) = (void (*)(int _port,BOOL shouldDim))dlsym(RTLD_DEFAULT, "SBDimScreen");
    void (*BKSDisplayServicesSetScreenBlanked)(BOOL blanked) = (void (*)(BOOL blanked))dlsym(RTLD_DEFAULT, "BKSDisplayServicesSetScreenBlanked");

    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
        case FSSwitchStateOn:
            [mutableDict setValue:@YES forKey:kSwitchKey];
            BKSDisplayServicesSetScreenBlanked(0);
            SBDimScreen(port,NO);
            break;
        case FSSwitchStateOff:
            [mutableDict setValue:@NO forKey:kSwitchKey];
            BKSDisplayServicesSetScreenBlanked(1);
            SBDimScreen(port,YES);
            break;
    }
    [mutableDict writeToFile:PREF_PATH atomically:YES];
    notify_post("net.mtvg.BacklightSwitch.settingschanged");
}

@end
