#import "VideoOptionsController.h"
#import "../TheosLinuxFix.h"
#import "../iOS15Fix.h"

@interface VideoOptionsController ()
- (void)setupVideoOptionsControllerView;
@end

@implementation VideoOptionsController

- (void)loadView {
	[super loadView];
    [self setupVideoOptionsControllerView];

    self.title = @"Video Options";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VideoTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        if (@available(iOS 13.0, *)) {
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
                cell.textLabel.textColor = [UIColor blackColor];
            } else {
                cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Enable No Ads (Video/HomeScreen)";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *enableNoVideoAds = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableNoVideoAds addTarget:self action:@selector(toggleEnableNoVideoAds:) forControlEvents:UIControlEventValueChanged];
            enableNoVideoAds.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableNoVideoAds"];
            cell.accessoryView = enableNoVideoAds;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Enable Background Playback";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *enableBackgroundPlayback = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableBackgroundPlayback addTarget:self action:@selector(toggleEnableBackgroundPlayback:) forControlEvents:UIControlEventValueChanged];
            enableBackgroundPlayback.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"];
            cell.accessoryView = enableBackgroundPlayback;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Allow HD On Cellular Data";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *allowHDOnCellularData = [[UISwitch alloc] initWithFrame:CGRectZero];
            [allowHDOnCellularData addTarget:self action:@selector(toggleAllowHDOnCellularData:) forControlEvents:UIControlEventValueChanged];
            allowHDOnCellularData.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAllowHDOnCellularData"];
            cell.accessoryView = allowHDOnCellularData;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"Auto Play In FullScreen";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *autoFullScreen = [[UISwitch alloc] initWithFrame:CGRectZero];
            [autoFullScreen addTarget:self action:@selector(toggleAutoFullScreen:) forControlEvents:UIControlEventValueChanged];
            autoFullScreen.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAutoFullScreen"];
            cell.accessoryView = autoFullScreen;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"Disable Video Endscreen Popups";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *disableVideoEndscreenPopups = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoEndscreenPopups addTarget:self action:@selector(toggleDisableVideoEndscreenPopups:) forControlEvents:UIControlEventValueChanged];
            disableVideoEndscreenPopups.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoEndscreenPopups"];
            cell.accessoryView = disableVideoEndscreenPopups;
        }
        if (indexPath.row == 5) {
            cell.textLabel.text = @"Disable Video Info Cards";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *disableVideoInfoCards = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoInfoCards addTarget:self action:@selector(toggleDisableVideoInfoCards:) forControlEvents:UIControlEventValueChanged];
            disableVideoInfoCards.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoInfoCards"];
            cell.accessoryView = disableVideoInfoCards;
        }
        if (indexPath.row == 6) {
            cell.textLabel.text = @"Disable Video AutoPlay";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *disableVideoAutoPlay = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableVideoAutoPlay addTarget:self action:@selector(toggleDisableVideoAutoPlay:) forControlEvents:UIControlEventValueChanged];
            disableVideoAutoPlay.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableVideoAutoPlay"];
            cell.accessoryView = disableVideoAutoPlay;
        }
        if (indexPath.row == 7) {
            cell.textLabel.text = @"Disable Double Tap To Skip";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *disableDoubleTapToSkip = [[UISwitch alloc] initWithFrame:CGRectZero];
            [disableDoubleTapToSkip addTarget:self action:@selector(toggleDisableDoubleTapToSkip:) forControlEvents:UIControlEventValueChanged];
            disableDoubleTapToSkip.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableDoubleTapToSkip"];
            cell.accessoryView = disableDoubleTapToSkip;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = @"Hide Channel Watermark";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *hideChannelWatermark = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hideChannelWatermark addTarget:self action:@selector(toggleHideChannelWatermark:) forControlEvents:UIControlEventValueChanged];
            hideChannelWatermark.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideChannelWatermark"];
            cell.accessoryView = hideChannelWatermark;
        }
        if (indexPath.row == 8) {
            cell.textLabel.text = @"Hide Player Bar Heatwave";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *hidePlayerBarHeatwave = [[UISwitch alloc] initWithFrame:CGRectZero];
            [hidePlayerBarHeatwave addTarget:self action:@selector(toggleHidePlayerBarHeatwave:) forControlEvents:UIControlEventValueChanged];
            hidePlayerBarHeatwave.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHidePlayerBarHeatwave"];
            cell.accessoryView = hidePlayerBarHeatwave;
        }
        if (indexPath.row == 9) {
            cell.textLabel.text = @"Always Show Player Bar";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kDisableRelatedVideosInOverlay"] == NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"kHideOverlayQuickActions"] == NO) {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            } else {
                UISwitch *alwaysShowPlayerBar = [[UISwitch alloc] initWithFrame:CGRectZero];
                [alwaysShowPlayerBar addTarget:self action:@selector(toggleAlwaysShowPlayerBar:) forControlEvents:UIControlEventValueChanged];
                alwaysShowPlayerBar.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kAlwaysShowPlayerBarVTwo"];
                cell.accessoryView = alwaysShowPlayerBar;
            }
        }
        if (indexPath.row == 10) {
            cell.textLabel.text = @"Enable Extra Speed Options";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *enableExtraSpeedOptions = [[UISwitch alloc] initWithFrame:CGRectZero];
            [enableExtraSpeedOptions addTarget:self action:@selector(toggleExtraSpeedOptions:) forControlEvents:UIControlEventValueChanged];
            enableExtraSpeedOptions.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableExtraSpeedOptions"];
            cell.accessoryView = enableExtraSpeedOptions;
        }
    }
    return cell;
}

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath {
    UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"Notice" message:@"You must enable 'Disable Related Videos In Overlay' and 'Hide Overlay Quick Actions' in YouTube Reborn settings to use 'Always Show Player Bar'" preferredStyle:UIAlertControllerStyleAlert];

    [alertError addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:alertError animated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {        
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 11;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupVideoOptionsControllerView];
    [self.tableView reloadData];
}

@end

@implementation VideoOptionsController(Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupVideoOptionsControllerView {
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        } else {
            self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        }
    }
}

- (void)toggleEnableNoVideoAds:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableNoVideoAds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableNoVideoAds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleEnableBackgroundPlayback:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableBackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableBackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAllowHDOnCellularData:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAllowHDOnCellularData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAllowHDOnCellularData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAutoFullScreen:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAutoFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAutoFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoEndscreenPopups:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoEndscreenPopups"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoEndscreenPopups"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoInfoCards:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoInfoCards"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoInfoCards"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableVideoAutoPlay:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableVideoAutoPlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableVideoAutoPlay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleDisableDoubleTapToSkip:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisableDoubleTapToSkip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisableDoubleTapToSkip"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHideChannelWatermark:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHideChannelWatermark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHideChannelWatermark"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleHidePlayerBarHeatwave:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHidePlayerBarHeatwave"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHidePlayerBarHeatwave"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleAlwaysShowPlayerBar:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kAlwaysShowPlayerBarVTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kAlwaysShowPlayerBarVTwo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)toggleExtraSpeedOptions:(UISwitch *)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kEnableExtraSpeedOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kEnableExtraSpeedOptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end