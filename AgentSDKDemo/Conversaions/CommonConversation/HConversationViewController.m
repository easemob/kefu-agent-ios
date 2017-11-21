//
//  ConversationTableController.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "HConversationViewController.h"
#import "DXTableViewCellTypeConversation.h"
#import "DXUserWaitTableViewCell.h"
#import "EMSearchDisplayController.h"
#import "ChatViewController.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "UIAlertView+AlertBlock.h"
#import "AppDelegate.h"
@interface HConversationViewController ()<UISearchBarDelegate, UISearchDisplayDelegate,SRRefreshDelegate,ChatViewControllerDelegate>
{
    BOOL _isRefresh;
    int _unreadcount;
    int _waitUnreadcount;
    int _conversationcount;
    BOOL hasMore;
    UILabel *_resultLabel;
    
    dispatch_queue_t _conversationQueue;
    void* _queueTag;
    
    NSTimeInterval _endConversation;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableDictionary *dataSourceDic;

@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UIView *networkStateView;

@end

@implementation HConversationViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
                         type:(HDConversationType)type
{
    self = [super initWithStyle:style];
    if (self) {
        _type = type;
        _page = -1;
        _showSearchBar = NO;
        _dataSourceDic = [NSMutableDictionary new];
        hasMore = NO;
        _conversationQueue = dispatch_queue_create("com.easemob.kefu.conversation", DISPATCH_QUEUE_SERIAL);
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(_conversationQueue, _queueTag, _queueTag, NULL);
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_type != HDConversationAccessed) {
        _page = 1;
    }
    [self.tableView addSubview:self.slimeView];//f5f7fa
    self.tableView.backgroundColor = kTableViewBgColor;
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



- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    [self isConnect:aConnectionState == HDConnectionConnected];
}


- (void)conversationLastMessageChanged:(HDMessage *)message {
    dispatch_async(_conversationQueue, ^{
        HDConversation *model = [self.dataSourceDic objectForKey:message.sessionId];
        if (model) {
            model.lastMessage = message;
            model.searchWord = model.chatter.nicename;
            if (!message.isSender) {
                 model.unreadCount += 1;
            }
            [self.dataSource removeObject:model];
            [self.dataSource insertObject:model atIndex:0];
            _unreadcount = 0;
            for (HDConversation *model in self.dataSource) {
                _unreadcount += model.unreadCount;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                KFManager *cm = [KFManager sharedInstance];
                [cm setTabbarBadgeValueWithAllConversations:self.dataSource];
                [cm setNavItemBadgeValueWithAllConversations:self.dataSource];
                [self.tableView reloadData];
            });
        }
    });
}

#pragma mark - getter
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

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        self.tableView.tableHeaderView = self.networkStateView;
    }
    else{
        self.tableView.tableHeaderView = self.searchBar;
        [self refreshConversationList];
    }
}

#pragma mark - 

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索名字、昵称";
    [_searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    _searchBar.backgroundImage = [self.view imageWithColor:[UIColor whiteColor] size:_searchBar.frame.size];
    _searchBar.tintColor = RGBACOLOR(0x4d, 0x4d, 0x4d, 1);
    [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg"] forState:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateHighlighted];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateSelected];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) - 0.5, self.tableView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:line];
    self.tableView.tableHeaderView = _searchBar;
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    
}

- (void)setShowSearchBar:(BOOL)showSearchBar
{
    if(showSearchBar != _showSearchBar){
        _showSearchBar = showSearchBar;
        [self setUpSearchBar];
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
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadData];
    [_slimeView endRefresh];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_type == HDConversationAccessed) {
        return 1;
    } else if (_type == HDConversationWaitQueues) {
        if(tableView == self.searchDisplayController.searchResultsTableView){
            return 1;
        }
        return 2;
    } else {
        return 1;
    }
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
    if (_type == HDConversationAccessed) {
        DXTableViewCellTypeConversation *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[DXTableViewCellTypeConversation alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.rightUtilityButtons = nil;
        }
        
        if (tableView != self.searchDisplayController.searchResultsTableView) {
            if ([self.dataSource count] == 0) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
                cell.textLabel.text = @"没有会话";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                return cell;
            }
        } else {
            if ([self.searchController.resultsSource count] == 0) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
                cell.textLabel.text = @"没有会话";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                return cell;
            }
        }
        cell.textLabel.text = @"";
        HDConversation *model = tableView != self.searchDisplayController.searchResultsTableView?[self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[HDConversation class]]) {
            [cell setModel:model];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
        }
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return DEFAULT_CHAT_CELLHEIGHT;
    } else {
        if (hasMore) {
            return DEFAULT_CHAT_CELLHEIGHT;
        } else {
            return 0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataSource count] == 0) {
        return;
    }
    if (_type == HDConversationAccessed) {
        if (_searchBar.isFirstResponder) {
            [_searchBar resignFirstResponder];
        }
        if ([self.conDelegate respondsToSelector:@selector(ConversationPushIntoChat:)]) {
            ChatViewController *chatVC = [[ChatViewController alloc] init];
            chatVC.delegate = self;
            HDConversation *model = tableView != self.searchDisplayController.searchResultsTableView?[self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];
            chatVC.conversationModel = model;
            model.unreadCount = 0;
            dispatch_async(_conversationQueue, ^{
                [self.dataSource removeObjectAtIndex:indexPath.row];
                [self.dataSource insertObject:model atIndex:indexPath.row];
                chatVC.allConversations = self.dataSource;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.conDelegate ConversationPushIntoChat:chatVC];
                    [[KFManager sharedInstance] setTabbarBadgeValueWithAllConversations:self.dataSource];
                });
            });
        }
    }
}


#pragma mark - 刷新UI
- (void)loadData
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
    _page = 1;
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    
    [[HDClient sharedClient].chatManager asyncLoadConversationsWithPage:_page limit:0 completion:^(NSArray *conversations, HDError *error) {
        [weakSelf hideHud];
        @synchronized (weakSelf) {
            _isRefresh = NO;
        }
        if (!error) {
            [self.dataSource removeAllObjects];
            switch (_type) {
                case HDConversationAccessed: {
                    _unreadcount = 0;
                    for (HDConversation *model in conversations) {
                        model.searchWord = [ChineseToPinyin pinyinFromChineseString:model.chatter.nicename];
                        [weakSelf.dataSource insertObject:model atIndex:0];
                        [_dataSourceDic setObject:model forKey:model.sessionId];
                        model.lastMessage.sessionId = model.sessionId;
                    }
                    break;
                }
                default:
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[KFManager sharedInstance] setTabbarBadgeValueWithAllConversations:self.dataSource];
                [weakSelf.tableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)clearSeesion
{
    [[KFManager sharedInstance] setCurrentSessionId:@""];
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
    [self refreshSearchView];
    
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


#pragma mark - chatViewControllerDelegate

- (void)refreshConversationList {
    if (_searchController.active == YES) {
        [self searhResignAndSearchDisplayNoActive];
    }
    [self loadData];
}

#pragma mark - notification
- (void)conversationRefresh:(NSNotification*)notification
{
    [self refreshConversationList];
}

- (void)conversationRefreshAutoEnd:(NSNotification*)notification
{
    NSDictionary *body = notification.object;
    NSString *text = [NSString string];
    
    if ([body objectForKey:@"visitorUser"]) {
        VisitorUserModel *model = [[VisitorUserModel alloc] initWithDictionary:[body objectForKey:@"visitorUser"]];
        if (model.nicename.length > 0) {
            text = [text stringByAppendingString:model.nicename];
        }
    }
    text = [text stringByAppendingString:@" 长时间没有回应,系统已自动关闭回话"];
    NSArray *views = [self.navigationController viewControllers];
    if ([views count] > 0) {
        UIViewController *viewController =  [views objectAtIndex:[views count] - 1];
        MBProgressHUD *hud = [MBProgressHUD showMessag:text toView:viewController.view];
        [hud hide:YES afterDelay:2.0];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showMessag:text toView:self.view];
        [hud hide:YES afterDelay:2.0];
    }
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0];
}

- (void)endChatSession:(NSNotification*)notification
{
    WEAK_SELF
    dispatch_async(_conversationQueue, ^{
        NSString *sessionServiceId = notification.object;
        if ([weakSelf.dataSourceDic objectForKey:sessionServiceId]) {
            HDConversation *model = [weakSelf.dataSourceDic objectForKey:sessionServiceId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataSource removeObject:model];
                [weakSelf.dataSourceDic removeObjectForKey:sessionServiceId];
                [weakSelf.tableView reloadData];
                [weakSelf refreshSearchView];
            });
        }
    });
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

- (void)refreshSearchView
{
    if (self.searchBar.text.length == 0) {
        return;
    }
    NSString *search = [ChineseToPinyin pinyinFromChineseString:self.searchBar.text];
    WEAK_SELF
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:search collationStringSelector:@selector(chatNicename) resultBlock:^(NSArray *results) {
        if (results) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
            if (results.count > 0) {
                for (HDConversation *obj in results) {
                    HDConversation *objc = (HDConversation *)obj;
                    if ([obj isKindOfClass:[HDConversation class]]) {
                        [mDic setObject:objc forKey:objc.conversationId];
                    }
                }
            }
            [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:search collationStringSelector:@selector(chatTruename) resultBlock:^(NSArray *results) {
                if (results) {
                    if (results.count > 0) {
                        for (HDConversation *obj in results) {
                            HDConversation *objc = (HDConversation *)obj;
                            if ([obj isKindOfClass:[HDConversation class]]) {
                                [mDic setObject:objc forKey:objc.conversationId];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.searchController.resultsSource removeAllObjects];
                        [weakSelf.searchController.resultsSource addObjectsFromArray:mDic.allValues];
                        [weakSelf.searchController.searchResultsTableView reloadData];
                    });
                }
            }];
        }
    }];
}
@end
