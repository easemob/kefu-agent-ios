//
//  KFLeftViewController.m
//  EMCSApp
//
//  Created by afanda on 5/15/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFLeftViewController.h"
#import "LeftMenuHeaderView.h"
#import "DXTipView.h"
#import "EMPickerView.h"
#import "HomeViewController.h"
#import "KFBaseNavigationController.h"
#import "HistoryConversationsController.h"
#import "AdminInforViewController.h"
typedef NS_ENUM(NSUInteger, AgentMenuTag) {
    AgentMenuTagHome = 0,
    AgentMenuTagHistory,
    AgentMenuTagUpdate,
    AgentMenuTagSet
};

@interface KFLeftViewController () <UITableViewDelegate,UITableViewDataSource,EMPickerSaveDelegate>
@property (nonatomic, strong) LeftMenuHeaderView *headerView;
@property (nonatomic, strong) DXTipView *unreadConversationLabel;
@property (nonatomic, strong) EMPickerView *pickerView;
@property (nonatomic, strong) UIButton *switchButton;
@property(nonatomic,strong) UITableView *tableView;
@end

@implementation KFLeftViewController
{
    NSArray *_menuData;
    NSArray *_statusArray;
    BOOL _adminModel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}
- (void)setup {
    _adminModel = NO;
#if APPSTORE
    _menuData = @[@"主页",@"历史"/*,@"访客中心",@"文件",@"检查更新"*/,@"设置"];
#else
    //================appstore start=================
#if IS_KEFU_HUASHENG
    _menuData = @[@"主页",@"历史",@"设置"];
#else
    _menuData = @[@"主页",@"历史"/*,@"访客中心",@"文件"*/,@"检查更新",@"设置"];
#endif
    //================appstore end=================
#endif
    
    self.view.backgroundColor = RGBACOLOR(26, 26, 26, 1);
    _headerView = [[LeftMenuHeaderView alloc] init];
     self.tableView.tableHeaderView = _headerView;
    _statusArray = @[@"空闲",@"忙碌",@"离开",@"隐身"];
    [_headerView.onlineButton addTarget:self action:@selector(onlineButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    _unreadConversationLabel = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _unreadConversationLabel.tipNumber = nil;
    _unreadConversationLabel.tipImageNamed = @"tip_red";
    
    //设置管理员模式
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    if (user) {
        NSRange range = [user.roles rangeOfString:@"admin"];
        if (range.location != NSNotFound) {
//            [self.tableView addSubview:self.switchButton];
        }
    }
    [self.view addSubview:self.tableView];
}

- (UIButton*)switchButton
{
    if (_switchButton == nil) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchButton.frame = CGRectMake(20, KScreenHeight - 60, 160, 40);
        [_switchButton setImage:[UIImage imageNamed:@"Shape"] forState:UIControlStateNormal];
        _switchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 120);
        [_switchButton setTitle:@"管理员模式" forState:UIControlStateNormal];
        [_switchButton setTitle:@"客服模式" forState:UIControlStateSelected];
        [_switchButton addTarget:self action:@selector(switchAdminView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor  = RGBACOLOR(26, 26, 26, 1);
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_menuData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMenuCell"];
    }
    cell.textLabel.text = [_menuData objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17.f];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = RGBACOLOR(26, 26, 26, 1);
    if (indexPath.row == 0) {
        if (!_adminModel) { //不是管理员
            _unreadConversationLabel.top = (cell.height - _unreadConversationLabel.height)/2;
            _unreadConversationLabel.left = self.view.width - _unreadConversationLabel.width - 10;
            [cell addSubview:_unreadConversationLabel];
            if (_unreadConversationLabel.tipNumber == nil) {
                _unreadConversationLabel.hidden = YES;
            } else {
                _unreadConversationLabel.hidden = NO;
            }
        } else {
            _unreadConversationLabel.hidden = YES;
        }
    }
    if (indexPath.row == 0 ) {
        cell.imageView.image = [UIImage imageNamed:@"main_tab_icon_ongoing_1"];
    } else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"main_tab_icon_histroy"];
    } else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"main_tab_icon_update_1"];
    } else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"main_tab_icon_friend"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
#if !APPSTORE
    if (!_adminModel) { //点击"更新",只有更新动作
        if (indexPath.row == AgentMenuTagUpdate) {
            [self.leftDelegate menuClickWithIndex:indexPath.row];
            return;
        }
    }
#else
#endif
    __block BOOL isAdmin = _adminModel;
    WEAK_SELF
    HomeViewController *homeController = [HomeViewController HomeViewController];
    KFBaseNavigationController *navigationController = [[KFBaseNavigationController alloc] initWithRootViewController:homeController];
    if (isAdmin) {
        if (self.leftDelegate && [self.leftDelegate respondsToSelector:@selector(adminMenuClickWithIndex:)]) {
            [weakSelf.leftDelegate adminMenuClickWithIndex:indexPath.row];
        }
    } else {
        if (self.leftDelegate && [self.leftDelegate respondsToSelector:@selector(menuClickWithIndex:)]) {
            [weakSelf.leftDelegate menuClickWithIndex:indexPath.row];
        }
    }
    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}

#pragma mark-----pickerview
- (void)onlineButtonAction
{
    if (_pickerView == nil) {
        _pickerView = [[EMPickerView alloc] initWithDataSource:_statusArray topHeight:64];
        _pickerView.delegate = self;
    }
    if (self.leftDelegate && [self.leftDelegate respondsToSelector:@selector(onlineStatusClick:)]) {
        [self.leftDelegate onlineStatusClick:_pickerView];
    }
}

#pragma mark - EMPickerSaveDelegate
- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"修改用户在线状态..." toView:self.view];
    HDOnlineStatus status = index;
    __weak MBProgressHUD *weakHud = hud;
    [[HDClient sharedClient].setManager updateOnLineStatusWithStatus:status completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusChanged" object:nil];
            if (status == HDOnlineStatusOnline) {
                [_headerView.onlineButton setTitle:@"空闲" forState:UIControlStateNormal];
                [weakHud hide:YES];
            } else {
                [_headerView.onlineButton setTitle:value forState:UIControlStateNormal];
                [hud setMode:MBProgressHUDModeCustomView];
                [weakHud setLabelText:[NSString stringWithFormat:@"切换到%@状态时，系统将不再为您分配新会话，进行中会话可以继续。",value]];
                [weakHud hide:YES afterDelay:3.0];
            }
        } else {
            [weakHud setLabelText:@"修改失败"];
            [weakHud hide:YES afterDelay:0.5];
        }
    }];
    
}

- (void)refreshUnreadView:(NSInteger)badgeNumber
{
    if (badgeNumber) {
        if (badgeNumber == 0) {
            _unreadConversationLabel.tipNumber = nil;
            _unreadConversationLabel.hidden = YES;
        } else {
            _unreadConversationLabel.hidden = NO;
            if (badgeNumber>=100) {
                _unreadConversationLabel.tipNumber = [NSString stringWithFormat:@"99+"];
            } else {
                _unreadConversationLabel.tipNumber = [NSString stringWithFormat:@"%@",@(badgeNumber)];
            }
        }
    } else {
        _unreadConversationLabel.tipNumber = nil;
        _unreadConversationLabel.hidden = YES;
    }
    [self reloadData];
}

- (void)switchAdminView
{
    self.switchButton.selected = !self.switchButton.selected;
    _adminModel = !_adminModel;
    if (_adminModel) { //管理员模式
        _menuData = @[@"主页"/*,@"当前会话",@"历史会话",@"统计查询"*/];
        [self.leftDelegate adminMenuClickWithIndex:AgentMenuTagHome];
    } else {
        [self.leftDelegate menuClickWithIndex:AgentMenuTagHome];
#if APPSTORE
        _menuData = @[@"主页",@"历史",@"设置"];
#else
        
        //================appstore start=================
#if IS_KEFU_HUASHENG
        _menuData = @[@"主页",@"历史",@"设置"];
#else
        _menuData = @[@"主页",@"历史"/*,@"访客中心",@"文件"*/,@"检查更新",@"设置"];
#endif
        //================appstore end=================
#endif
        
    }
    [self reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)reloadData {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
