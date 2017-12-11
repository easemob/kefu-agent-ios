//
//  WaitQueueViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/2/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "WaitQueueViewController.h"

#import "DXTableViewCellTypeConversation.h"
#import "DXUserWaitTableViewCell.h"
#import "EMSearchDisplayController.h"
#import "ChatViewController.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "UIAlertView+AlertBlock.h"
#import "EMHeaderImageView.h"
#import "UINavigationItem+Margin.h"
#import "HistoryOptionViewController.h"

@interface WaitQueueViewController ()<UISearchBarDelegate, UISearchDisplayDelegate,SRRefreshDelegate,EMChatManagerDelegate,HistoryOptionDelegate>
{
    BOOL _isRefresh;
    int _unreadcount;
    NSInteger _waitUnreadcount;
    BOOL _hasMore;
    UILabel *_resultLabel;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableDictionary *dataSourceDic;

@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) EMHeaderImageView *headerImageView;
@property (strong, nonatomic) UIView *networkStateView;
@property (strong, nonatomic) UILabel *curLabel;

@end

@implementation WaitQueueViewController

@synthesize searchBar = _searchBar;
@synthesize searchController = _searchController;

@synthesize showSearchBar = _showSearchBar;
@synthesize isFetchedData = _isFetchedData;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = HDConversationWaitQueues;
        _page = -1;
        _isFetchedData = NO;
        _dataSourceDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _hasMore = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableHeaderView = self.curLabel;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_type != HDConversationAccessed) {
        _page = 1;
    }
    [self.tableView addSubview:self.slimeView];//f5f7fa
    self.tableView.backgroundColor = kTableViewBgColor;
    
    [self setUpSearchBar];
    [self.view addSubview:_searchBar];
    self.tableView.top += _searchBar.height;
    self.tableView.height -= _searchBar.height;
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIBarButtonItem*)optionItem
{
    if (_optionItem == nil) {
        UIButton *optionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [optionButton setImage:[UIImage imageNamed:@"agents_icon_shai_Text2"] forState:UIControlStateNormal];
        [optionButton setImage:[UIImage imageNamed:@"agents_icon_shai_Text2"] forState:UIControlStateSelected];
        optionButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [optionButton addTarget:self action:@selector(optionAction) forControlEvents:UIControlEventTouchUpInside];
        _optionItem = [[UIBarButtonItem alloc] initWithCustomView:optionButton];
    }
    return _optionItem;
}

- (UILabel*)curLabel
{
    if (_curLabel == nil) {
        _curLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _curLabel.backgroundColor = RGBACOLOR(229, 229, 229, 1);
        _curLabel.font = [UIFont systemFontOfSize:12.f];
        _curLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _curLabel.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@(0),@(0)];
    }
    return _curLabel;
}

- (UIBarButtonItem*)headerViewItem
{
    if (_headerViewItem == nil) {
        _headerViewItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
        _headerImageView.userInteractionEnabled = YES;
    }
    return _headerViewItem;
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

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"当前网络连接失败";
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    [_searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    _searchBar.placeholder = @"搜索用户昵称";
    _searchBar.backgroundImage = [self.view imageWithColor:[UIColor whiteColor] size:_searchBar.frame.size];
    _searchBar.tintColor = RGBACOLOR(0x4d, 0x4d, 0x4d, 1);
    [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg"] forState:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateHighlighted];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateSelected];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) - 0.5, self.tableView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:line];
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    
    WEAK_SELF
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        DXUserWaitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversationNoAccessSearch"];
        if (cell == nil) {
            cell = [[DXUserWaitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationNoAccessSearch"];
        }
        
        if ([weakSelf.searchController.resultsSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有待接入会话";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        
        HDWaitUser *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[HDWaitUser class]]) {
            cell.timeLabel.textColor = RGBACOLOR(248, 103, 6, 1);
            [cell setModel:model];
        }
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return DEFAULT_CHAT_CELLHEIGHT;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [weakSelf.searchController.searchBar endEditing:YES];
        
        if ([weakSelf.searchController.resultsSource count] <= indexPath.row) {
            return;
        }
        HDWaitUser *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要接入此会话吗" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        [alert showAlertViewWithCompleteBlock:^(NSInteger btnIndex){
            if (btnIndex == 1) {
                __weak HDWaitUser *weakmodel = model;
                [[HDClient sharedClient].waitManager asyncFetchUserWaitQueuesWithUserId:model.userWaitQueueId completion:^(id responseObject, HDError *error) {
                    if (!error) {
                        [weakSelf refreshSearchView];
                        [weakSelf.dataSource removeObject:weakmodel];
                        [weakSelf.tableView reloadData];
                        _waitUnreadcount--;
                        [weakSelf setUnreadCount:_waitUnreadcount];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[KFManager sharedInstance].wait loadData];
                        });
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"接入会话失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }];
            }
        }];
        [alert show];
    }];

    
}

#pragma mark - action

- (void)optionAction
{
    HistoryOptionViewController *historyOption = [[HistoryOptionViewController alloc] init];
    historyOption.optionDelegate = self;
    historyOption.type = EMWaitingQueueType;
    [self.navigationController pushViewController:historyOption animated:YES];
}

- (void)headImageItemAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
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
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadData];
    [_slimeView endRefresh];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(tableView == self.searchDisplayController.searchResultsTableView){
        if ([self.searchController.resultsSource count] == 0) {
            return 1;
        }
        return [self.searchController.resultsSource count];
    }
    if (section == 0) {
        if ([self.dataSource count] == 0) {
            return 1;
        }
        return [self.dataSource count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DXUserWaitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversationNoAccess"];
        if (cell == nil) {
            cell = [[DXUserWaitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationNoAccess"];
        }
        
        if ([self.dataSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有待接入会话";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        
        HDWaitUser *model = [self.dataSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[HDWaitUser class]]) {
            cell.timeLabel.textColor = RGBACOLOR(248, 103, 6, 1);
            [cell setModel:model];
        }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if ([self.dataSource count] <= indexPath.row) {
            return;
        }
        HDWaitUser *model = [self.dataSource objectAtIndex:indexPath.row];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要接入此会话吗" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
        [alert showAlertViewWithCompleteBlock:^(NSInteger btnIndex){
            if (btnIndex == 1) {
                __weak HDWaitUser *weakmodel = model;
                WEAK_SELF
                [[HDClient sharedClient].waitManager asyncFetchUserWaitQueuesWithUserId:model.userWaitQueueId completion:^(id responseObject, HDError *error) {
                    if (error == nil) {
                        [weakSelf refreshSearchView];
                        [weakSelf.dataSource removeObject:weakmodel];
                        [weakSelf.tableView reloadData];
                        _waitUnreadcount--;
                        [weakSelf setUnreadCount:_waitUnreadcount];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[KFManager sharedInstance].wait loadData];
                        });
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"接入会话失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];

                    }
                }];
            }
        }];
        [alert show];
    }
    if (indexPath.section == 1) {
        if (_hasMore) {
            [self loadMore];
        }
    }
}

#pragma mark - data

- (void)loadMore
{
    if (!_isRefresh) {
        @synchronized(self) {
            if (_isRefresh) {
                return;
            }
            _isRefresh = YES;
        }
    } else {
        return;
    }
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    
    [[HDClient sharedClient].waitManager asyncGetWaitQueuesWithPage:_page pageSize:hPageLimit parameters:nil completion:^(NSArray<HDWaitUser *> *waitUsers, HDError *error) {
        [weakSelf hideHud];
        _isRefresh = NO;
        if (error == nil) {
            for (HDWaitUser *model in waitUsers) {
                model.searchWord = [ChineseToPinyin pinyinFromChineseString:model.userName];
                [weakSelf.dataSource addObject:model];
            }
            _waitUnreadcount = [HDClient sharedClient].waitManager.waitUsersNum;
            weakSelf.curLabel.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[self.dataSource count]),@(_waitUnreadcount)];
            _page++;
            if ([HDClient sharedClient].waitManager.waitUsersNum < hPageLimit) {
                _hasMore = NO;
            } else {
                if (_waitUnreadcount > [weakSelf.dataSource count]) {
                    _hasMore = YES;
                } else {
                    _hasMore = NO;
                }
            }
            [weakSelf.tableView reloadData];
        }
    }];
    
}

- (void)loadData
{
    @synchronized(self) {
        if (_isRefresh) {
            return;
        }
    }
    _isRefresh = YES;
    _page = 1;
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    [[HDClient sharedClient].waitManager asyncGetWaitQueuesWithPage:_page pageSize:hPageSize parameters:nil completion:^(NSArray<HDWaitUser *> *waitUsers, HDError *error) {
        [weakSelf hideHud];
        _isRefresh = NO;
        if (!error) {
            [weakSelf.dataSource removeAllObjects];
            for (HDWaitUser *waitUser in waitUsers) {
                waitUser.searchWord = [ChineseToPinyin pinyinFromChineseString:waitUser.userName];
                [weakSelf.dataSource addObject:waitUser];
            }
            _waitUnreadcount = [HDClient sharedClient].waitManager.waitUsersNum;
            weakSelf.curLabel.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[self.dataSource count]),@(_waitUnreadcount)];
            [weakSelf setUnreadCount:_waitUnreadcount];
            _page++;
            if ([waitUsers count] < hPageLimit) {
                _hasMore = NO;
            } else {
                if (_waitUnreadcount > [self.dataSource count]) {
                    _hasMore = YES;
                } else {
                    _hasMore = NO;
                }
            }
            [weakSelf.tableView reloadData];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
    
}

- (void)clearSeesion
{
//    [[DXMessageManager shareManager] setCurSessionId:@""];
}

- (void)searhResignAndSearchDisplayNoActive
{
    _searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [_searchBar setShowsCancelButton:NO animated:YES];
    _searchController.active = NO;
    [_searchBar resignFirstResponder];
}

- (void)searhResign
{
    [_searchBar resignFirstResponder];
}

#pragma mark - HistoryOptionDelegate

- (void)historyOptionWithParameters:(NSMutableDictionary *)parameters
{
    [self.navigationController popViewControllerAnimated:YES];
    [parameters setObject:@(1) forKey:@"page"];
    [parameters setObject:@(hPageLimit) forKey:@"per_page"];
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    [[HDClient sharedClient].waitManager asyncScreenWaitQueuesWithParameters:parameters completion:^(NSArray<HDWaitUser *> *users, HDError *errror) {
        [weakSelf hideHud];
        if (errror == nil) {
            [weakSelf.dataSource removeAllObjects];
            for (HDWaitUser *user in users) {
                user.searchWord = [ChineseToPinyin pinyinFromChineseString:user.userName];
                [weakSelf.dataSource addObject:user];
            }
            _waitUnreadcount = [HDClient sharedClient].waitManager.waitUsersNum;
            weakSelf.curLabel.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[self.dataSource count]),@(_waitUnreadcount)];
            [weakSelf setUnreadCount:_waitUnreadcount];
            _hasMore = NO;
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        return;
    }
    WEAK_SELF
    NSString *search = [ChineseToPinyin pinyinFromChineseString:searchText];
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)search collationStringSelector:@selector(searchWord) resultBlock:^(NSArray *results) {
        if (results) {
            if ([results count] > 0) {
                if ([[results objectAtIndex:0] isKindOfClass:[HDWaitUser class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.searchController.resultsSource removeAllObjects];
                        [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                        [weakSelf.searchController.searchResultsTableView reloadData];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.searchController.resultsSource removeAllObjects];
                    [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                    [weakSelf.searchController.searchResultsTableView reloadData];
                });
            }
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarEnabled
{
    _searchBar.userInteractionEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@""];
        }
    }
    return YES;
}

- (void)sort
{
    if (_type == HDConversationAccessed) {
        if ([self.dataSource count] > 0) {
            for (int i = 0; i < [self.dataSource count]; i ++) {
                HDConversation *model = [self.dataSource objectAtIndex:i];
                for (int j = i + 1; j < [self.dataSource count]; j ++) {
                    HDConversation *model2 = [self.dataSource objectAtIndex:j];
                    if (model2.lastMessage.localTime > model.lastMessage.localTime) {
                        model = model2;
                    }
                }
                [self.dataSource removeObject:model];
                [self.dataSource insertObject:model atIndex:i];
            }
        }
    }
}

#pragma makr - private

- (void)setUnreadCount:(NSInteger)count
{
    if (count <= 0) {
        [[HomeViewController HomeViewController] setWaitQueueWithBadgeValue:nil];
    } else {
        if (count>=100) {
            [[HomeViewController HomeViewController] setWaitQueueWithBadgeValue:[NSString stringWithFormat:@"%@",@"99+"]];
        } else {
            [[HomeViewController HomeViewController] setWaitQueueWithBadgeValue:[NSString stringWithFormat:@"%@",@(count)]];
        }
    }
}

- (void)refreshSearchView
{
    if (self.searchBar.text.length == 0) {
        return;
    }
    WEAK_SELF
    NSString *search = [ChineseToPinyin pinyinFromChineseString:self.searchBar.text];
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)search collationStringSelector:@selector(searchWord) resultBlock:^(NSArray *results) {
        if (results) {
            if ([results count] > 0) {
                if ([[results objectAtIndex:0] isKindOfClass:[HDWaitUser class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.searchController.resultsSource removeAllObjects];
                        [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                        [weakSelf.searchController.searchResultsTableView reloadData];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.searchController.resultsSource removeAllObjects];
                    [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                    [weakSelf.searchController.searchResultsTableView reloadData];
                });
            }
        }
    }];
}
@end
