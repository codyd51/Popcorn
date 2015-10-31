#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CDTContextHostProvider.h"
#include "InspCWrapper.m"
#include "POPContentView.h"

#define kTweakName @"Popcorn"
#ifdef DEBUG
    #define NSLog(FORMAT, ...) NSLog(@"[%@: %s - %i] %@", kTweakName, __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])
#else
    #define NSLog(FORMAT, ...) do {} while(0)
#endif


#define kContentViewTag 76326766

@interface SBIconController (POPExtensions)
@property (nonatomic, retain, setter=pop_setPoppedBundleID:) NSString* pop_poppedBundleID;
-(void)pop_popIconViewFromGestureRecognizer:(UIGestureRecognizer*)gestureRec;
-(void)pop_popIconView:(SBIconView*)iconView;
-(void)pop_unpop:(UIButton*)sender;
-(void)pop_actuatePopSimulateIfNecessary;
@end

UIView* contextHostView;

%hook SBIconController
-(void)_handleShortcutMenuPeek:(UILongPressGestureRecognizer*)rec {
    %orig;

    SBIconView* target = (SBIconView*)rec.view;

    if (rec.state == UIGestureRecognizerStateBegan || !contextHostView) {
        contextHostView = [[CDTContextHostProvider sharedInstance] hostViewForApplicationWithBundleID:target.icon.applicationBundleID];
    }

    NSArray* touches = MSHookIvar<NSArray*>(rec, "_touches");
    UITouch* touch = [touches firstObject];
    CGFloat pressure = MSHookIvar<CGFloat>(touch, "_previousPressure");
    NSLog(@"rec.pressure: %f", pressure); 

    if (pressure > 900) {
        [self pop_popIconView:target];
    }
}
%new
-(void)pop_popIconViewFromGestureRecognizer:(UIGestureRecognizer*)gestureRec {
    SBIconView* view = (SBIconView*)gestureRec.view;
    [[CDTContextHostProvider sharedInstance] launchSuspendedApplicationWithBundleID:view.icon.applicationBundleID];
    [self pop_popIconView:view];
}
static int invocationAttempts = 0;
%new 
-(void)pop_popIconView:(SBIconView*)iconView {
    if (![iconView.icon isKindOfClass:%c(SBApplicationIcon)]) return;
    //invocationAttempts++;
    BOOL isiOS9 = NO;
    if ([[%c(SBIconController) sharedInstance] respondsToSelector:@selector(_canRevealShortcutMenu)]) {
        isiOS9 = YES;
    }
    if (isiOS9) {
        if ([[%c(SBIconController) sharedInstance] _canRevealShortcutMenu]) {
            [[%c(SBIconController) sharedInstance] _revealMenuForIconView:iconView presentImmediately:YES];
        }
    }

    contextHostView = [[CDTContextHostProvider sharedInstance] hostViewForApplicationWithBundleID:iconView.icon.applicationBundleID];
    if (!contextHostView) {
        //[[[UIAlertView alloc] initWithTitle:@"Uh-oh!" message:@"Something funny is going on!\nThe app was not alive in the background." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (isiOS9) {
                [[%c(SBIconController) sharedInstance] _dismissShortcutMenuAnimated:NO completionHandler:nil];
            }

            if (invocationAttempts >= 5) {
                //give up
                [[[UIAlertView alloc] initWithTitle:@"Popcorn" message:@"There was an issue opening this app.\nPlease ensure the app is open in the background and try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                //reset invocation attempts for next use
                invocationAttempts = 0;
                return;
            }
            else {
                [self pop_popIconView:iconView];
                invocationAttempts++;
            }
        });
        return;
    }
    //success! decrement invocation attempts
    invocationAttempts = 0;

    void(^completion)(void) = ^(void){
        UIView* keyWindow = [[[%c(SBIconController) sharedInstance] _currentFolderController] contentView];
        if ([keyWindow viewWithTag:kContentViewTag]) return;

        [self pop_actuatePopSimulateIfNecessary];

        POPContentView* contentView = [[POPContentView alloc] initWithFrame:keyWindow.frame contextHostView:contextHostView];
        contentView.tag = kContentViewTag;
        [keyWindow addSubview:contentView];

        [contentView fadeBlurIn];
        [contentView presentMainContent];

        self.pop_poppedBundleID = iconView.icon.applicationBundleID;
    };
    
    if (isiOS9) {
        [[%c(SBIconController) sharedInstance] _dismissShortcutMenuAnimated:NO completionHandler:^(BOOL finished){
            completion();
        }];
    }
    else {
        completion();
    }
}
%new
-(void)pop_unpop:(UIButton*)sender {
    UIView* keyWindow = [[[%c(SBIconController) sharedInstance] _currentFolderController] contentView];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        while ([keyWindow viewWithTag:kContentViewTag].alpha != 0.0) {
            [keyWindow viewWithTag:kContentViewTag].alpha = 0.0;
        }
    } completion:^(BOOL finished){
        UIView* keyWindow = [[[%c(SBIconController) sharedInstance] _currentFolderController] contentView];
        while ([keyWindow viewWithTag:kContentViewTag]) {
            [[keyWindow viewWithTag:kContentViewTag] removeFromSuperview];
        }
        [[CDTContextHostProvider sharedInstance] stopHostingForBundleID:sender.accessibilityHint];

        self.pop_poppedBundleID = nil;
    }];
}
%new
-(void)pop_actuatePopSimulateIfNecessary {
    //if device is force touch enabled, actuate pop
    if ([[UIDevice currentDevice] respondsToSelector:@selector(_tapticEngine)]) {
        UITapticEngine *tapticEngine = [UIDevice currentDevice]._tapticEngine;
        if (tapticEngine) {
            [tapticEngine actuateFeedback:UITapticEngineFeedbackPop];
        }
        else {
            typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);
            //vibrate
            NSMutableArray* vPattern = [NSMutableArray array];
            [vPattern addObject:[NSNumber numberWithBool:YES]];
            [vPattern addObject:[NSNumber numberWithInt:100]];
            NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };

            vibratePointer vibrate;
            void *handle = dlopen(0, 9);
            *(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
            vibrate(kSystemSoundID_Vibrate, nil, vDict);
        }
    }
    else {
        typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);
        //vibrate
        NSMutableArray* vPattern = [NSMutableArray array];
        [vPattern addObject:[NSNumber numberWithBool:YES]];
        [vPattern addObject:[NSNumber numberWithInt:100]];
        NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };

        vibratePointer vibrate;
        void *handle = dlopen(0, 9);
        *(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
        vibrate(kSystemSoundID_Vibrate, nil, vDict);
    }
}
%new
-(void)pop_setPoppedBundleID:(NSString*)bundleID {
    objc_setAssociatedObject(self, @selector(pop_poppedBundleID), bundleID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(NSString*)pop_poppedBundleID {
    return objc_getAssociatedObject(self, @selector(pop_poppedBundleID));
}
%end

%hook SBUIController
-(BOOL)clickedMenuButton {
    %log;
    /*
    SBRootFolderController* currentFolderController = [[%c(SBIconController) sharedInstance] _currentFolderController];
    if (currentFolderController) {
        UIView* keyWindow = [currentFolderController contentView];
        if (keyWindow) {
            if ([keyWindow viewWithTag:kContentViewTag]) {
                //the user has Popcorn open
                UIButton* fakeButton = 
            }
        }
    }
    */
    NSString* poppedBundleID = [[%c(SBIconController) sharedInstance] pop_poppedBundleID];
    NSLog(@"poppedBundleID: %@", poppedBundleID);
    if (poppedBundleID && ![poppedBundleID isEqualToString:@""]) {
        NSLog(@"user had Popcorn open...");
        //the user has popcorn open
        UIButton* fakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fakeButton.accessibilityHint = poppedBundleID;
        [[%c(SBIconController) sharedInstance] pop_unpop:fakeButton];

        return YES;
    }
    
    NSLog(@"user did not have Popcorn open...");

    return %orig;
}
%end

%hook SBIconView
-(void)setIcon:(SBIcon*)icon {
    SBIconView* view = self;
    %orig;

    if (![view.icon isKindOfClass:%c(SBApplicationIcon)]) return;

    UISwipeGestureRecognizer* swipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:[%c(SBIconController) sharedInstance] action:@selector(pop_popIconViewFromGestureRecognizer:)];
    swipeRec.direction = UISwipeGestureRecognizerDirectionUp;
    [view addGestureRecognizer:swipeRec];
}
%end

static void loadPreferences() {
    CFPreferencesAppSynchronize(CFSTR("com.phillipt.popcorn"));

    //enabled = [(id)CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("com.phillipt.popcorn")) boolValue];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPreferences,
                                CFSTR("com.phillipt.popcorn/prefsChanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPreferences();
}