



// #import <stdio.h>
// #import <unistd.h>
// #import <string.h>
// #import "substrate.h"
// void mylog2(const char *mytxt) {

// 	const char *path = "/tmp/svc3log";
// 	FILE *p = fopen(path, "a");

// 	if (p) {
// 		char prognametxt[50];
// 		sprintf(prognametxt, "%s[%d]", getprogname(), getpid());

// 		char logtxt[strlen(mytxt) + 50];
// 		sprintf(logtxt,"%s %s\n", prognametxt, mytxt);
// 		fwrite(logtxt, strlen(logtxt), 1, p);
// 		fclose(p);
// 	}
// }

// #define NSLog(...) mylog2([[NSString stringWithFormat:__VA_ARGS__] UTF8String])




#import "SVCController.h"



static unsigned char decreaseCount = 0;
static unsigned char decreaseCount2 = 0;
static unsigned char numberOfVolumeDecreasesHold = 0;
static BOOL isVolumeKeyDown = NO;
static BOOL isVolumeDownKeyDown = NO;
static BOOL isVolumeUpKeyDown = NO;
static BOOL fastMute = NO;
static BOOL lockscreenVolume = NO;
static float firstPressVolumeStep = 1.0;
static BOOL volumeIncreased = NO;




static void settingsChanged() {

	[[SVCController sharedInstance] releaseObjects];
	[[objc_getClass("AVSystemController") sharedAVSystemController] changeActiveCategoryVolumeBy:0.0];
	[SVCController makeChangesSilently];

}

static void liveSettingsChanged() {

	[[SVCController sharedInstance] releaseObjects];
	[[objc_getClass("AVSystemController") sharedAVSystemController] changeActiveCategoryVolumeBy:0.0];

}

static void stepsChanged() {

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
	short volumeSteps = [defaults objectForKey:@"volumeSteps"] ? [[defaults objectForKey:@"volumeSteps"] intValue] : 16;
	[defaults release];
	[SVCController setVolumeSteps:volumeSteps];

}

static void fastMuteChanged() {

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
	fastMute = [defaults objectForKey:@"fastMute"] ? [[defaults objectForKey:@"fastMute"] boolValue] : NO;
	[defaults release];

}

static void lockscreenVolumeChanged() {

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
	lockscreenVolume = [defaults objectForKey:@"lockscreenVolume"] ? [[defaults objectForKey:@"lockscreenVolume"] boolValue] : NO;
	[defaults release];

}

static void firstPressVolumeStepChanged() {

	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
	firstPressVolumeStep = [defaults objectForKey:@"firstPressVolumeStep"] ? [[defaults objectForKey:@"firstPressVolumeStep"] floatValue] : 1.0;
	[defaults release];

}




%subclass SVCWindow : SBHUDWindow

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	UIView *subview = %orig;

	return [[SVCController sharedInstance] _viewFromTouchedView:subview atPoint:point];

}

%end




%hook SpringBoard

-(void)applicationDidFinishLaunching: (UIApplication *)app {

	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		fastMuteChanged();
		lockscreenVolumeChanged();
		firstPressVolumeStepChanged();

		[[SVCHelperController sharedInstance] licenseCheck];

	});

}

-(void)_updateHomeScreenPresenceNotification:(id)notification {

	%orig;
	if ([SVCController isUIPresent])
		[[SVCController sharedInstance] handleHomeScreenPresence];

}

%end




%hook SBSystemGestureManager


-(BOOL)isGestureWithTypeAllowed:(unsigned long long)type {

	if ([SVCController isUIPresent] && ((UIWindow *)[[SVCController sharedInstance] valueForKey:@"_window"]).tag == 10 && type == 21)
		return NO;

	return %orig;
}

%end




%hook SBVolumeControl

-(void)increaseVolume {

	%orig;
	volumeIncreased = YES;

	decreaseCount = decreaseCount2 = 0;

	if ([SVCController isUIPresent])
		[[SVCController sharedInstance] increaseVolume];

}

-(void)decreaseVolume {

	%orig;
	volumeIncreased = NO;

	if (decreaseCount >= 250 || decreaseCount2 >= 250)
		decreaseCount = decreaseCount2 = 0;
	decreaseCount ++;

	if ([SVCController isUIPresent])
		[[SVCController sharedInstance] decreaseVolume];

}

-(void)handleVolumeButtonWithType:(long long)type down:(BOOL)isDown {

	// 102 Volume up
	// 103 Volume down

	%orig;

	if (type == 102 || type == 103) {
		if (isDown)
			isVolumeKeyDown = YES;
		else
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ isVolumeKeyDown = NO; });
	}

	if (type == 102) {

		if (isDown)
			isVolumeUpKeyDown = YES;
		else
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ isVolumeUpKeyDown = NO; });

	}
	else if (type == 103) {
		if (isDown)
			isVolumeDownKeyDown = YES;
		else
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ isVolumeDownKeyDown = NO; numberOfVolumeDecreasesHold = 0; });
	}

	if ((type == 102 || type == 103)) {
		[[SVCController sharedInstance ] handleVolumeButtonWithType:type down:isDown];
	}
	
}

-(float)volumeStepUp {

	return [SVCController volumeStep];

}

-(float)volumeStepDown {
	
	return [SVCController volumeStep];

}

+(BOOL)_isVolumeChangeAllowedForState:(id)state error:(NSError *)error {

	if (lockscreenVolume && [[objc_getClass("SBLockScreenManager") sharedInstance] isLockScreenActive])
		return YES;

	return %orig;

}

%end




%hook MPVolumeController

-(void)volumeControllerDataSource:(id)source didChangeVolume:(float)volume {

	if (lockscreenVolume && [[objc_getClass("SBLockScreenManager") sharedInstance] isLockScreenActive] && isVolumeKeyDown && (![[[objc_getClass("SBLockScreenManager") sharedInstance] valueForKey:@"_isScreenOn"] boolValue] || ([SVCController isUIPresent] && ((UIWindow *)[[SVCController sharedInstance] valueForKey:@"_window"]).backgroundColor == [UIColor blackColor]))) {

		[[objc_getClass("AVSystemController") sharedAVSystemController] getActiveCategoryVolume:&volume andName:nil];

		[[SVCController sharedInstance] setIsRingerHUD:NO];
		[[SVCController sharedInstance] updateVolumeLevel:volume];
		[[SVCController sharedInstance] presentUI];

	}

	%orig;

}

%end




%hook SBElasticVolumeViewController

-(BOOL)_canShowWhileLocked {

	if (lockscreenVolume)
		return YES;

	return %orig;

}

-(void)updateVolumeLevel:(float)volume {

	[[objc_getClass("AVSystemController") sharedAVSystemController] getActiveCategoryVolume:&volume andName:nil];

	[[SVCController sharedInstance] setIsRingerHUD:NO];
	[[SVCController sharedInstance] updateVolumeLevel:volume];
	[[SVCController sharedInstance] presentUI];

	%orig;

}

-(void)_createHapticFeedbackEngines {

	if ([[UIDevice currentDevice] _feedbackSupportLevel])
		%orig;

}

%end


%hook SBRingerHUDViewController

-(BOOL)_canShowWhileLocked {

	if (lockscreenVolume)
		return YES;

	return %orig;

}

-(void)setVolume:(float)volume animated:(BOOL)animated forKeyPress:(BOOL)pressed {

	[[objc_getClass("AVSystemController") sharedAVSystemController] getVolume:&volume forCategory:@"Ringtone"];

	if (animated) {
		[[SVCController sharedInstance] setIsRingerHUD:YES];
		[[SVCController sharedInstance] updateVolumeLevel:volume];
		[[SVCController sharedInstance] presentUI];
	}

	%orig;

}

-(void)setRingerSilent:(BOOL)silent {

	%orig;
	[[SVCController sharedInstance] setRingerSilent:silent];

}

-(void)presentForMuteSwitch:(BOOL)mute {

	%orig;
	[[SVCController sharedInstance] presentForMuteSwitch:mute];
	[[SVCController sharedInstance] setIsRingerHUD: YES];

	if (mute) {
		[[SVCController sharedInstance] updateVolumeLevel:[self volume]];
		[[SVCController sharedInstance] presentUI];
	}

}

%end




%hook _SBHUDHostViewController

- (void)viewWillTransitionToSize: (CGSize)size withTransitionCoordinator: (_UIViewControllerTransitionCoordinator *)coordinator {

	%orig;

	long long orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
	[[SVCController sharedInstance] reorientUIForOrientation:orientation withAnimationDuration:[coordinator transitionDuration]];

}

%end




%hook AVSystemController

-(BOOL)changeActiveCategoryVolume:(BOOL)change {
	// iOS 14
	// Step value fix

	if (isVolumeDownKeyDown && !volumeIncreased)
		decreaseCount2 ++;

	if (decreaseCount2 > decreaseCount) {
		decreaseCount2 = decreaseCount = 0;
		return YES;
	}
	
	if (isVolumeUpKeyDown) {
		[self changeActiveCategoryVolumeBy:[SVCController volumeStep]];
		return YES;
	}
	else if (isVolumeDownKeyDown) {
		[self changeActiveCategoryVolumeBy:-[SVCController volumeStep]];
		return YES;
	}

	return %orig;

}

-(BOOL)changeActiveCategoryVolumeBy:(float)volume {

	if (![SVCController isUIPresent])
		volume *= firstPressVolumeStep;

	// Fast mute feature
	if (fastMute) {
		if (isVolumeDownKeyDown && volume < -0.000001) {
			numberOfVolumeDecreasesHold ++;
		}
		if (numberOfVolumeDecreasesHold > 5) {
			numberOfVolumeDecreasesHold = 0;
			volume = -1.0;
		}
	}

	if (![objc_getClass("AXCustomContent") class] && isVolumeDownKeyDown) {
		// iOS 13
		// Step values fix

		if (volume < -0.000001)
			decreaseCount2 ++;

		if (decreaseCount2 > decreaseCount) {
			decreaseCount2 = decreaseCount = 0;
			return YES;
		}

	}

	return %orig;

}

%end




%hook SBHUDWindow

-(UIWindow *)initWithDebugName:(NSString *)name {

	UIWindow *window = %orig;
	
	if ([name isEqualToString:@"HUDWindow"])
		[window setAlpha:0.0];

	return window;

}

%end





%ctor {

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&settingsChanged, CFSTR("eu.midkin.smartvolumecontrol3.settingschanged"), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&liveSettingsChanged, CFSTR("eu.midkin.smartvolumecontrol3.livesettingschanged"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&stepsChanged, CFSTR("eu.midkin.smartvolumecontrol3.stepschanged"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&fastMuteChanged, CFSTR("eu.midkin.smartvolumecontrol3.fastmutechanged"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&lockscreenVolumeChanged, CFSTR("eu.midkin.smartvolumecontrol3.lockscreenvolumechanged"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&firstPressVolumeStepChanged, CFSTR("eu.midkin.smartvolumecontrol3.firstpressvolumestepchanged"), NULL, 0);

}





