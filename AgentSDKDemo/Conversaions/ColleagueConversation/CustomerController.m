//
//  CustomerController.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
#import "CustomerController.h"
#import "EMSearchDisplayController.h"
#import "CustomerChatViewController.h"
#import "DXTableViewCellType1.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"

@interface CustomerController ()<UISearchBarDelegate, SRRefreshDelegate>
{
    NSString *_curRemoteAgentId;
    BOOL _isRefresh;
    int _customerUnreadcount;
    UILabel *_resultLabel;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EMSearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) SRRefreshView *slimeView;

@end

@implementation CustomerController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addSubview:self.slimeView];
    
    [self loadData];
    self.tableView.backgroundColor = kTableViewBgColor;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DXTableViewCellType1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[DXTableViewCellType1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
    }
    
    HDConversation *model = [self.dataSource objectAtIndex:indexPath.row];

    [cell setModel:model];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_CHAT_CELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
    }
    
    CustomerChatViewController *customerChat = [[CustomerChatViewController alloc] init];
    HDConversation *model = [self.dataSource objectAtIndex:indexPath.row];
    customerChat.title = model.chatter.nicename;
    customerChat.userModel = model.chatter;
    customerChat.model = model;
    
    _customerUnreadcount -= model.unreadCount;
    model.unreadCount = 0;

    _curRemoteAgentId = model.chatter.agentId;
    if ([self.delegate respondsToSelector:@selector(CustomerPushIntoChat:)]) {
        [self.delegate CustomerPushIntoChat:customerChat];
    }
}

#pragma mark - data

- (void)loadData
{
    @synchronized(self) {
        if (_isRefresh) {
            return;
        }
        _isRefresh = YES;
    }
    [self showHudInView:self.view hint:@"加载中..."];
    WEAK_SELF
    
    
    __block void(^reloadData)(void) = ^(void){
        if ([NSThread isMainThread]) {
            [weakSelf.tableView reloadData];
        }else {
            hd_dispatch_main_async_safe(^{
                [weakSelf.tableView reloadData];
            });
        }
    };
    
    [[HDClient sharedClient].chatManager asyncGetAllCustomersCompletion:^(NSArray<HDConversation *> *customers, HDError *error) {
        [weakSelf hideHud];
        if (!weakSelf) {
            return;
        }
        _isRefresh = NO;
        if (!error) {
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSourceDic removeAllObjects];
            _customerUnreadcount = 0;
            if (!weakSelf.dataSourceDic) {
                weakSelf.dataSourceDic = [NSMutableDictionary dictionary];
            }
            for (HDConversation *customer in customers) {
                customer.searchWord = [ChineseToPinyin pinyinFromChineseString:customer.chatter.nicename];
                _customerUnreadcount += customer.unreadCount;
                [weakSelf.dataSourceDic setObject:customer forKey:customer.chatter.agentId];
            }
            [super dxDelegateAction:@{@"unreadCount": [NSNumber numberWithInt:_customerUnreadcount]}];
            self.dataSource = customers.mutableCopy;
            reloadData();
        }
        else{
            reloadData();
        }
    }];
}

- (NSMutableArray *)sortWithArray:(NSMutableArray *)array {
    return [array sortedArrayUsingComparator:^NSComparisonResult(HDConversation *obj1, HDConversation *obj2) {
        return obj1.chatter.agentStatus > obj2.chatter.agentStatus;
    }].mutableCopy;
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
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    searchBar.userInteractionEnabled = NO;
//    [self performSelector:@selector(searchBarEnabled) withObject:nil afterDelay:2.0];
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
#pragma mark - public

- (void)searhResignAndSearchDisplayNoActive
{
    _searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [_searchBar setShowsCancelButton:NO animated:YES];
    _searchController.active = NO;
    [_searchBar resignFirstResponder];
}

#pragma mark - notification
- (void)agentListChanged:(NSNotification*)notification
{
    [self loadData];
}


- (void)lastMessageChange:(NSNotification*)notification
{
    WEAK_SELF
    hd_dispatch_main_async_safe(^{
        HDMessage *message = notification.object;
        HDConversation *model = [weakSelf.dataSourceDic objectForKey:message.toUser.userId];
        if (model) {
            model.lastMessage = message;
            [weakSelf.dataSource removeObject:model];
            [weakSelf.dataSource insertObject:model atIndex:0];
            [weakSelf.tableView reloadData];
        }
    });
}

#pragma mark - private
- (void)clearSession
{
    _curRemoteAgentId = @"";
}

- (void)searhResign
{
    [_searchBar resignFirstResponder];
}

- (void)sort
{
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

@end
