




// #import <stdio.h>
// #import <unistd.h>
// #import <string.h>
// #import "substrate.h"
// void mylog3(const char *mytxt) {

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

// #define NSLog(...) mylog3([[NSString stringWithFormat:__VA_ARGS__] UTF8String])




#include "SVCRootListController.h"




@implementation SVCRootListController {
	
	UIView *_logoContainerView;
	UIImageView *_logoView;
	UILabel *_version;

	WKWebView *_webview;

}

- (NSMutableArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [[NSMutableArray alloc] init];
		PSSpecifier *specifier = nil;

		NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"eu.midkin.smartvolumecontrol3"];
		unsigned char viewStyle = [defaults objectForKey:@"viewStyle"] ? [[defaults objectForKey:@"viewStyle"] unsignedCharValue] :0;
		unsigned char backgroundType = [defaults objectForKey:@"backgroundType"] ? [[defaults objectForKey:@"backgroundType"] unsignedCharValue] : 0;
		[defaults release];

		specifier = [[PSSpecifier alloc] initWithName:@"Presentation style" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"Choose among various presentation styles.\nTo provide the best visual experience, some settings may not be available for all presentation styles." forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Active style" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SVCPSListItemsController") cell:PSLinkListCell edit:nil];
		specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:3], [NSNumber numberWithUnsignedChar:4], [NSNumber numberWithUnsignedChar:5], [NSNumber numberWithUnsignedChar:6], [NSNumber numberWithUnsignedChar:7], [NSNumber numberWithUnsignedChar:8], [NSNumber numberWithUnsignedChar:9], [NSNumber numberWithUnsignedChar:10], nil];
		specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Classic", @"Big Notchy", @"Notchy", @"Pill", @"Disc", @"Minimal", @"Video Player", @"Windows10", @"Android", @"Triangle", @"Bottom Bar", nil] forKeys:specifier.values];
		specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Classic", @"Big Notchy", @"Notchy", @"Pill", @"Disc", @"Minimal", @"Video Player", @"Windows10", @"Android", @"Triangle", @"Bottom Bar", nil] forKeys:specifier.values];
		[specifier setProperty:@"viewStyle" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.livesettingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		if (viewStyle != 3 && viewStyle != 5 && viewStyle != 8 && viewStyle != 9) {

			specifier = [[PSSpecifier alloc] initWithName:@"Appearance" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
			[specifier setProperty:@"Adaptive style will automatically change background and elements coloring to match system's Dark/Light Mode.\nOLED style will force a true black background reducing battery consumption in OLED screens.\nGlass thickness will change the transparency of the background." forKey:@"footerText"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"Theming style" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SVCPSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:3], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Adaptive", @"Always Light", @"Always Dark", @"OLED", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Adaptive", @"Always Light", @"Always Dark", @"OLED", nil] forKeys:specifier.values];
			[specifier setProperty:@"backgroundType" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.livesettingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			if (backgroundType != 3) {

				specifier = [[PSSpecifier alloc] initWithName:@"Glass thickness" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
				specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:3], nil];
				specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Very Thin", @"Thin", @"Regular", @"Thick", nil] forKeys:specifier.values];
				specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Very Thin", @"Thin", @"Regular", @"Thick", nil] forKeys:specifier.values];
				[specifier setProperty:@"backgroundThickness" forKey:@"key"];
				[specifier setProperty:[NSNumber numberWithUnsignedChar:2] forKey:@"default"];
				[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
				[specifier setProperty:@"eu.midkin.smartvolumecontrol3.livesettingschanged" forKey:@"PostNotification"];
				[_specifiers addObject:specifier];
				[specifier release];

			}

		}

		specifier = [[PSSpecifier alloc] initWithName:@"Animations" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"Speaker steps +, will add more opacity steps to speaker icon waves.\nMax volume stretch, will add stretch animation at max volume." forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		if (viewStyle != 1 && viewStyle != 5 && viewStyle != 7 && viewStyle != 8 && viewStyle != 9) {
			specifier = [[PSSpecifier alloc] initWithName:@"Speaker steps +" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier setProperty:@"moreSpeakerOpacitySteps" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

		}

		specifier = [[PSSpecifier alloc] initWithName:@"Max volume stretch" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"maxVolumeAnimation" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];


		specifier = [[PSSpecifier alloc] initWithName:@"General features" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"1. Volume steps, are the steps between min and max volume level. You may enter values from 1 to 1000.\n2. Auto dismiss delay, is the number of seconds, before auto dismissing the HUD. 3. Fast mute, will decrease volume level to min, if volume down key is pressed and holded.\n4. Lockscreen volume, will allow HUD presentation and volume changes in lockscreen.\n5. Wake screen, will wake (light up) the screen when changing volume level.\n6. OLED Lockscreen will keep screen off, presenting only the volume HUD. It needs switched 4 and 5 opened!" forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"1. Volume steps: " target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
		[specifier setProperty:@"volumeSteps" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithShort:16] forKey:@"default"];
		[specifier setKeyboardType:4 autoCaps:0 autoCorrection:0];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.stepschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"2. Auto dismiss delay: " target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
		[specifier setProperty:@"autoDismissDelay" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithDouble:2.0] forKey:@"default"];
		[specifier setKeyboardType:8 autoCaps:0 autoCorrection:0];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"3. Fast mute" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"fastMute" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.fastmutechanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"4. Lockscreen volume" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"lockscreenVolume" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.lockscreenvolumechanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"5. Wake screen" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"wakeScreen" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"6. OLED Lockscreen" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"oledLockScreenVolume" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];


		if ([[UIDevice currentDevice] _feedbackSupportLevel]) {

			specifier = [[PSSpecifier alloc] initWithName:@"Haptic Feedback" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
			[specifier setProperty:@"Choose among several options for haptic feedback." forKey:@"footerText"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"Manage settings" target:self set:NULL get:NULL detail:NSClassFromString(@"SVCHapticListController") cell:PSLinkCell edit:Nil];
			[specifier setProperty:@"SVCHapticListController" forKey:@"customControllerClass"];
			[_specifiers addObject:specifier];
			[specifier release];

		}
		

		specifier = [[PSSpecifier alloc] initWithName:@"1st press features" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"1st press features, handle HUD behavior on 1st volume change." forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"HUD Visibility" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
		specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:1.0], [NSNumber numberWithDouble:0.75], [NSNumber numberWithDouble:0.5], [NSNumber numberWithDouble:0.0], nil];
		specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Full visibility(default)", @"3/4 visibility", @"1/2 visibility", @"Zero visibility", nil] forKeys:specifier.values];
		specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Full", @"3/4", @"1/2", @"Zero", nil] forKeys:specifier.values];
		[specifier setProperty:@"firstPressVisibility" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithDouble:1.0] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Volume steps" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
		specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.25], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:2.0], [NSNumber numberWithFloat:3.0], [NSNumber numberWithFloat:4.0], [NSNumber numberWithFloat:5.0], nil];
		specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1/4 step", @"1/2 step", @"1 step (default)", @"2 steps", @"3 steps", @"4 steps", @"5 steps", nil] forKeys:specifier.values];
		specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1/4 step", @"1/2 step", @"1 step", @"2 steps", @"3 steps", @"4 steps", @"5 steps", nil] forKeys:specifier.values];
		[specifier setProperty:@"firstPressVolumeStep" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithFloat:1.0] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.firstpressvolumestepchanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Auto dismiss delay" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
		specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.1], [NSNumber numberWithDouble:0.2], [NSNumber numberWithDouble:0.5], [NSNumber numberWithDouble:1.0], nil];
		specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1/10 delay", @"1/5 delay", @"1/2 delay", @"Default delay", nil] forKeys:specifier.values];
		specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1/10", @"1/5", @"1/2", @"Default", nil] forKeys:specifier.values];
		[specifier setProperty:@"firstPressDismissDelay" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithFloat:1.0] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		NSString *activatorLabel = nil;
		if (access("/usr/lib/libactivator.dylib", F_OK) == 0)
			activatorLabel = [[NSString alloc] initWithString:@"Enable Activator action for presenting the HUD."];
		else
			activatorLabel = [[NSString alloc] initWithString:@"Get Activator tweak to enable Activator action for presenting the HUD."];

		specifier = [[PSSpecifier alloc] initWithName:@"Activator Support" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:activatorLabel forKey:@"footerText"];
		[activatorLabel release];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Choose action" target:self set:NULL get:NULL detail:nil cell:PSLinkCell edit:nil];
		if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
			[specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"isContoller"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.presenthud" forKey:@"activatorListener"];
			[specifier setProperty:@"/System/Library/PreferenceBundles/LibActivator.bundle" forKey:@"lazy-bundle"];
			specifier->action = @selector(lazyLoadBundle:);
		}
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"License Handling" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"" forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"License info" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
		[specifier setButtonAction:@selector(purchaseNow)];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Learn More" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"Development status: Active." forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Follow me on twitter" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
		[specifier setProperty:[UIImage imageNamed:@"twitterIcon" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SmartVolumeControl3.bundle"]] forKey:@"iconImage"];
		[specifier setButtonAction:@selector(myTwitter)];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"Visit my website" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSButtonCell edit:nil];
		[specifier setProperty:[UIImage imageNamed:@"websiteIcon" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SmartVolumeControl3.bundle"]] forKey:@"iconImage"];
		[specifier setButtonAction:@selector(myWebsite)];
		[_specifiers addObject:specifier];
		[specifier release];

	}

	return _specifiers;

}

-(void)viewDidLoad {

	[super viewDidLoad];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
	tapRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];

}

-(void)dismissKeyboard:(UITapGestureRecognizer *)sender {

	[self.view endEditing:YES];

}

-(void)loadView {

	[super loadView];

	_logoContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 131.0)];

	_logoView = [[UIImageView alloc] initWithFrame:CGRectMake(_logoContainerView.frame.size.width / 2.0 - 265.0 / 2.0, 10.0, 265.0, 121.0)];
	_logoView.image = [UIImage imageNamed:@"logo" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SmartVolumeControl3.bundle"]];

	_version = [[UILabel alloc] initWithFrame:CGRectMake(_logoView.frame.origin.x + _logoView.frame.size.width - 30.0, 115.0, 50.0, 20.0)];
	_version.text = @"v. 1.2.2";
	_version.textColor = [UIColor colorWithRed:0.294 green:0.294 blue:0.294 alpha:1.0];
	_version.textAlignment = NSTextAlignmentRight;
	_version.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
	_version.adjustsFontSizeToFitWidth = YES;

	[_logoContainerView addSubview:_logoView];
	[_logoContainerView addSubview:_version];
	self.table.tableHeaderView = _logoContainerView;
	
}

-(void)viewDidLayoutSubviews {

	[super viewDidLayoutSubviews];

	_logoContainerView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 131.0);
	_logoView.frame = CGRectMake(_logoContainerView.frame.size.width / 2.0 - 265.0 / 2.0, 10.0, 265.0, 121.0);
	_version.frame = CGRectMake(_logoView.frame.origin.x + _logoView.frame.size.width - 30.0, 115.0, 50.0, 20.0);
	
}

-(void)dealloc {

	if (_webview != nil)
		[_webview release];

	[_version release];
	[_logoView release];
	[_logoContainerView release];
	[_specifiers release];
	_specifiers = nil;

	[super dealloc];

}

-(void)myTwitter {

	if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"twitter://"]]) // is twitter app installed?
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"twitter://user?screen_name=midkin"] options:@{} completionHandler:nil];
	else
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://twitter.com/midkin"] options:@{} completionHandler:nil];

}

-(void)myWebsite {

	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://midkin.eu"] options:@{} completionHandler:nil];

}

-(void)purchaseNow {

	// Does nothing after publishing the code

}

- (void)hideWebview: (UIButton*)sender {

	// Does nothing after publishing the code

}

-(void)addRepo {

	if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"cydia://"]]) // is cydia app installed?
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"cydia://url/https://cydia.saurik.com/api/share#?source=https://midkin.eu/repo/"] options:@{} completionHandler:nil];
	else if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"sileo://"]]) // is sileo app installed?
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"sileo://source/https://midkin.eu/repo/"] options:@{} completionHandler:nil];
	else if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"installer://"]]) // is installer app installed?
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"installer://add/repo=https://midkin.eu/repo/"] options:@{} completionHandler:nil];
	else if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"zbra://"]]) // is zebra app installed?
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"zbra://sources/add/https://midkin.eu/repo/"] options:@{} completionHandler:nil];

}

@end




@implementation SVCPSListItemsController

-(void)viewWillDisappear:(BOOL)disappear {

	if (disappear)
		[[[self specifier] performSelector:@selector(target)] reloadSpecifiers];

	[super viewWillDisappear:disappear];

}

@end




@implementation SVCHapticListController

- (NSMutableArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [[NSMutableArray alloc] init];
		PSSpecifier* specifier = nil;

		specifier = [[PSSpecifier alloc] initWithName:@"Haptic Feedback Settings" target:self set:NULL get:NULL detail:nil cell:PSGroupCell edit:nil];
		[specifier setProperty:@"1. Enable/Disable haptic feedback.\n2. Haptic feedback at minimum volume.\n3. Haptic feedback at maximum volume.\n4. Haptic feedback above min and below max volume.\n5. Minimum volume haptic feedback intensity.\n6. Maximum volume haptic feedback intensity.\n7. Other volume levels haptic feedback intensity.\n8. Whether changing volume level by touch will perform haptic feedback or not.\n\nPlease notice, to perform haptic feedback at ALL volume levels, switches 2, 3 and 4 must ALL be open!" forKey:@"footerText"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"1. Enable" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"hapticFeedback" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"2. Min volume" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"minHapticFeedback" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"3. Max volume" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"maxHapticFeedback" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];

		specifier = [[PSSpecifier alloc] initWithName:@"4. All volume steps" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
		[specifier setProperty:@"allHapticFeedback" forKey:@"key"];
		[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
		[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
		[_specifiers addObject:specifier];
		[specifier release];


		if ([[UIDevice currentDevice] _feedbackSupportLevel] == 1) {

			specifier = [[PSSpecifier alloc] initWithName:@"5. Min intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			[specifier setProperty:@"minHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"6. Max intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			[specifier setProperty:@"maxHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"7. Other steps intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Weak", @"Strong", nil] forKeys:specifier.values];
			[specifier setProperty:@"otherHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

		}

		else if ([[UIDevice currentDevice] _feedbackSupportLevel] == 2) {

			specifier = [[PSSpecifier alloc] initWithName:@"5. Min intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:5], [NSNumber numberWithUnsignedChar:3], [NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:4], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:6], [NSNumber numberWithUnsignedChar:7], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low duration", @"Soft", @"Light", @"Medium", @"Medium low duration", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low", @"Soft", @"Light", @"Medium", @"Medium low", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			[specifier setProperty:@"minHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"6. Max intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:5], [NSNumber numberWithUnsignedChar:3], [NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:4], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:6], [NSNumber numberWithUnsignedChar:7], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low duration", @"Soft", @"Light", @"Medium", @"Medium low duration", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low", @"Soft", @"Light", @"Medium", @"Medium low", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			[specifier setProperty:@"maxHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"7. Other steps intensity" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"PSListItemsController") cell:PSLinkListCell edit:nil];
			specifier.values = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedChar:5], [NSNumber numberWithUnsignedChar:3], [NSNumber numberWithUnsignedChar:0], [NSNumber numberWithUnsignedChar:1], [NSNumber numberWithUnsignedChar:4], [NSNumber numberWithUnsignedChar:2], [NSNumber numberWithUnsignedChar:6], [NSNumber numberWithUnsignedChar:7], nil];
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low duration", @"Soft", @"Light", @"Medium", @"Medium low duration", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Soft low", @"Soft", @"Light", @"Medium", @"Medium low", @"Heavy", @"Success", @"Error", nil] forKeys:specifier.values];
			[specifier setProperty:@"otherHapticFeedbackIntensity" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithUnsignedChar:0] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

			specifier = [[PSSpecifier alloc] initWithName:@"8. Allow touch haptic" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier setProperty:@"touchHaptic" forKey:@"key"];
			[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3" forKey:@"defaults"];
			[specifier setProperty:@"eu.midkin.smartvolumecontrol3.settingschanged" forKey:@"PostNotification"];
			[_specifiers addObject:specifier];
			[specifier release];

		}

	}

	return _specifiers;

}

-(void)dealloc {

	[_specifiers release];
	_specifiers = nil;

	[super dealloc];

}

@end





