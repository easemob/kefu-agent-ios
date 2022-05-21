//
//  ConversationsController.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "KFConversationsController.h"
#import "HConversationViewController.h"
#import "WaitQueueViewController.h"
#import "CustomerViewController.h"
#import "HomeViewController.h"
#import "EMSetMaxServiceNumberController.h"
#import "DXTipView.h"
#import "ChatViewController.h"
#import "EMHeaderImageView.h"
#import "UINavigationItem+Margin.h"
#import "UIAlertView+KFAdd.h"
#import "UIImageView+EMWebCache.h"
#import "HDSelectButton.h"

@interface KFConversationsController ()<ConversationTableControllerDelegate,UIScrollViewDelegate,HDClientDelegate, DXTableViewControllerDelegate>
{
    HDSelectButton *_conversationButton;
    HDSelectButton *_waitButton;
    DXTipView *_unreadWaitLabel;
    EMHeaderImageView *_headImageView;
    
    UIScrollView *_scrollView;
    HConversationViewController *_conversationController;
    CustomerViewController *_customerViewController;
    
    int _conversationCount;
}

@property (nonatomic, strong) UILabel* currentlabel;
@property (nonatomic, strong) UIButton *maxServiceNumButton;

@property (nonatomic, copy) NSString *tipNumber;

@end

@implementation KFConversationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initNoti];
    [self setNav];
    [self setupView];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    if (![[HDClient sharedClient].currentAgentUser.roles containsString:@"admin"]) {
        [KFManager sharedInstance].needShowSuperviseTip = NO;
    }
}

- (void)setNav {
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.rightBarButtonItem = self.rightItem;
    [self showSetMaxSession:[HDClient sharedClient].currentAgentUser.allowAgentChangeMaxSessions];
    
}
- (void)initNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMaxServiceNumber)
                                                 name:NOTIFICATION_SET_MAX_SERVICECOUNT
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMaxServiceNumber)
                                                 name:NOTIFICATION_UPDATE_SERVICECOUNT
                                               object:nil];
    
    [[HDClient sharedClient] removeDelegate:self];
    [[HDClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_conversationController clearSeesion];
}


#pragma mark - HDClientDelegate

//会话被管理员关闭
- (void)conversationClosedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    [self reloadDataWithSessionId:serviceSessionId];
}

- (void)transferScheduleAccept:(NSString *)sessionId {
    NSLog(@"会话转接被确认");
    [self showHint:@"会话已转接"];
    [self reloadDataWithSessionId:sessionId];
}

- (void)transferScheduleRefuse:(NSString *)sessionId {
    [self showHint:@"对方已拒绝转接"];
}


//- (void)transferScheduleRequest:(NSString *)sessionId {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新会话" message:@"收到一个转接会话,是否接受?" delegate:[KFManager sharedInstance].appDelegate cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
//    alert.sessionId = sessionId;
//    alert.tag = kTransferScheduleRequestTag;
//    [alert show];
//}

- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {

    [self reloadDataWithSessionId:serviceSessionId];
    // 会话自动关闭的时候 清除 本地存储会话助手状态
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if ([def valueForKey:serviceSessionId]) {
        [def removeObjectForKey:serviceSessionId];
        [def synchronize];
    }

}

//会话被管理员转接
- (void)conversationTransferedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    [self reloadDataWithSessionId:serviceSessionId];
}

- (void)reloadDataWithSessionId:(NSString *)sessionId {
    if ([sessionId isEqualToString:[KFManager sharedInstance].currentSessionId]) {
        [[KFManager sharedInstance].curChatViewConvtroller.navigationController popViewControllerAnimated:YES];
       
        
    }
    [_conversationController loadData];
}

//连接状态改变
- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    [_conversationController connectionStateDidChange:aConnectionState];
}

//最后一条消息改变
- (void)conversationLastMessageChanged:(HDMessage *)message {
    if (message.chatType == HDChatTypeCustomer) {
        [_customerViewController loadData];
    }
}

- (void)agentUsersListChange {
    [_customerViewController loadData];
}


- (void)dealloc
{
    _conversationController.dxDelegate = nil;
    _customerViewController.customerController.dxDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData {
    [_conversationController loadData];
    [_customerViewController loadData];
}

#pragma mark - property

- (void)setupView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    _conversationController = [[HConversationViewController alloc] initWithStyle:UITableViewStylePlain type:HDConversationAccessed];
    _conversationController.dxDelegate = self;
    _conversationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _conversationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _conversationController.showSearchBar = YES;
    _conversationController.conDelegate = self;
    
    [_scrollView addSubview:_conversationController.view];
    
    _customerViewController = [[CustomerViewController alloc] init];
    _customerViewController.customerController.dxDelegate = self;
    _customerViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    _customerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _customerViewController.conDelegate = self;
    
    [_scrollView addSubview:_customerViewController.view];
}

- (UIButton *)maxServiceNumButton
{
    if (_maxServiceNumButton == nil) {
        _maxServiceNumButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 44)];
        [_maxServiceNumButton addTarget:self action:@selector(maxServiceNumButtonAvtion:) forControlEvents:UIControlEventTouchUpInside];
        [_maxServiceNumButton setImage:[UIImage imageNamed:@"visitor_icon_setting_Text2"] forState:UIControlStateNormal];
    }
    return _maxServiceNumButton;
}

- (UILabel*)currentlabel
{
    if (_currentlabel == nil) {
        _currentlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _currentlabel.textColor = [UIColor whiteColor];
        _currentlabel.font = [UIFont systemFontOfSize:15];
        _currentlabel.textAlignment = NSTextAlignmentRight;
        _currentlabel.text = @"(0/0)";
    }
    return _currentlabel;
}

- (UIBarButtonItem*)headerViewItem
{
    if (_headerViewItem == nil) {
        _headerViewItem = [[UIBarButtonItem alloc] initWithCustomView:self.headImageView];
    }
    return _headerViewItem;
}

- (EMHeaderImageView *)headImageView
{
    return [KFManager sharedInstance].headImageView;
}

- (UIView *)titleView
{
    if (_titleView == nil) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth-160)/2, 27, 160, 30)];
        _titleView.layer.borderColor = [UIColor whiteColor].CGColor;
        _titleView.layer.cornerRadius = 4.f;
        _titleView.layer.borderWidth = 1.f;
        _titleView.layer.masksToBounds = YES;
        _titleView.backgroundColor = [UIColor clearColor];
        
        __weak typeof(self) weakSelf = self;
        
        _conversationButton = [[HDSelectButton alloc] initWithFrame:CGRectMake(0, 0, 80, _titleView.frame.size.height)];
        _conversationButton.layer.masksToBounds = YES;
        [_conversationButton setTitle:@"进行中" forState:UIControlStateNormal];
        [_conversationButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_conversationButton addTarget:self action:@selector(conversationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_conversationButton addTarget:self action:@selector(multipleTap:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [_conversationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_conversationButton setTitleColor:kNavBarBgColor forState:UIControlStateSelected];
        [_conversationButton setBackgroundImage:[weakSelf.view imageWithColor:kNavBarBgColor size:_conversationButton.frame.size] forState:UIControlStateNormal];
        [_conversationButton setBackgroundImage:[weakSelf.view imageWithColor:[UIColor whiteColor] size:_conversationButton.frame.size] forState:UIControlStateSelected];
//        _conversationButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
        _conversationButton.tag = 100;
        _conversationButton.selected = YES;
        
        [_titleView addSubview:_conversationButton];
        
        _waitButton = [[HDSelectButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_conversationButton.frame), 0, 80, _titleView.frame.size.height)];
        _waitButton.layer.masksToBounds = YES;
        [_waitButton setTitle:@"客服" forState:UIControlStateNormal];
        [_waitButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_waitButton addTarget:self action:@selector(waitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_waitButton addTarget:self action:@selector(multipleTap:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [_waitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_waitButton setTitleColor:kNavBarBgColor forState:UIControlStateSelected];
        [_waitButton setBackgroundImage:[self.view imageWithColor:kNavBarBgColor size:_conversationButton.frame.size] forState:UIControlStateNormal];
        [_waitButton setBackgroundImage:[self.view imageWithColor:[UIColor whiteColor] size:_conversationButton.frame.size] forState:UIControlStateSelected];
//        _waitButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
        _waitButton.selected = NO;
        [_titleView addSubview:_waitButton];
        
        _unreadWaitLabel = [[DXTipView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_waitButton.frame) - 25, 5, 30, 20)];
        _unreadWaitLabel.tipNumber = nil;
        _unreadWaitLabel.tipImageNamed = @"tip_red";
        [_waitButton addSubview:_unreadWaitLabel];
        
        [self conversationButtonAction:_conversationButton];
    }
    
    return _titleView;
}

- (UIBarButtonItem*)rightItem
{
    if (_rightItem == nil) {
        if (KScreenWidth > 320.f) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.maxServiceNumButton.width + self.currentlabel.width + 5, self.maxServiceNumButton.height)];
            [view addSubview:self.currentlabel];
            self.maxServiceNumButton.left = self.currentlabel.width + 5;
            [view addSubview:self.maxServiceNumButton];
            _rightItem = [[UIBarButtonItem alloc] initWithCustomView:view];
        } else {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.maxServiceNumButton.width, self.maxServiceNumButton.height)];
            [view addSubview:self.maxServiceNumButton];
            _rightItem = [[UIBarButtonItem alloc] initWithCustomView:view];
        }
        
    }
    return _rightItem;
}

#pragma mark - item action

- (void)conversationButtonAction:(id)sender
{
    [_customerViewController.customerController searhResignAndSearchDisplayNoActive];
    _waitButton.selected = NO;
    _conversationButton.selected = YES;
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)waitButtonAction:(id)sender
{
    _conversationButton.selected = NO;
    _waitButton.selected = YES;
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_scrollView.frame), 0) animated:NO];
}

-(void)multipleTap:(id)sender withEvent:(UIEvent*)event {
    
    UITouch* touch = [[event allTouches] anyObject];
    
    UIButton *btn = (UIButton *)sender;
    if (touch.tapCount == 2) {
        if (btn.tag == 100) {
            [_conversationController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
            [_customerViewController.customerController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

- (void)searchItemAction:(id)sender
{
}

- (void)maxServiceNumButtonAvtion:(id)sender
{
    EMSetMaxServiceNumberController *setMaxServiceNumber = [[EMSetMaxServiceNumberController alloc] init];
    [self.navigationController pushViewController:setMaxServiceNumber animated:YES];
}

- (void)headImageItemAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
}

#pragma mark - ConversationTableControllerDelegate
- (void)ConversationPushIntoChat:(UIViewController *)viewController
{
    if (_conversationButton.selected) {
        ((ChatViewController*)viewController).notifyNumber = _tipNumber;
    } else {
        [_customerViewController.customerController searhResign];
    }
    [viewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x<CGRectGetWidth(scrollView.frame)) {
        [_customerViewController.customerController searhResignAndSearchDisplayNoActive];
        _waitButton.selected = NO;
        _conversationButton.selected = YES;
    } else {
        _conversationButton.selected = NO;
        _waitButton.selected = YES;
    }
}

#pragma makr - DXTableViewControllerDelegate
- (void)dxtableView:(DXTableViewController *)aTableVC userInfo:(NSDictionary *)userInfo {
    
    __block void(^reloadData)(void) = ^(void){
        if ([aTableVC isKindOfClass:[HConversationViewController class]]) {
                 if ([[userInfo valueForKey:@"unreadCount"] intValue] > 0) {
                     [_conversationButton showUnReadStamp];
                 }else {
                     [_conversationButton hiddenUnReadStamp];
                 }
             }else if ([aTableVC isKindOfClass:[CustomerController class]]) {
                 if ([[userInfo valueForKey:@"unreadCount"] intValue] > 0) {
                     [_waitButton showUnReadStamp];
                 }else {
                     [_waitButton hiddenUnReadStamp];
                 }
             }
    };
    
    hd_dispatch_main_async_safe(^{
        reloadData();
    });
}

#pragma mark - HDClientDelegate

//管理员是否允许坐席修改最大接入数,【管理员不受此限制】
- (void)showSetMaxSession:(BOOL)show {
    if (![[HDClient sharedClient].currentAgentUser.roles containsString:@"admin"]) {
//        _currentlabel.hidden = !show;
        _maxServiceNumButton.hidden = !show;
    }
}


#pragma mark - notifaction
- (void)updateMaxServiceNumber
{
    _currentlabel.text = [NSString stringWithFormat:@"(%@/%@)",@([KFManager sharedInstance].curConversationNum),@((int)[HDClient sharedClient].currentAgentUser.maxServiceSessionCount)];
}

@end
