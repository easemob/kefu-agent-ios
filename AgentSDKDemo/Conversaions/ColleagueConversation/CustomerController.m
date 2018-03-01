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

@interface CustomerController ()<UISearchBarDelegate, UISearchDisplayDelegate,SRRefreshDelegate>
{
    NSString *_curRemoteAgentId;
    BOOL _isRefresh;
    int _customerUnreadcount;
    UILabel *_resultLabel;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableDictionary *dataSourceDic;

@property (strong, nonatomic) SRRefreshView *slimeView;

@end

@implementation CustomerController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self setUpSearchBar];
    
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

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
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
    // Return the number of rows in the section.
    if(tableView == self.searchDisplayController.searchResultsTableView){
        if ([self.searchController.resultsSource count] == 0) {
            return 1;
        }
        return [self.searchController.resultsSource count];
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DXTableViewCellType1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[DXTableViewCellType1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchController.resultsSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有搜索到……";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
    }
    
    HDConversation *model = tableView != self.searchDisplayController.searchResultsTableView ? [self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];

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
    HDConversation *model = tableView != self.searchDisplayController.searchResultsTableView ? [self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];
    customerChat.title = model.chatter.nicename;
    customerChat.userModel = model.chatter;
    customerChat.model = model;
    
    _customerUnreadcount -= model.unreadCount;
//    [self setValue:@(_customerUnreadcount) forKey:CUSTOMER_UNREADCOUNT];
    model.unreadCount = 0;
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    _curRemoteAgentId = model.chatter.userId;
    if ([self.delegate respondsToSelector:@selector(CustomerPushIntoChat:)]) {
        [self.delegate CustomerPushIntoChat:customerChat];
    }
//    [self.navigationController pushViewController:customerChat animated:YES];
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
                [weakSelf.dataSourceDic setObject:customer forKey:customer.chatter.userId];
            }
            [super dxDelegateAction:@{@"unreadCount": [NSNumber numberWithInt:_customerUnreadcount]}];
            self.dataSource = customers.mutableCopy;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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
    NSString *search = [ChineseToPinyin pinyinFromChineseString:searchText];
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)search collationStringSelector:@selector(searchWord) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@""];
        }
    }
    return YES;
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
    dispatch_async(dispatch_get_main_queue(), ^{
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
