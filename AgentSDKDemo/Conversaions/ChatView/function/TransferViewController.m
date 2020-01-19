//
//  TransferViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/9/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "TransferViewController.h"
#import "EMSearchDisplayController.h"
#import "CustomerChatViewController.h"
#import "DXTableViewCellType1.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "JNGroupViewController.h"

@interface TransferViewController ()<UISearchBarDelegate, SRRefreshDelegate,JNGroupViewDelegate>
{
    NSString *_curRemoteAgentId;
    BOOL _isRefresh;
    int _customerUnreadcount;
    UILabel *_resultLabel;
    HDConversation *_curModel;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EMSearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) UIView *headerButtonView;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *tagButton;

@property (nonatomic, strong) JNGroupViewController *jn;

@end

@implementation TransferViewController

@synthesize searchBar = _searchBar;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view addSubview:self.headerButtonView];
    self.tableView.top = self.headerButtonView.height;
    self.tableView.height -= self.headerButtonView.height;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addSubview:self.slimeView];
    
    [self loadData];
    self.title = @"选择转接客服";
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _jn = [[JNGroupViewController alloc] init];
    _jn.serviceSessionId = _conversation.sessionId;
    _jn.tableView.top = self.headerButtonView.height;
    _jn.tableView.height -= self.headerButtonView.height - 20;
    _jn.view.left = KScreenWidth;
    _jn.delegate = self;
    [self.view addSubview:_jn.view];
}

#pragma mark - getter

- (UIView *)headerButtonView
{
    if (_headerButtonView == nil) {
        _headerButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 45)];
        _headerButtonView.backgroundColor = [UIColor whiteColor];
        [_headerButtonView addSubview:self.infoButton];
        [_headerButtonView addSubview:self.tagButton];
        [_headerButtonView addSubview:self.selectView];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 0.5f, KScreenWidth, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_headerButtonView addSubview:line];
    }
    return _headerButtonView;
}

- (UIView *)selectView
{
    if (_selectView == nil) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 1.5f, KScreenWidth/2, 1.f)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25.f, 0, KScreenWidth/2 - 50.f, 1.5f)];
        line.backgroundColor = RGBACOLOR(25, 163, 255, 1);
        [_selectView addSubview:line];
    }
    return _selectView;
}

- (UIButton *)infoButton
{
    if (_infoButton == nil) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _infoButton.frame = CGRectMake(0, 0, KScreenWidth/2, 40.f);
        [_infoButton setTitle:@"客服" forState:UIControlStateNormal];
        [_infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

- (UIButton *)tagButton
{
    if (_tagButton == nil) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 40.f);
        [_tagButton setTitle:@"技能组" forState:UIControlStateNormal];
        [_tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_tagButton addTarget:self action:@selector(tagButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tagButton;
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

/*
- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2.5, 0, self.tableView.frame.size.width-5, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.backgroundImage = [self.view imageWithColor:RGBACOLOR(0xef, 0xef, 0xf4, 1) size:_searchBar.frame.size];
    _searchBar.tintColor = RGBACOLOR(0x4d, 0x4d, 0x4d, 1);
    self.tableView.tableHeaderView = _searchBar;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) - 0.5, self.tableView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:line];
    self.tableView.tableHeaderView = _searchBar;
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
}
*/

#pragma mark - private

#pragma mark - action
- (void)infoButtonAction
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.left = 0;
        _jn.view.left = KScreenWidth;
        self.selectView.left = 0.f;
    }];
}

- (void)tagButtonAction
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.left = -KScreenWidth;
        _jn.view.left = 0;
        self.selectView.left = KScreenWidth/2;
    }];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jinengAction
{
    JNGroupViewController *jn = [[JNGroupViewController alloc] init];
    jn.serviceSessionId = _conversation.sessionId;
    [self.navigationController pushViewController:jn animated:YES];
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

    if (cell == nil) {
        cell = [[DXTableViewCellType1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
    }

    HDConversation *model =  [self.dataSource objectAtIndex:indexPath.row];
    model.unreadCount = 0;
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

    HDConversation *model = [self.dataSource objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定将该会话转接给%@吗？",model.chatter.nicename] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
    _curModel = model;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1000) {
        [self showHintNotHide:@"转接中..."];
        WEAK_SELF
        HDConversationManager *conversation = [[HDConversationManager alloc] initWithSessionId:_conversation.sessionId];
        [conversation transferConversationWithRemoteUserId:_curModel.chatter.agentId completion:^(id responseObject, HDError *error) {
            [weakSelf hideHud];
            if (!error) {
//                [weakSelf showHint:@""];
//                if ([HDClient sharedClient].currentAgentUser.serviceSessionTransferPreScheduleEnable) {
//                    [self showHint:@"已转接,等待对方接受"];
//                } else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationHasTransfered)]) {
                        [self.delegate conversationHasTransfered];
                    }
//                }
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            } else {
                [weakSelf showHint:@"转接失败"];
            }
        }];
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
    [self showHintNotHide:@"加载中..."];
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
            if (!_dataSourceDic) {
                _dataSourceDic = [NSMutableDictionary dictionary];
            }
            for (HDConversation *customer in customers) {
                customer.searchWord = [ChineseToPinyin pinyinFromChineseString:customer.chatter.nicename];
                _customerUnreadcount += customer.unreadCount;
                if ([customer.chatter.status isEqualToString:USER_STATUS_DISABLE]) {
                    continue;
                }
                if ([customer.chatter.onLineState isEqualToString:USER_STATE_ONLINE]) {
                    [weakSelf.dataSource insertObject:customer atIndex:0];
                } else {
                    [weakSelf.dataSource addObject:customer];
                }
                [weakSelf.dataSourceDic setObject:customer forKey:customer.chatter.agentId];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
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

#pragma mark - JNGroupViewDelegate

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:self];
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
