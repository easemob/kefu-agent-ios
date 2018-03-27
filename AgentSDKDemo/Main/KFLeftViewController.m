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
#import "KFLeftViewItem.h"
#import "KFLeftItemCell.h"
#import "KFSwitchTypeButton.h"


#define kBottomButtonHeight 49

typedef NS_ENUM(NSUInteger, AgentMenuTag) {
    AgentMenuTagHome = 0,
    AgentMenuTagHistory,
    AgentMenuTagUpdate,
    AgentMenuTagSet
};

@interface KFLeftViewController () <UITableViewDelegate,UITableViewDataSource,EMPickerSaveDelegate>
@property (nonatomic, strong) LeftMenuHeaderView *headerView;
@property (nonatomic, strong) EMPickerView *pickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KFSwitchTypeButton *switchBtn;
@property (nonatomic, strong) NSArray *adminDatasrouce;
@property (nonatomic, strong) NSArray *nomalDatasource;
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
    [kNotiCenter addObserver:self selector:@selector(setMonitTip:) name:KFSuperviseNoti object:nil];
    self.view.backgroundColor = RGBACOLOR(26, 26, 26, 1);
    
    [self setupHeadView];
    [self.view addSubview:self.switchBtn];
    [self switchIsAdminType:NO];
    if (![self isAdminAccountLogin]) {
        [self.switchBtn setHidden:YES];
    }
    [self.view addSubview:self.tableView];
}

- (void)setupHeadView {
    _headerView = [[LeftMenuHeaderView alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 70)];
    self.tableView.tableHeaderView = _headerView;
    _statusArray = @[@"空闲",@"忙碌",@"离开",@"隐身"];
    [_headerView.onlineButton addTarget:self
                                 action:@selector(onlineButtonAction)
                       forControlEvents:UIControlEventTouchUpInside];
}

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

- (void)switchButtonAction:(UIButton *)btn {
    _adminModel = !_adminModel;
    [self switchIsAdminType:_adminModel];
}

- (void)switchIsAdminType:(BOOL)isAdminType {
    [self.switchBtn setIsAdminType:isAdminType];
    [self.switchBtn showUnreadTip:[KFManager sharedInstance].needShowSuperviseTip];
    [self showTipImage:[KFManager sharedInstance].needShowSuperviseTip];
    if (isAdminType) {
        _menuData = self.adminDatasrouce;
        [self.leftDelegate adminMenuClickWithIndex:AgentMenuTagHome];
    }else {
        _menuData = self.nomalDatasource;
        [self.leftDelegate menuClickWithIndex:AgentMenuTagHome];
    }
    
    [self.tableView reloadData];
}

- (void)refreshUnreadView:(NSInteger)badgeNumber
{
    KFLeftViewItem *item = item = self.nomalDatasource[0];
    [item setUnreadCount:(int)badgeNumber];
    [self.tableView reloadData];
}

- (BOOL)isAdminAccountLogin {
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    NSRange range = [user.roles rangeOfString:@"admin"];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

- (void)setMonitTip:(NSNotification *)noti {
    [self.switchBtn showUnreadTip:[KFManager sharedInstance].needShowSuperviseTip];
    [self showTipImage:[KFManager sharedInstance].needShowSuperviseTip];
}

- (void)showTipImage:(BOOL)isShow {
    KFLeftViewItem *item = self.adminDatasrouce[self.adminDatasrouce.count - 1];
    [item setIsShowTipImage:isShow];
    [self.tableView reloadData];
}

- (KFSwitchTypeButton *)switchBtn {
    if (!_switchBtn) {
        
        _switchBtn = [[KFSwitchTypeButton alloc] initWithNomalImage:[UIImage imageNamed:@"Shape"]
                                                          nomalText:@"管理员模式"
                                                      selectedImage:[UIImage imageNamed:@"Shape"]
                                                       selectedText:@"客服模式"];
        
        _switchBtn.frame = CGRectMake(0, KScreenHeight - kBottomButtonHeight - iPhoneXBottomHeight, self.view.width, kBottomButtonHeight);
        [_switchBtn addTarget:self action:@selector(switchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _switchBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat statusBarHeight = isIPHONEX ? 44: 20;
        CGRect frame = CGRectMake(0, statusBarHeight, self.view.width, self.view.height - statusBarHeight - kBottomButtonHeight);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor  = RGBACOLOR(26, 26, 26, 1);
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSArray *)adminDatasrouce {
    if (!_adminDatasrouce) {
        _adminDatasrouce = [self isAppStoreType] ? [self appStoreAdminItems] : [self nomalAdminItems];
    }
    return _adminDatasrouce;
}

- (NSArray *)nomalDatasource {
    if (!_nomalDatasource) {
        _nomalDatasource = [self isAppStoreType] ? [self appStoreAgentItems] : [self nomalAgentItems];
    }
    return _nomalDatasource;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KFLeftItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    if (cell == nil) {
        cell = [[KFLeftItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMenuCell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.f];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = RGBACOLOR(26, 26, 26, 1);
    }
    cell.model = [_menuData objectAtIndex:indexPath.row];
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
                [weakHud setLabelText:@"系统将不再为您分配新会话"];
                [weakHud hide:YES afterDelay:3.0];
            }
        } else {
            [weakHud setLabelText:@"修改失败"];
            [weakHud hide:YES afterDelay:0.5];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSArray *)appStoreAgentItems {
    return @[
             [KFLeftViewItem name:@"主页" image:[UIImage imageNamed:@"main_tab_icon_ongoing_1"]],
             [KFLeftViewItem name:@"历史" image:[UIImage imageNamed:@"main_tab_icon_histroy"]],
             [KFLeftViewItem name:@"设置" image:[UIImage imageNamed:@"main_tab_icon_friend"]]
             ];
}

- (NSArray *)appStoreAdminItems {
    return @[
             [KFLeftViewItem name:@"主页" image:[UIImage imageNamed:@"icon_manager_home"]],
             [KFLeftViewItem name:@"现场管理" image:[UIImage imageNamed:@"icon_manager_supervise"]],
             [KFLeftViewItem name:@"实时监控" image:[UIImage imageNamed:@"icon_manager_realtime"]],
             [KFLeftViewItem name:@"告警记录" image:[UIImage imageNamed:@"alarmsRecord"]]
             ];
}

- (NSArray *)nomalAgentItems {
    return @[
             [KFLeftViewItem name:@"主页" image:[UIImage imageNamed:@"main_tab_icon_ongoing_1"]],
             [KFLeftViewItem name:@"历史" image:[UIImage imageNamed:@"main_tab_icon_histroy"]],
             [KFLeftViewItem name:@"检查更新" image:[UIImage imageNamed:@"main_tab_icon_update_1"]],
             [KFLeftViewItem name:@"设置" image:[UIImage imageNamed:@"main_tab_icon_friend"]]
             ];
}

- (NSArray *)nomalAdminItems {
    return @[
             [KFLeftViewItem name:@"主页" image:[UIImage imageNamed:@"icon_manager_home"]],
             [KFLeftViewItem name:@"现场管理" image:[UIImage imageNamed:@"icon_manager_supervise"]],
             [KFLeftViewItem name:@"实时监控" image:[UIImage imageNamed:@"icon_manager_realtime"]],
             [KFLeftViewItem name:@"告警记录" image:[UIImage imageNamed:@"alarmsRecord"]]
             ];
}



- (BOOL)isAppStoreType {
#if APPSTORE
    return YES;
#else
    return NO;
#endif
}

@end

