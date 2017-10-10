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

#import "UIImageView+EMWebCache.h"

@interface KFConversationsController ()<ConversationTableControllerDelegate,UIScrollViewDelegate,HDClientDelegate>
{
    UIButton *_conversationButton;
    UIButton *_waitButton;
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
}

- (void)setNav {
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.rightBarButtonItem = self.rightItem;
    
}
- (void)initNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMaxServiceNumber) name:NOTIFICATION_SET_MAX_SERVICECOUNT object:nil];
    
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

- (void)transferScheduleAccept:(NSString *)serviceSessionId {
    NSLog(@"会话转接被确认");
    [self reloadDataWithSessionId:serviceSessionId];
}

- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {
    [self reloadDataWithSessionId:serviceSessionId];
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
    [_conversationController conversationLastMessageChanged:message];
    if (message.chatType == HDChatTypeCustomer) {
        [_customerViewController loadData];
    }
}

- (void)agentUsersListChange {
    [_customerViewController loadData];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData {
    [_conversationController loadData];
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
    _conversationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _conversationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _conversationController.showSearchBar = YES;
    _conversationController.conDelegate = self;
    
    [_scrollView addSubview:_conversationController.view];
    
    _customerViewController = [[CustomerViewController alloc] init];
    _customerViewController.view.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    _customerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _customerViewController.conDelegate = self;
    
    [_scrollView addSubview:_customerViewController.view];
}

- (UIButton*)maxServiceNumButton
{
    if (_maxServiceNumButton == nil) {
        _maxServiceNumButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 44)];
        [_maxServiceNumButton addTarget:self action:@selector(maxServiceNumButtonAvtion:) forControlEvents:UIControlEventTouchUpInside];
        [_maxServiceNumButton setImage:[UIImage imageNamed:@"visitor_icon_setting_Text2"] forState:UIControlStateNormal];
        [_maxServiceNumButton setImage:[UIImage imageNamed:@"visitor_icon_setting_Text2"] forState:UIControlStateSelected];
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
        _currentlabel.text = @"0/0";
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

- (EMHeaderImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[EMHeaderImageView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageItemAction:)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
    }
    return _headImageView;
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
        
        _conversationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, _titleView.frame.size.height)];
        _conversationButton.layer.masksToBounds = YES;
        [_conversationButton setTitle:@"进行中" forState:UIControlStateNormal];
        [_conversationButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_conversationButton addTarget:self action:@selector(conversationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_conversationButton addTarget:self action:@selector(multipleTap:withEvent:) forControlEvents:UIControlEventTouchDownRepeat];
        [_conversationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_conversationButton setTitleColor:kNavBarBgColor forState:UIControlStateSelected];
        [_conversationButton setBackgroundImage:[self.view imageWithColor:kNavBarBgColor size:_conversationButton.frame.size] forState:UIControlStateNormal];
        [_conversationButton setBackgroundImage:[self.view imageWithColor:[UIColor whiteColor] size:_conversationButton.frame.size] forState:UIControlStateSelected];
//        _conversationButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0];
        _conversationButton.tag = 100;
        _conversationButton.selected = YES;
        [_titleView addSubview:_conversationButton];
        
        _waitButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_conversationButton.frame), 0, 80, _titleView.frame.size.height)];
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
    [_conversationController searhResignAndSearchDisplayNoActive];
    _conversationButton.selected = NO;
    _waitButton.selected = YES;
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(_scrollView.frame), 0) animated:NO];
}

-(void)multipleTap:(id)sender withEvent:(UIEvent*)event {
    
    UITouch* touch = [[event allTouches] anyObject];
    
    UIButton *btn = (UIButton*)sender;
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
        [_conversationController searhResign];
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
        [_conversationController searhResignAndSearchDisplayNoActive];
        _conversationButton.selected = NO;
        _waitButton.selected = YES;
    }
}

#pragma mark - notifaction
- (void)updateMaxServiceNumber
{
    _currentlabel.text = [NSString stringWithFormat:@"(%@/%@)",@([KFManager sharedInstance].curConversationNum),@((int)[HDClient sharedClient].currentAgentUser.maxServiceSessionCount)];
}

@end
