#import <LocalAuthentication/LocalAuthentication.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YouTubeExtractor/YouTubeExtractor.h>
#import <AFNetworking/AFNetworking.h>
#import "Controllers/RootOptionsController.h"
#import "Controllers/PictureInPictureController.h"
#import "Tweak.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

static BOOL hasDeviceNotch() {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return NO;
	} else {
		LAContext* context = [[LAContext alloc] init];
		[context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
		return [context biometryType] == LABiometryTypeFaceID;
	}
}

UIColor *rebornHexColour;

YTLocalPlaybackController *playingVideoID;

%hook YTLocalPlaybackController
- (NSString *)currentVideoID {
    playingVideoID = self;
    return %orig;
}
%end

YTSingleVideo *shortsPlayingVideoID;

%hook YTSingleVideo
- (NSString *)videoId {
    shortsPlayingVideoID = self;
    return %orig;
}
%end

YTUserDefaults *ytThemeSettings;

%hook YTUserDefaults
- (long long)appThemeSetting {
    ytThemeSettings = self;
    return %orig;
}
%end

YTMainAppVideoPlayerOverlayViewController *resultOut;
YTMainAppVideoPlayerOverlayViewController *layoutOut;
YTMainAppVideoPlayerOverlayViewController *stateOut;

%hook YTMainAppVideoPlayerOverlayViewController
- (CGFloat)mediaTime {
    resultOut = self;
    return %orig;
}
- (int)playerViewLayout {
    layoutOut = self;
    return %orig;
}
- (NSInteger)playerState {
    stateOut = self;
    return %orig;
}
%end

%group gPictureInPicture
%hook YTPlayerPIPController
- (BOOL)isPictureInPicturePossible {
    return YES;
}
- (BOOL)canEnablePictureInPicture {
    return YES;
}
- (BOOL)isPipSettingEnabled {
    return YES;
}
- (BOOL)isPictureInPictureForceDisabled {
    return NO;
}
- (void)setPictureInPictureForceDisabled:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%hook YTLocalPlaybackController
- (BOOL)isPictureInPicturePossible {
    return YES;
}
%end
%hook YTBackgroundabilityPolicy
- (BOOL)isPlayableInPictureInPictureByUserSettings {
    return YES;
}
%end
%hook YTLightweightPlayerViewController
- (BOOL)isPictureInPicturePossible {
    return YES;
}
%end
%hook YTPlayerViewController
- (BOOL)isPictureInPicturePossible {
    return YES;
}
%end
%hook YTPlayerResponse
- (BOOL)isPlayableInPictureInPicture {
    return YES;
}
- (BOOL)isPipOffByDefault {
    return NO;
}
%end
%hook MLPIPController
- (BOOL)pictureInPictureSupported {
    return YES;
}
%end
%end

%hook YTRightNavigationButtons
%property (strong, nonatomic) YTQTMButton *youtubeRebornButton;
- (NSMutableArray *)buttons {
	NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouTubeReborn" ofType:@"bundle"];
    NSString *youtubeRebornLightSettingsPath;
    NSString *youtubeRebornDarkSettingsPath;
    if (tweakBundlePath) {
        NSBundle *tweakBundle = [NSBundle bundleWithPath:tweakBundlePath];
        youtubeRebornLightSettingsPath = [tweakBundle pathForResource:@"ytrebornbuttonwhite" ofType:@"png"];
		youtubeRebornDarkSettingsPath = [tweakBundle pathForResource:@"ytrebornbuttonblack" ofType:@"png"];
    } else {
		youtubeRebornLightSettingsPath = @"/Library/Application Support/YouTubeReborn.bundle/ytrebornbuttonwhite.png";
        youtubeRebornDarkSettingsPath = @"/Library/Application Support/YouTubeReborn.bundle/ytrebornbuttonblack.png";
    }
    NSMutableArray *retVal = %orig.mutableCopy;
    [self.youtubeRebornButton removeFromSuperview];
    [self addSubview:self.youtubeRebornButton];
    if (!self.youtubeRebornButton) {
        self.youtubeRebornButton = [%c(YTQTMButton) iconButton];
        self.youtubeRebornButton.frame = CGRectMake(0, 0, 24, 24);
        
        if ([%c(YTPageStyleController) pageStyle] == 0) {
            [self.youtubeRebornButton setImage:[UIImage imageWithContentsOfFile:youtubeRebornDarkSettingsPath] forState:UIControlStateNormal];
        }
        else if ([%c(YTPageStyleController) pageStyle] == 1) {
            [self.youtubeRebornButton setImage:[UIImage imageWithContentsOfFile:youtubeRebornLightSettingsPath] forState:UIControlStateNormal];
        }
        
        [self.youtubeRebornButton addTarget:self action:@selector(rebornRootOptionsAction) forControlEvents:UIControlEventTouchUpInside];
        [retVal insertObject:self.youtubeRebornButton atIndex:0];
    }
    return retVal;
}
- (NSMutableArray *)visibleButtons {
    NSMutableArray *retVal = %orig.mutableCopy;
    [self setLeadingPadding:+10];
    if (self.youtubeRebornButton) {
        [self.youtubeRebornButton removeFromSuperview];
        [self addSubview:self.youtubeRebornButton];
        [retVal insertObject:self.youtubeRebornButton atIndex:0];
    }
    return retVal;
}
%new;
- (void)rebornRootOptionsAction {
    RootOptionsController *rootOptionsController = [[RootOptionsController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *rootOptionsControllerView = [[UINavigationController alloc] initWithRootViewController:rootOptionsController];
    rootOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    UIViewController *rootPrefsViewController = [self _viewControllerForAncestor];
    [rootPrefsViewController presentViewController:rootOptionsControllerView animated:YES completion:nil];
}
%end

%hook YTMainAppControlsOverlayView

%property(retain, nonatomic) UIButton *rebornOverlayButton;

- (id)initWithDelegate:(id)delegate {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"15.0")) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == NO && [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnablePictureInPictureVTwo"] == YES) {
            %init(gPictureInPicture);
        }
    }
    self = %orig;
    if (self) {
        self.rebornOverlayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rebornOverlayButton addTarget:self action:@selector(rebornOptionsAction) forControlEvents:UIControlEventTouchUpInside];
        [self.rebornOverlayButton setTitle:@"OP" forState:UIControlStateNormal];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kShowStatusBarInOverlay"] == YES) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"] == YES) {
                self.rebornOverlayButton.frame = CGRectMake(40, 9, 40.0, 30.0);
            } else {
                self.rebornOverlayButton.frame = CGRectMake(40, 24, 40.0, 30.0);
            }
        } else {
            self.rebornOverlayButton.frame = CGRectMake(40, 9, 40.0, 30.0);
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornOPButtonVTwo"] == YES) {
            self.rebornOverlayButton.hidden = YES;
        }
        [self addSubview:self.rebornOverlayButton];
    }
    return self;
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    if (canceledState) {
        if (!self.rebornOverlayButton.hidden) {
            self.rebornOverlayButton.alpha = 0.0;
        }
    } else {
        if (!self.rebornOverlayButton.hidden) {
            int rotation = [layoutOut playerViewLayout];
            if (rotation == 2) {
                self.rebornOverlayButton.alpha = visible ? 1.0 : 0.0;
            } else {
                self.rebornOverlayButton.alpha = 0.0;
            }
        }
    }
    %orig;
}

%new;
- (void)rebornOptionsAction {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        [self didPressPause:[self playPauseButton]];
    }

    NSString *videoIdentifier = [playingVideoID currentVideoID];

    UIAlertController *alertMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    // if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14.0") && SYSTEM_VERSION_LESS_THAN(@"15.0") && [[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == NO) {
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"Picture In Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self rebornPictureInPicture:videoIdentifier];
        }]];
    // }

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Play In External App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self rebornPlayInExternalApp:videoIdentifier];
    }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertMenu setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertMenu popoverPresentationController];
    popPresenter.sourceView = self;
    popPresenter.sourceRect = self.bounds;

    UIViewController *menuViewController = [self _viewControllerForAncestor];
    [menuViewController presentViewController:alertMenu animated:YES completion:nil];
}

%new;
- (void)rebornPictureInPicture :(NSString *)videoID {
    NSString *videoTime = [NSString stringWithFormat:@"%f", [resultOut mediaTime]];
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSURL *videoPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"] == YES) {
        PictureInPictureController *pictureInPictureController = [[PictureInPictureController alloc] init];
        pictureInPictureController.videoTime = videoTime;
        pictureInPictureController.videoPath = videoPath;
        UINavigationController *pictureInPictureControllerView = [[UINavigationController alloc] initWithRootViewController:pictureInPictureController];
        pictureInPictureControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        UIViewController *pictureInPictureViewController = self._viewControllerForAncestor;
        [pictureInPictureViewController presentViewController:pictureInPictureControllerView animated:YES completion:nil];
    } else {
        UIAlertController *alertPip = [UIAlertController alertControllerWithTitle:@"Notice" message:@"You must enable 'Background Playback' in YouTube Reborn settings to use Picture-In-Picture" preferredStyle:UIAlertControllerStyleAlert];

        [alertPip addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];

        UIViewController *pipViewController = [self _viewControllerForAncestor];
        [pipViewController presentViewController:alertPip animated:YES completion:nil];
    }
}

%new;
- (void)rebornPlayInExternalApp :(NSString *)videoID {
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSURL *videoPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    UIAlertController *alertApp = [UIAlertController alertControllerWithTitle:@"Choose App" message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Play In Infuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"infuse://x-callback-url/play?url=%@", videoPath]] options:@{} completionHandler:nil];
    }]];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Play In VLC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"vlc-x-callback://x-callback-url/stream?url=%@", videoPath]] options:@{} completionHandler:nil];
    }]];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];

    UIViewController *alertAppViewController = [self _viewControllerForAncestor];
    [alertAppViewController presentViewController:alertApp animated:YES completion:nil];
}
%end

%hook YTReelHeaderView
- (void)layoutSubviews {
	%orig();
    UIButton *rebornOverlayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rebornOverlayButton addTarget:self action:@selector(rebornOptionsAction) forControlEvents:UIControlEventTouchUpInside];
    [rebornOverlayButton setTitle:@"OP" forState:UIControlStateNormal];
    rebornOverlayButton.frame = CGRectMake(40, 5, 40.0, 30.0);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornShortsOPButton"] == YES) {
        rebornOverlayButton.hidden = YES;
    }
    [self addSubview:rebornOverlayButton];
}

%new;
- (void)rebornOptionsAction {
    NSString *videoIdentifier = [shortsPlayingVideoID videoId];

    UIAlertController *alertMenu = [UIAlertController alertControllerWithTitle:nil message:@"Please Pause The Video Before Continuing" preferredStyle:UIAlertControllerStyleActionSheet];

    // if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14.0") && SYSTEM_VERSION_LESS_THAN(@"15.0") && [[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == NO) {
        [alertMenu addAction:[UIAlertAction actionWithTitle:@"Picture In Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self rebornPictureInPicture:videoIdentifier];
        }]];
    // }

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Play In External App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self rebornPlayInExternalApp:videoIdentifier];
    }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [alertMenu setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alertMenu popoverPresentationController];
    popPresenter.sourceView = self;
    popPresenter.sourceRect = self.bounds;

    UIViewController *menuViewController = [self _viewControllerForAncestor];
    [menuViewController presentViewController:alertMenu animated:YES completion:nil];
}

%new;
- (void)rebornPictureInPicture :(NSString *)videoID {
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSURL *videoPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"] == YES) {
        PictureInPictureController *pictureInPictureController = [[PictureInPictureController alloc] init];
        pictureInPictureController.videoTime = nil;
        pictureInPictureController.videoPath = videoPath;
        UINavigationController *pictureInPictureControllerView = [[UINavigationController alloc] initWithRootViewController:pictureInPictureController];
        pictureInPictureControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

        UIViewController *pictureInPictureViewController = self._viewControllerForAncestor;
        [pictureInPictureViewController presentViewController:pictureInPictureControllerView animated:YES completion:nil];
    } else {
        UIAlertController *alertPip = [UIAlertController alertControllerWithTitle:@"Notice" message:@"You must enable 'Background Playback' in YouTube Reborn settings to use Picture-In-Picture" preferredStyle:UIAlertControllerStyleAlert];

        [alertPip addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];

        UIViewController *pipViewController = [self _viewControllerForAncestor];
        [pipViewController presentViewController:alertPip animated:YES completion:nil];
    }
}

%new;
- (void)rebornPlayInExternalApp :(NSString *)videoID {
    NSDictionary *youtubePlayerRequest = [YouTubeExtractor youtubePlayerRequest:@"IOS":@"16.20":videoID];
    NSURL *videoPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", youtubePlayerRequest[@"streamingData"][@"hlsManifestUrl"]]];

    UIAlertController *alertApp = [UIAlertController alertControllerWithTitle:@"Choose App" message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Play In Infuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"infuse://x-callback-url/play?url=%@", videoPath]] options:@{} completionHandler:nil];
    }]];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Play In VLC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"vlc-x-callback://x-callback-url/stream?url=%@", videoPath]] options:@{} completionHandler:nil];
    }]];

    [alertApp addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];

    UIViewController *alertAppViewController = [self _viewControllerForAncestor];
    [alertAppViewController presentViewController:alertApp animated:YES completion:nil];
}
%end

%group gNoVideoAds
%hook YTIPlayerResponse
- (BOOL)isMonetized {
    return NO;
}
%end
%hook YTDataUtils
+ (id)spamSignalsDictionary {
    return NULL;
}
%end
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
}
%end
%end

%group gBackgroundPlayback
%hook YTIPlayerResponse
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%hook YTSingleVideo
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%hook YTSingleVideoMediaData
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%hook YTPlaybackData
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%hook YTPlaybackBackgroundTaskController
- (BOOL)isContentPlayableInBackground {
    return YES;
}
- (void)setContentPlayableInBackground:(BOOL)arg1 {
    arg1 = YES;
	%orig;
}
%end
%hook YTBackgroundabilityPolicy
- (BOOL)isBackgroundableByUserSettings {
    return YES;
}
%end
%end

%group gExtraSpeedOptions
%hook YTVarispeedSwitchController
- (void *)init {
    void *ret = (void *)%orig;

    NSMutableArray *ytSpeedOptions = [NSMutableArray new];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"0.1x" rate:0.1]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"0.25x" rate:0.25]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"0.5x" rate:0.5]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"0.75x" rate:0.75]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"Normal" rate:1]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"1.25x" rate:1.25]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"1.5x" rate:1.5]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"1.75x" rate:1.75]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"2x" rate:2]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"2.5x" rate:2.5]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"3x" rate:3]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"3.5x" rate:3.5]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"4x" rate:4]];
    [ytSpeedOptions addObject:[[NSClassFromString(@"YTVarispeedSwitchControllerOption") alloc] initWithTitle:@"5x" rate:5]];
    MSHookIvar<NSArray *>(self, "_options") = [ytSpeedOptions copy];

    return ret;
}
%end
%hook MLHAMQueuePlayer
- (void)setRate:(float)rate {
	MSHookIvar<float>(self, "_rate") = rate;

	id ytPlayer = MSHookIvar<HAMPlayerInternal *>(self, "_player");
	[ytPlayer setRate:rate];

	[self.playerEventCenter broadcastRateChange:rate];
}
%end
%end

%group gNoCastButton
%hook YTSettings
- (BOOL)disableMDXDeviceDiscovery {
    return YES;
} 
%end
%hook YTRightNavigationButtons
- (void)layoutSubviews {
	%orig();
	if(![[self MDXButton] isHidden]) [[self MDXButton] setHidden:YES];
}
%end
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
	if(![[self playbackRouteButton] isHidden]) [[self playbackRouteButton] setHidden:YES];
}
%end
%end

%group gNoNotificationButton
%hook YTNotificationPreferenceToggleButton
- (void)setHidden:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
%end
%hook YTNotificationMultiToggleButton
- (void)setHidden:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
%end
%hook YTRightNavigationButtons
- (void)layoutSubviews {
	%orig();
	if(![[self notificationButton] isHidden]) [[self notificationButton] setHidden:YES];
}
%end
%end

%group gAllowHDOnCellularData
%hook YTUserDefaults
- (BOOL)disableHDOnCellular {
	return NO;
}
- (void)setDisableHDOnCellular:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%hook YTSettings
- (BOOL)disableHDOnCellular {
	return NO;
}
- (void)setDisableHDOnCellular:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%end

%group gShowStatusBarInOverlay
%hook YTSettings
- (BOOL)showStatusBarWithOverlay {
    return YES;
}
%end
%end

%group gDisableRelatedVideosInOverlay
%hook YTRelatedVideosViewController
- (BOOL)isEnabled {
    return NO;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = NO;
	%orig;
}
%end
%hook YTFullscreenEngagementOverlayView
- (BOOL)isEnabled {
    return NO;
} 
- (void)setEnabled:(BOOL)arg1 {
    arg1 = NO;
    %orig;
} 
%end
%hook YTFullscreenEngagementOverlayController
- (BOOL)isEnabled {
    return NO;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayView
- (void)setInfoCardButtonHidden:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
- (void)setInfoCardButtonVisible:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayViewController
- (void)adjustPlayerBarPositionForRelatedVideos {
}
%end
%end

%group gDisableVideoEndscreenPopups
%hook YTCreatorEndscreenView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%end

%group gDisableYouTubeKids
%hook YTWatchMetadataAppPromoCell
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return NULL;
}
%end
%hook YTNGWatchMiniBarViewController
- (id)miniplayerRenderer {
    return NULL;
}
%end
%hook YTWatchMiniBarViewController
- (id)miniplayerRenderer {
    return NULL;
}
%end
%end

%group gDisableHints
%hook YTSettings
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
%end
%hook YTUserDefaults
- (BOOL)areHintsDisabled {
	return YES;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    arg1 = YES;
    %orig;
}
%end
%end

%group gHideExploreTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEexplore"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];

    %orig;
}
%end
%end

%group gHideShortsTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEshorts"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];

    %orig;
}
%end
%end

%group gHideUploadTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarIconOnlyItemRenderer] pivotIdentifier] isEqualToString:@"FEuploads"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];

    %orig;
}
%end
%end

%group gHideSubscriptionsTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FEsubscriptions"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];

    %orig;
}
%end
%end

%group gHideLibraryTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"FElibrary"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];

    %orig;
}
%end
%end

%group gDisableDoubleTapToSkip
%hook YTDoubleTapToSeekController
- (void)enableDoubleTapToSeek:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
- (void)showDoubleTapToSeekEducationView:(BOOL)arg1 {
    arg1 = NO;
    %orig;
}
%end
%hook YTSettings
- (BOOL)doubleTapToSeekEnabled {
    return NO;
}
%end
%end

%group gHideOverlayDarkBackground
%hook YTMainAppVideoPlayerOverlayView
- (void)setBackgroundVisible:(BOOL)arg1 {
    arg1 = NO;
	%orig;
}
%end
%end

%group gEnableiPadStyleOniPhone
%hook UIDevice
- (long long)userInterfaceIdiom {
    return YES;
} 
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return NO;
} 
%end
%hook UIKBTree
- (long long)nativeIdiom {
    return NO;
} 
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    return NO;
} 
%end
%end

%group gHidePreviousButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTMainAppControlsOverlayView *>(self, "_previousButton").hidden = YES;
}
%end
%end

%group gHideNextButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTMainAppControlsOverlayView *>(self, "_nextButton").hidden = YES;
}
%end
%end

%group gDisableVideoAutoPlay
%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1 {
	arg1 = NO;
	%orig;
}
%end
%end

%group gHideAutoPlaySwitchInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
	if(![[self autonavSwitch] isHidden]) [[self autonavSwitch] setHidden:YES];
}
%end
%end

%group gHideCaptionsSubtitlesButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
    if(![[self closedCaptionsOrSubtitlesButton] isHidden]) [[self closedCaptionsOrSubtitlesButton] setHidden:YES];
}
%end
%end

%group gDisableVideoInfoCards
%hook YTInfoCardDarkTeaserContainerView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
- (BOOL)isVisible {
    return NO;
}
%end
%hook YTInfoCardTeaserContainerView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
- (BOOL)isVisible {
    return NO;
}
%end
%hook YTSimpleInfoCardDarkTeaserView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTSimpleInfoCardTeaserView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTPaidContentViewController
- (id)initWithParentResponder:(id)arg1 paidContentRenderer:(id)arg2 enableNewPaidProductDisclosure:(BOOL)arg3 {
    arg2 = NULL;
    arg3 = NO;
    return %orig;
}
%end
%hook YTPaidContentOverlayView
- (id)initWithParentResponder:(id)arg1 paidContentRenderer:(id)arg2 enableNewPaidProductDisclosure:(BOOL)arg3 {
    arg2 = NULL;
    arg3 = NO;
    return %orig;
}
%end
%end

%group gNoSearchButton
%hook YTRightNavigationButtons
- (void)layoutSubviews {
	%orig();
	if(![[self searchButton] isHidden]) [[self searchButton] setHidden:YES];
}
%end
%end

%group gHideTabBarLabels
%hook YTPivotBarItemView
- (void)layoutSubviews {
    %orig();
    [[self navigationButton] setTitle:@"" forState:UIControlStateNormal];
    [[self navigationButton] setTitle:@"" forState:UIControlStateSelected];
}
%end
%end

%group gHideChannelWatermark
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
}
%end
%end

%group gHideShortsMoreActionsButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTReelPlayerMoreButton *>(self, "_moreButton").hidden = YES;
}
%end
%end

%group gHideShortsLikeButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTQTMButton *>(self, "_reelLikeButton").hidden = YES;
}
%end
%end

%group gHideShortsDislikeButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTQTMButton *>(self, "_reelDislikeButton").hidden = YES;
}
%end
%end

%group gHideShortsCommentsButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTQTMButton *>(self, "_viewCommentButton").hidden = YES;
}
%end
%end

%group gHideShortsShareButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
	%orig();
	MSHookIvar<YTQTMButton *>(self, "_shareButton").hidden = YES;
}
%end
%end

%group gColourOptions
%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTPivotBarView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTSlideForActionsView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTChipCloudCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTEngagementPanelView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistPanelProminentThumbnailVideoCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistHeaderView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTAsyncCollectionView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTLinkCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTMessageCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTSearchView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTDrawerAvatarCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTFeedHeaderView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTextCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatViewerEngagementCell")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTCommentsHeaderView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatView")]) {
        color = rebornHexColour;
    }
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTickerViewController")]) {
        color = rebornHexColour;
    }
    %orig;
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
        color = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } else if([self.nextResponder isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
        color = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } else {
        color = rebornHexColour;
    }
    %orig;
}
- (UIColor *)darkBackgroundColor {
    return rebornHexColour;
}
- (void)setDarkBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTVideoView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = rebornHexColour;
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
- (void)setBarTintColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YCHLiveChatBannerCell
- (void)layoutSubviews {
	%orig();
	MSHookIvar<UIImageView *>(self, "_bannerContainerImageView").hidden = YES;
    MSHookIvar<UIView *>(self, "_bannerContainerView").backgroundColor = rebornHexColour;
}
%end
%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    color = rebornHexColour;
    %orig;
}
%end
%hook YTSearchSuggestionCollectionViewCell
- (void)updateColors {
}
%end
%hook YTCreateCommentTextView
- (void)setTextColor:(UIColor *)color {
    long long ytDarkModeCheck = [ytThemeSettings appThemeSetting];
    if (ytDarkModeCheck == 0 || ytDarkModeCheck == 1) {
        if (UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            color = [UIColor blackColor];
        } else {
            color = [UIColor whiteColor];
        }
    }
    if (ytDarkModeCheck == 2) {
        color = [UIColor blackColor];
    }
    if (ytDarkModeCheck == 3) {
        color = [UIColor whiteColor];
    }
    %orig;
}
%end
%hook YTShareMainView
- (void)layoutSubviews {
	%orig();
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = rebornHexColour;
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = rebornHexColour;
}
%end
%end

%group gAutoFullScreen
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig();
    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(autoFullscreen) userInfo:nil repeats:NO];
}
%new
- (void)autoFullscreen {
    YTWatchController *watchController = [self valueForKey:@"_UIDelegate"];
    [watchController showFullScreen];
}
%end
%end

%group gHideYouTubeLogo
%hook YTHeaderLogoController
- (YTHeaderLogoController *)init {
    return NULL;
}
%end
%end

%group gHideOverlayQuickActions
%hook YTFullscreenActionsView
- (id)initWithElementView:(id)arg1 {
    return NULL;
}
- (id)initWithElementRenderer:(id)arg1 parentResponder:(id)arg2 {
    return NULL;
}
- (BOOL)enabled {
    return 0;
}
%end
%end

%group gAlwaysShowPlayerBar
%hook YTPlayerBarController
- (void)setPlayerViewLayout:(int)arg1 {
    arg1 = 2;
    %orig;
} 
%end
%end

%group gHidePlayerBarHeatwave
%hook YTPlayerBarHeatwaveView
- (id)initWithFrame:(CGRect)frame heatmap:(id)heat {
    return NULL;
}
%end
%hook YTPlayerBarController
- (void)setHeatmap:(id)arg1 {
    arg1 = NULL;
    %orig;
}
%end
%end

%group gHidePictureInPictureAdsBadge
%hook YTPlayerPIPController
- (void)displayAdsBadge {
}
%end
%end

%group gHidePictureInPictureSponsorBadge
%hook YTPlayerPIPController
- (void)displaySponsorBadge {
}
%end
%end

BOOL sponsorBlockEnabled;
NSDictionary *sponsorBlockValues = [[NSDictionary alloc] init];

%hook YTPlayerViewController
- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    sponsorBlockEnabled = 0;
    sponsorBlockValues = [YouTubeExtractor sponsorBlockRequest:self.currentVideoID];
    %orig();
    if ([NSJSONSerialization isValidJSONObject:sponsorBlockValues]) {
        sponsorBlockEnabled = 1;
    } else {
        sponsorBlockEnabled = 0;
    }
}
- (void)singleVideo:(id)video currentVideoTimeDidChange:(YTSingleVideoTime *)time {
    %orig();
    if (sponsorBlockEnabled == 1) {
        for (NSMutableDictionary *jsonDictionary in sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"sponsor"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"selfpromo"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSelfPromoSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSelfPromoSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"interaction"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kInteractionSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kInteractionSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"intro"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kIntroSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kIntroSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"outro"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kOutroSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kOutroSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"preview"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kPreviewSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kPreviewSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            } else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kMusicOffTopicSegmentedInt"] && self.currentVideoMediaTime >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && self.currentVideoMediaTime <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kMusicOffTopicSegmentedInt"] == 1) {
                    [self seekToTime:[[jsonDictionary objectForKey:@"segment"][1] floatValue]];
                }
            }
        }
    }
}
%end

int selectedTabIndex = 0;

%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig();
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"]) {
        int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"];
        if (selectedTab == 0 && selectedTabIndex == 0) {
            [self selectItemWithPivotIdentifier:@"FEwhat_to_watch"];
            selectedTabIndex = 1;
        }
        if (selectedTab == 1 && selectedTabIndex == 0) {
            [self selectItemWithPivotIdentifier:@"FEexplore"];
            selectedTabIndex = 1;
        }
        if (selectedTab == 2 && selectedTabIndex == 0) {
            [self selectItemWithPivotIdentifier:@"FEshorts"];
            selectedTabIndex = 1;
        }
        if (selectedTab == 3 && selectedTabIndex == 0) {
            [self selectItemWithPivotIdentifier:@"FEsubscriptions"];
            selectedTabIndex = 1;
        }
        if (selectedTab == 4 && selectedTabIndex == 0) {
            [self selectItemWithPivotIdentifier:@"FElibrary"];
            selectedTabIndex = 1;
        }
    }
}
%end

%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
%end

%ctor {
    @autoreleasepool {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kEnableNoVideoAds"] == nil) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableNoVideoAds"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kEnablePictureInPictureVTwo"] == nil) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnablePictureInPictureVTwo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableNoVideoAds"] == YES) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == NO) {
                %init(gNoVideoAds);
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"] == YES) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kRebornIHaveYouTubePremium"] == NO) {
                %init(gBackgroundPlayback);
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kNoCastButton"] == YES) %init(gNoCastButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kNoNotificationButton"] == YES) %init(gNoNotificationButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kAllowHDOnCellularData"] == YES) %init(gAllowHDOnCellularData);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoEndscreenPopups"] == YES) %init(gDisableVideoEndscreenPopups);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableYouTubeKidsPopup"] == YES) %init(gDisableYouTubeKids);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableExtraSpeedOptions"] == YES) %init(gExtraSpeedOptions);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableHints"] == YES) %init(gDisableHints);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideTabBarLabels"] == YES) %init(gHideTabBarLabels);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideExploreTab"] == YES) %init(gHideExploreTab);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsTab"] == YES) %init(gHideShortsTab);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideUploadTab"] == YES) %init(gHideUploadTab);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideSubscriptionsTab"] == YES) %init(gHideSubscriptionsTab);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideLibraryTab"] == YES) %init(gHideLibraryTab);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableDoubleTapToSkip"] == YES) %init(gDisableDoubleTapToSkip);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayDarkBackground"] == YES) %init(gHideOverlayDarkBackground);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePreviousButtonInOverlay"] == YES) %init(gHidePreviousButtonInOverlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideNextButtonInOverlay"] == YES) %init(gHideNextButtonInOverlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoAutoPlay"] == YES) %init(gDisableVideoAutoPlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideAutoPlaySwitchInOverlay"] == YES) %init(gHideAutoPlaySwitchInOverlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideCaptionsSubtitlesButtonInOverlay"] == YES) %init(gHideCaptionsSubtitlesButtonInOverlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoInfoCards"] == YES) %init(gDisableVideoInfoCards);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kNoSearchButton"] == YES) %init(gNoSearchButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideChannelWatermark"] == YES) %init(gHideChannelWatermark);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsMoreActionsButton"] == YES) %init(gHideShortsMoreActionsButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsLikeButton"] == YES) %init(gHideShortsLikeButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsDislikeButton"] == YES) %init(gHideShortsDislikeButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsCommentsButton"] == YES) %init(gHideShortsCommentsButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideShortsShareButton"] == YES) %init(gHideShortsShareButton);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoFullScreen"] == YES) %init(gAutoFullScreen);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideYouTubeLogo"] == YES) %init(gHideYouTubeLogo);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableRelatedVideosInOverlay"] == YES) %init(gDisableRelatedVideosInOverlay);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayQuickActions"] == YES) %init(gHideOverlayQuickActions);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"] == YES) %init(gEnableiPadStyleOniPhone);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePlayerBarHeatwave"] == YES) %init(gHidePlayerBarHeatwave);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePictureInPictureAdsBadge"] == YES) %init(gHidePictureInPictureAdsBadge);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePictureInPictureSponsorBadge"] == YES) %init(gHidePictureInPictureSponsorBadge);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableRelatedVideosInOverlay"] == YES & [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayQuickActions"] == YES & [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlwaysShowPlayerBarVTwo"] == YES) {
            %init(gAlwaysShowPlayerBar);
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"] == NO & hasDeviceNotch() == NO & [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowStatusBarInOverlay"] == YES) {
            %init(gShowStatusBarInOverlay);
        }
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kYTRebornColourOptionsVFour"];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
        [unarchiver setRequiresSecureCoding:NO];
        NSString *hexString = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        if(hexString != nil) {
            rebornHexColour = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
            %init(gColourOptions);
        }
        %init(_ungrouped);
    }
}