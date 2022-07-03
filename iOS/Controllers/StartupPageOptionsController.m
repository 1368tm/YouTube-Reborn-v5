#import "StartupPageOptionsController.h"
#import "../TheosLinuxFix.h"
#import "../iOS15Fix.h"

@interface StartupPageOptionsController ()
- (void)setupStartupPageOptionsControllerView;
@end

@implementation StartupPageOptionsController

int selectedIndex;

- (void)loadView {
	[super loadView];
    [self setupStartupPageOptionsControllerView];

    self.title = @"Startup Page Options";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"]) {
        selectedIndex = 0;
    } else {
        selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageIntVTwo"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StartupPageTableViewCell";
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
        } else {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Home";
            if (selectedIndex == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"Explore";
            if (selectedIndex == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"Shorts";
            if (selectedIndex == 2) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"Subscriptions";
            if (selectedIndex == 3) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = @"Library";
            if (selectedIndex == 4) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"kStartupPageIntVTwo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {        
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setupStartupPageOptionsControllerView];
    [self.tableView reloadData];
}

@end

@implementation StartupPageOptionsController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupStartupPageOptionsControllerView {
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
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

@end