//
//  NotifyViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "NotifyViewController.h"
#import "EMHeaderImageView.h"
#import "SRRefreshView.h"
#import "EMSearchDisplayController.h"
#import "DXTableViewCellTypeConversation.h"
#import "NSDate+Formatter.h"
#import "RealtimeSearchUtil.h"
#import "UINavigationItem+Margin.h"
#import "HomeViewController.h"
#import "UIAlertView+AlertBlock.h"
#import "NotiDetailViewController.h"
#define kNotifyPageSize 15

@interface HDNotifyCell : DXTableViewCellTypeConversation

@property (nonatomic, strong) UIImageView *unreadView;

- (void)setNotifyModel:(HDNotifyModel*)model;

@end

@implementation HDNotifyCell

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.unreadView.left = self.width - 30;
    self.unreadView.top = CGRectGetMaxY(self.timeLabel.frame) + 10;
}

- (UIImageView*)unreadView
{
    if (_unreadView == nil) {
        _unreadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _unreadView.image = [UIImage imageNamed:@"tips_popup_right_EllipseCopy"];
        [self addSubview:_unreadView];
    }
    return _unreadView;
}

- (void)setNotifyModel:(HDNotifyModel*)model
{
    self.timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:model.createDateTime/1000] minuteDescription];
    self.headerImageView.image = [UIImage imageNamed:@"default_customer_avatar"];
    self.titleLabel.text = model.name;
    self.contentLabel.text = model.summary;
    if (model.status == HDNoticeStatusUnread) {
        self.unreadView.hidden = NO;
    } else {
        self.unreadView.hidden = YES;
    }
}

@end

@interface NotifyViewController ()<SRRefreshDelegate,UISearchBarDelegate,UISearchDisplayDelegate,SWTableViewCellDelegate>
{
    NSInteger _page;
}

@property (strong, nonatomic) EMHeaderImageView *headerImageView;
@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (assign, nonatomic) BOOL hasMore;
@property (assign, nonatomic) BOOL isRefresh;
@property (assign, nonatomic) NSInteger totalCount;
@property (strong, nonatomic) UIView *headerView;
@property(nonatomic,strong) UIView *tabMenuView;

@property (nonatomic, strong) UIButton *readButton;
@property (nonatomic, strong) UIButton *unreadButton;
@property (nonatomic, strong) UIButton *markButton;
@property(nonatomic,strong) UIButton *seeReadButton; //查看已读

@property(nonatomic,strong) NSMutableArray *unreadDataSource; //未读数据
@property(nonatomic,assign) NSInteger unreadTotleCount;
@end


@implementation NotifyViewController
{
    NSMutableArray *_menus;
    HDNoticeStatus _currentStatus;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.height -= 44;
    [self loadData];
}

- (void)loadData {
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.tabMenuView];
//    self.tableView.tableHeaderView = self.headerView;
    self.tableView.top = self.tabMenuView.height;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kTableViewBgColor;
    
    _currentTabMenu = HDNoticeTypeAll;
    _currentStatus = HDNoticeStatusUnread;
    _page = 1;
    [self loadDataWithPage:_page type:HDNoticeTypeAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIView *)tabMenuView {
    if (_tabMenuView == nil) {
        _menus = [NSMutableArray array];
        NSArray *titles = @[@"全部通知",@"管理员通知",@"系统通知"];
        _tabMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        _tabMenuView.backgroundColor = [UIColor whiteColor];
        CGFloat btnWidth = KScreenWidth/3;
        for (int i=0; i<3 ; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, 44);
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            btn.tag = i+HDNoticeTypeAll;
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:RGBACOLOR(0x4d, 0x4d, 0x4d, 1) forState:UIControlStateNormal];
            [btn setTitleColor:RGBACOLOR(40, 162, 239, 1) forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(menuTabClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i==0) {
                btn.selected = YES;
            }
            [_menus addObject:btn];
            [_tabMenuView addSubview:btn];
        }
    }
    
    return _tabMenuView;
}

- (void)menuTabClicked:(UIButton *)btn {
    [self tabMenuSelected:btn.tag];
    
}

#pragma mark - getter


- (NSString *)title1 {
    if(_seeReadButton == nil || !self.seeReadButton.selected) {
        return @"未读通知";
    } else {
        return @"已读通知";
    }
}

- (UIBarButtonItem*)headerViewItem
{
    if (_headerViewItem == nil) {
        _headerViewItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
    }
    return _headerViewItem;
}
- (UIBarButtonItem *)readButtonItem {
    if (_readButtonItem == nil) {
        _seeReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _seeReadButton.frame = CGRectMake(0, 10,100, 44);
        [_seeReadButton setTitle:@"查看已读" forState:UIControlStateNormal];
        [_seeReadButton setTitle:@"查看未读" forState:UIControlStateSelected];
        [_seeReadButton setTitleColor:RGBACOLOR(40, 162, 239, 1) forState:UIControlStateNormal];
        [_seeReadButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_seeReadButton addTarget:self action:@selector(seeReadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _readButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_seeReadButton];
    }
    return _readButtonItem;
}

- (void)seeReadButtonClicked:(UIButton *)btn { //rightItem
    HomeViewController *homeVC = [HomeViewController HomeViewController];
    if (!btn.selected) {
        homeVC.title = @"已读通知";
        _unreadDataSource = [NSMutableArray arrayWithArray:self.dataSource];
        _unreadTotleCount = self.totalCount;
        [self readAction];
    } else {
        homeVC.title = @"未读通知";
        [self unReadAction];
    }
    
    btn.selected = !btn.selected;
}

- (UIButton *)markButton {
    if (_markButton == nil) {
        _markButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _markButton.frame = CGRectMake(KScreenWidth-150, 0,150, 30);
        [_markButton setTitle:@"全部标记为已读" forState:UIControlStateNormal];
        [_markButton setTitleColor:RGBACOLOR(40, 162, 239, 1) forState:UIControlStateNormal];
        [_markButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_markButton addTarget:self action:@selector(markReadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _markButton;
}

- (EMHeaderImageView*)headerImageView
{
    return [KFManager sharedInstance].headImageView;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _headerView.backgroundColor = RGBACOLOR(229, 229, 229, 1);
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        tip.font = [UIFont systemFontOfSize:12.0];
        tip.tag = 12306;
        tip.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@(0),@(0)];
        [_headerView addSubview:tip];
        [_headerView addSubview:self.markButton];
    }
    return _headerView;
}

- (void)setHeaderNumWithtotle:(NSInteger)totle {
    UILabel *lb = [self.headerView viewWithTag:12306];
    lb.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@([self.dataSource count]),@(totle)];
}

#pragma mark - action

- (void)headImageItemAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([self.dataSource count] == 0) {
            if (_totalCount > 0) {
                return 0;
            } else {
                return 1;
            }
        }
        return [self.dataSource count];
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerView.height;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HDNotifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDNotifyCell"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[HDNotifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HDNotifyCell"];
            cell.rightUtilityButtons = nil;
        }
        if ([self.dataSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HDNotifyCellNormal"];
            cell.textLabel.text = @"没有记录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        cell.delegate = self;
        HDNotifyModel *model = [self.dataSource objectAtIndex:indexPath.row];
        [cell setNotifyModel:model];
        return cell;
    } else if (indexPath.section == 1) {
        DXLoadmoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversationLoadMore"];
        if (cell == nil) {
            cell = [[DXLoadmoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationLoadMore"];
        }
        [cell setHasMore:_hasMore];
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return DEFAULT_CHAT_CELLHEIGHT;
    } else {
        if (_hasMore) {
            return DEFAULT_CHAT_CELLHEIGHT;
        } else {
            return 0;
        }
    }
}

//进入详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([self.dataSource count] == 0) {
            return;
        }
        HDNotifyModel *model = [self.dataSource objectAtIndex:indexPath.row];
        NotiDetailViewController *detail = [NotiDetailViewController new];
        detail.model = model;
        [detail setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:detail animated:YES];
        if (_currentStatus == HDNoticeStatusUnread) {
            [self markNotifyModelAsRead:model];
        }
    } else {
        if (_hasMore) {
            _page++;
            [self loadDataWithPage:_page type:_currentTabMenu];
        }
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    _page = 1;
    [self loadDataWithPage:_page type:_currentTabMenu];
    [_slimeView endRefresh];
}

#pragma mark - LoadData

- (void)loadDataWithPage:(NSInteger)page type:(HDNoticeType)notiType
{
    if (_isRefresh) {
        return;
    }
    WEAK_SELF
    _isRefresh = YES;
    [self showHintNotHide:@"加载中..."];
    [[HDClient sharedClient].notiManager asyncGetNoticeWithPageIndex:page pageSize:kNotifyPageSize status:_currentStatus type:notiType prameters:nil completion:^(NSArray<HDNotifyModel *> *notices, HDError *error) {
        [MBProgressHUD  hideAllHUDsForView:weakSelf.view animated:YES];
        weakSelf.isRefresh = NO;
        if (nil == error) {
            if (page == 1) {
                [self.dataSource removeAllObjects];
            }
            if (_currentStatus == HDNoticeStatusUnread) {
                _totalCount = [HDClient sharedClient].notiManager.unreadCount;
            } else { //已读通知
                _totalCount = [HDClient sharedClient].notiManager.totalCount - [HDClient sharedClient].notiManager.unreadCount;
            }
            [self.dataSource addObjectsFromArray:notices];
            if (weakSelf.totalCount > [weakSelf.dataSource count]) {
                weakSelf.hasMore = YES;
            } else {
                weakSelf.hasMore = NO;
            }
            if (_currentStatus == HDNoticeStatusUnread) {
                [weakSelf resetBadge];
            }
            
            [UIView performWithoutAnimation:^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }];
            [self setHeaderNumWithtotle:_totalCount];
        }
        
    }];
}

- (void)resetBadge {
    [self setUnreadCount:[HDClient sharedClient].notiManager.unreadCount];
}

#pragma mark - Action
- (void)readAction
{
    _readButton.selected = YES;
    _unreadButton.selected = NO;
    _page = 1;
    _currentStatus = HDNoticeStatusRead;
    _isRefresh = NO;
    [self loadDataWithPage:_page type:_currentTabMenu];
    _markButton.hidden = YES;
}

- (void)unReadAction
{
    
    _unreadButton.selected = YES;
    _readButton.selected = NO;
    _page = 1;
    _currentStatus = HDNoticeStatusUnread;
    [self loadDataWithPage:_page type:_currentTabMenu];
    _markButton.hidden = NO;
}

- (void)markReadAction
{
    if ([self.dataSource count] == 0) {
        [self showHint:@"没有未读通知"];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要全部标记为已读?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)markNotifyModelAsRead:(HDNotifyModel*)model
{
    if (model.status == HDNoticeStatusRead) {
        return;
    }
    WEAK_SELF
    [[HDClient sharedClient].notiManager asyncPUTMarkNoticeASReadWithUnreadNoticeIds:@[model.activityId] parameters:nil completion:^(id responseObjcet, HDError *error) {
        if (!error) {
            model.status = HDNoticeStatusRead;
            [weakSelf.dataSource removeObject:model];
            [weakSelf setHeaderNumWithtotle:[HDClient sharedClient].notiManager.unreadCount];
            [weakSelf.tableView reloadData];
            NSLog(@"标记成功");
            [weakSelf resetBadge];
        } else {
            NSLog(@"标记失败");
        }
    }];
    
}

#pragma mark 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1) {
        return;
    }
    
    NSMutableArray *activityIds = [NSMutableArray array];
    for (HDNotifyModel *model in self.dataSource) {
        if (model.status == HDNoticeStatusUnread) {
            [activityIds addObject:model.activityId];
        }
    }
    [self showHintNotHide:@"正在全部标记已读..."];
    WEAK_SELF
    [[HDClient sharedClient].notiManager asyncPUTMarkNoticeASReadWithUnreadNoticeIds:activityIds parameters:nil completion:^(id responseObjcet, HDError *error) {
        [weakSelf hideHud];
        if (error == nil) {
            [weakSelf.dataSource removeAllObjects];
            [weakSelf setHeaderNumWithtotle:[HDClient sharedClient].notiManager.unreadCount];
            [weakSelf.tableView reloadData];
            [weakSelf resetBadge];
            _page = 0;
            [weakSelf showHint:@"标记成功"];
        } else {
            [weakSelf showHint:@"标记失败"];
        }
    }];
}

#pragma makr - private

- (void)tabMenuSelected:(HDNoticeType)type {
//    [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    _currentTabMenu = type;
    _page = 1;
    [self loadDataWithPage:_page type:type];
    switch (type) {
        case HDNoticeTypeAll:{
            ((UIButton *)_menus[0]).selected = YES;
            ((UIButton *)_menus[1]).selected = NO;
            ((UIButton *)_menus[2]).selected = NO;
            break;
        }
        case HDNoticeTypeAgent: {
            ((UIButton *)_menus[0]).selected = NO;
            ((UIButton *)_menus[1]).selected = YES;
            ((UIButton *)_menus[2]).selected = NO;
            break;
        }
        case HDNoticeTypeSystem: {
            ((UIButton *)_menus[0]).selected = NO;
            ((UIButton *)_menus[1]).selected = NO;
            ((UIButton *)_menus[2]).selected = YES;
            break;
        }
        default:
            break;
    }
}

- (void)setUnreadCount:(NSInteger)count
{
    NSString *badgeStr = nil;
    if (count != 0 && count < 100) {
        badgeStr = [NSString stringWithFormat:@"%d",(int)count];
    }else if (count >= 100){
        badgeStr = @"99+";
    }
    self.tabBarItem.badgeValue = badgeStr;
    [[HomeViewController HomeViewController] setNotifyWithBadgeValue:count];
}


@end
