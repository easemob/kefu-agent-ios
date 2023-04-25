//
//  HomeViewController.m
//  EMCSApp
//
//  Created by dhc on 15/4/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "HomeViewController.h"
#import "KFBaseNavigationController.h"
#import "KFConversationsController.h"
#import "HistoryConversationsController.h"
#import "CustomerController.h"
#import "NotifyViewController.h"
#import "CustomerViewController.h"
#import "WaitQueueViewController.h"
#import "ChatViewController.h"
#import "KFLeftViewController.h"
#import "AdminHomeViewController.h"
#import "AdminInforViewController.h"
#import "ReminderView.h"
#import "DXTipView.h"
#import "DXUpdateView.h"
#import "HDSuperviseManagerViewController.h"
#import "KFWarningViewController.h"
#import "KFMonitorViewController.h"
#import "KFManager.h"

//在线中的视频
#import "HLeaveMessageViewController.h"
#import "HDAgoraCallManager.h"
#import "KFAnswerView.h"
#import "HDCallViewController.h"

// vec 相关
#import "HDVECAgoraCallManager.h"
#import "KFVECAnswerView.h"
#import "HDVECViewController.h"
#import "HDVECVideoDetailAllModel.h"
#import "HDVECRingingCallModel.h"

//测试相关
#import "HDVECSessionHistoryViewController.h"

#import "KFVECHistoryController.h"
#import "KFWebViewController.h"



@implementation UIImage (tabBarImage)

- (UIImage *)tabBarImage
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        return self;
    }
}

@end

static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

#define kLeftMenuTag 12903
@interface HomeViewController ()<EMChatManagerDelegate,LeftMenuViewDelegate,HDChatManagerDelegate,HDClientDelegate>
{
    UITapGestureRecognizer *_tap;
    BOOL _isEnterChat;
    NSString *_serviceSessionId;
    
    NSInteger _waitVCUnreadCount;
    NSInteger _notifiersVCUnreadCount;
    NSInteger _leaveMessageVCUnreadCount;
    
}


@property (nonatomic, strong) KFConversationsController *conversationsController;
@property (nonatomic, strong) CustomerViewController *customerController;
@property (nonatomic, strong) NotifyViewController *notifyController;
@property (nonatomic, strong) WaitQueueViewController *waitqueueController;
@property (nonatomic, strong) HLeaveMessageViewController *leaveMessageC;

//非管理员
@property (nonatomic, strong) HomeViewController *homeViewController;
@property (nonatomic, strong) HistoryConversationsController *historyController;
@property (nonatomic, strong) KFVECHistoryController *vecHistoryController;
@property (nonatomic, strong) AdminInforViewController *adminController;

//管理员
@property (nonatomic, strong) AdminHomeViewController *adminTypeHomeController;
@property (nonatomic, strong) DXTipView *tipView;
@property (nonatomic, strong) DXTipView *tipCustomerView;
@property (nonatomic, strong) DXTipView *tipNotifyView;
@property (nonatomic, strong) DXTipView *tipLeaveMsgView;

@property (nonatomic, strong) NSDate *lastPlaySoundDate;

@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong)  KFAnswerView *kfAnswerView;

#pragma mark  -------- VEC 相关 ------------
@property (nonatomic, strong)  KFVECAnswerView *kfVecAnswerView;
@property (nonatomic, strong)  UIWindow *alertWindow;

@end

static HomeViewController *homeViewController;

@implementation HomeViewController


+(id) homeViewController
{
    @synchronized(self) {
        if(homeViewController == nil) {
            homeViewController = [[super allocWithZone:NULL] init];
        }
    }
    return homeViewController;
}

+(void) homeViewControllerDestory
{
    @synchronized(self) {
        homeViewController = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self printViewHierarchy:self.tabBarController.view];
    
#pragma mark  -------- VEC 相关 只有坐席空闲状态才能接入 视频 所以 登录成功以后需要设置一下坐席状态 ------------
    // 更改VEC 坐席空闲 才能接视频
    [self performSelector:@selector(delayDo) withObject:nil afterDelay:2.0f];
    
#pragma mark  -------- VEC 相关 只有坐席空闲状态才能接入 视频 所以 登录成功以后需要设置一下坐席状态 end------------
}

- (void)delayDo{
    [[HDVECAgoraCallManager shareInstance] vec_SetVECAgentStatus:HDAgentServiceType_VEC completion:^(id responseObject, HDError * error) {
        NSLog(@"==1=%@",responseObject);
    }];
}

- (void)printViewHierarchy:(UIView *)superView
{
    static uint level = 0;
    for(uint i = 0; i < level; i++){
        printf("\t");
    }
    
    const char *className = NSStringFromClass([superView class]).UTF8String;
    const char *frame = NSStringFromCGRect(superView.frame).UTF8String;
    printf("print,%s:%s\n", className, frame);
    
    ++level;
    for(UIView *view in superView.subviews){
        [self printViewHierarchy:view];
    }
    --level;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[HDClient sharedClient] getExpiredInformationCompletion:^(id responseObject, HDError *error) {
            if (error==nil && responseObject != nil) {
                hd_dispatch_main_async_safe(^(){
                    ReminderView *remindView = [[ReminderView alloc] initWithDictionary:responseObject];
                    [[UIApplication sharedApplication].keyWindow addSubview:remindView];
                });
            }
            
        }];
    });
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(setTotalBadgeValue)
                                               name:NOTIFICATION_UPDATE_ICON_BADGE
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(setConversationWithBadgeValue:)
                                               name:NOTIFICATION_UPDATE_SERVICECOUNT
                                             object:nil];
    
    [self _setupChildrenVC];
    [self registerNotifications];
    [[HDClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_setupChildrenVC {
    
    _conversationsController = [[KFConversationsController alloc] init];
    [KFManager sharedInstance].conversation = _conversationsController;
    [self setupChildVc:_conversationsController title:@"会话" image:@"tabbar_icon_ongoing" selectedImage:@"tabbar_icon_ongoinghighlight" index:0];
    
    _waitqueueController = [[WaitQueueViewController alloc] init];
    [KFManager sharedInstance].wait = _waitqueueController;
    _waitqueueController.showSearchBar = YES;
    _waitqueueController.isFetchedData = YES;
    [self setupChildVc:_waitqueueController title:@"待接入" image:@"tabbar_icon_visitor_Text6" selectedImage:@"tabbar_icon_visitorhighlight_Text6" index:1];
    [_waitqueueController viewDidLoad];
    
    _notifyController = [[NotifyViewController alloc] init];
    [KFManager sharedInstance].noti = _notifyController;
    [self setupChildVc:_notifyController title:@"通知" image:@"tabbar_icon_notice" selectedImage:@"tabbar_icon_crmhighlight" index:2];
    [_notifyController viewDidLoad];
    
    _leaveMessageC = [[HLeaveMessageViewController alloc] init];
    [self setupChildVc:_leaveMessageC
                 title:@"留言"
                 image:@"tabbar_icon_crm"
         selectedImage:@"tabbar_icon_crmhighlight" index:3];
    
    self.view.backgroundColor = RGBACOLOR(25, 25, 25, 1);
    
    self.viewControllers = @[_conversationsController, _waitqueueController, _notifyController,_leaveMessageC];
    
    self.navigationItem.titleView = _conversationsController.titleView;
    self.navigationItem.leftBarButtonItem = _conversationsController.headerViewItem;
    self.navigationItem.rightBarButtonItem = _conversationsController.rightItem;
    
    _tipView = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _tipView.tipNumber = nil;
    
    _tipCustomerView = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _tipCustomerView.tipNumber = nil;
    
    _tipNotifyView = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _tipNotifyView.tipNumber = nil;
    
    _tipLeaveMsgView = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    _tipLeaveMsgView.tipNumber = nil;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
}



/**
 * 初始化子控制器
 */
- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage index:(NSInteger)index
{
    // 设置文字和图片
    vc.navigationItem.title = title;
    vc.tabBarItem.title = title;
    vc.tabBarItem.tag = index;
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 包装一个导航控制器, 添加导航控制器为tabbarcontroller的子控制器
    KFBaseNavigationController *nav = [[KFBaseNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}


#pragma mark - getter

- (UIView *)tapView
{
    if (_tapView == nil) {
        _tapView = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth - kHomeViewLeft, 0, kHomeViewLeft, KScreenHeight)];
        _tapView.userInteractionEnabled = YES;
        [_tapView addGestureRecognizer:_tap];
        _tapView.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:_tapView];
    }
    return _tapView;
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"会话";
        self.navigationItem.titleView = _conversationsController.titleView;
        self.navigationItem.leftBarButtonItem = _conversationsController.headerViewItem;
        self.navigationItem.rightBarButtonItem = _conversationsController.rightItem;
    } else if (item.tag == 1){
        self.title = @"待接入";
        self.navigationItem.titleView = nil;
        self.navigationItem.leftBarButtonItem = _waitqueueController.headerViewItem;
        self.navigationItem.rightBarButtonItem = _waitqueueController.optionItem;
    } else if (item.tag == 2){
        self.title = _notifyController.title1;
        self.navigationItem.titleView =nil;
        self.navigationItem.leftBarButtonItem = _notifyController.headerViewItem;
        self.navigationItem.rightBarButtonItem = _notifyController.readButtonItem;
    } else if (item.tag == 3){
        self.title = @"留言";
        self.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(UITabBarItem*) createBarWithSelectedImageObj:(UIImage*)selectedImage withUnSelectedImg:(UIImage*) unSeletedImage andTitle:(NSString *)title
{
    //移动title，使其隐藏。因为如果bar的title是nil或空字符串，title默认会设为nav bar的title。
    //    barItem.titlePositionAdjustment = UIOffsetMake(0, 20.0);
    UITabBarItem* barItem = [[UITabBarItem alloc] initWithTitle:title image:[unSeletedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //向下移动tab上的图标
    float downMove = 0.0;
    barItem.imageInsets = UIEdgeInsetsMake( downMove,0, -1*downMove, 0);
    return barItem;
}

-(UIImage*) imageAddRedDot:(UIImage*) originalImage
{
    CGRect rect = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    
    CGRect borderRect = CGRectMake(originalImage.size.width-8, 5.0, 8.0, 8.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetFillColorWithColor(context,[UIColor redColor].CGColor);
    
    CGContextFillEllipseInRect (context, borderRect);
    CGContextFillPath(context);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

-(UIImage*)convertViewToImage:(UIView *)v{
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)combine:(UIImage*)leftImage rightImage:(UIImage*)rightImage {
    CGFloat width = leftImage.size.width + 20;
    CGFloat height = leftImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, 0.0);
    
    CGRect rect = CGRectMake(10, 0, leftImage.size.width, leftImage.size.height);
    [leftImage drawInRect:rect];
    
    rect.origin.x += width/2;
    [rightImage drawInRect:CGRectMake(leftImage.size.width - 10, 0, rightImage.size.width, rightImage.size.height)];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imagez;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

- (void)historyBackAction
{
    
}

- (void)settingBackAction
{
    
}

- (void)showLeftView
{
    KFLeftViewController *leftVC = (KFLeftViewController *)self.mm_drawerController.leftDrawerViewController;
    leftVC.leftDelegate =  self;
    [self setTotalBadgeValue];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)setConversationWithBadgeValue:(NSNotification *)aNotification
{
    NSString *badgeStr = aNotification.object;
    _conversationVCUnreadCount = [badgeStr intValue];
    [self setTotalBadgeValue];
}

-(void) setWaitQueueWithBadgeValue:(NSInteger)badgeValue
{
    _waitVCUnreadCount = badgeValue;
    [self setTotalBadgeValue];
}

- (void)setNotifyWithBadgeValue:(NSInteger)badgeValue
{
    _notifiersVCUnreadCount = badgeValue;
    [self setTotalBadgeValue];
}


- (void)setLeaveMessageWithBadgeValue:(NSInteger)badgeValue{
    _leaveMessageVCUnreadCount = badgeValue;
    [self setTotalBadgeValue];
}

- (void)setTotalBadgeValue
{
    //设置提醒数
    NSInteger totalBadge = _conversationVCUnreadCount + _waitVCUnreadCount + _notifiersVCUnreadCount + _leaveMessageVCUnreadCount;
    KFLeftViewController *leftVC = (KFLeftViewController*)self.mm_drawerController.leftDrawerViewController;
    [leftVC refreshUnreadView:totalBadge];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = totalBadge;
    

    
}

#pragma mark - LeftMenuViewDelegate

- (void)menuClickWithIndex:(NSInteger)index
{
    if (index == 0) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else if (index == 1) {
        self.historyController = nil;
        self.historyController = [[HistoryConversationsController alloc] init];
        [self.historyController initData];
        [self.navigationController pushViewController:self.historyController animated:NO];
        NSArray *views = [self.navigationController viewControllers];
        BOOL needPush = YES;
        for (UIViewController *view in views) {
            if ([view isKindOfClass:[HistoryConversationsController class]]) {
                needPush = NO;
            }
        }
        if (needPush) {
            [self.historyController reloadData];
            [self.navigationController pushViewController:self.historyController animated:NO];
        } else {
            [self.historyController reloadData];
        }
        
    }
#if APPSTORE
    else if (index == 2)
    {
        if ([HDClient sharedClient].currentAgentUser.vecIndependentVideoEnable) {
          
            //显示vec
            self.vecHistoryController = nil;
            self.vecHistoryController = [[KFVECHistoryController alloc] init];
            [self.vecHistoryController initData];
            [self.navigationController pushViewController:self.vecHistoryController animated:NO];
            NSArray *views = [self.navigationController viewControllers];
            BOOL needPush = YES;
            for (UIViewController *view in views) {
                if ([view isKindOfClass:[KFVECHistoryController class]]) {
                    needPush = NO;
                }
            }
            if (needPush) {
                [self.vecHistoryController reloadData];
                [self.navigationController pushViewController:self.vecHistoryController animated:NO];
            } else {
                [self.vecHistoryController reloadData];
            }
            
            
        }else{
        self.adminController = nil;
        self.adminController = [[AdminInforViewController alloc] init];
        NSArray *views = [self.navigationController viewControllers];
        BOOL needPush = YES;
        for (UIViewController *view in views) {
            if ([view isKindOfClass:[AdminInforViewController class]]) {
                needPush = NO;
            }
        }
        if (needPush) {
            [self.navigationController pushViewController:self.adminController animated:NO];
        }
        }
    }
    else if (index == 3)
    {
        if ([HDClient sharedClient].currentAgentUser.vecIndependentVideoEnable) {
          
            self.adminController = nil;
            self.adminController = [[AdminInforViewController alloc] init];
            NSArray *views = [self.navigationController viewControllers];
            BOOL needPush = YES;
            for (UIViewController *view in views) {
                if ([view isKindOfClass:[AdminInforViewController class]]) {
                    needPush = NO;
                }
            }
            if (needPush) {
                [self.navigationController pushViewController:self.adminController animated:NO];
            }
            
            
        }else{
       
        }
    }
    
    
#else
    else if (index == 2)
    {

    }
    else if (index == 3)
    {
        self.adminController = nil;
        self.adminController = [[AdminInforViewController alloc] init];
        NSArray *views = [self.navigationController viewControllers];
        BOOL needPush = YES;
        for (UIViewController *view in views) {
            if ([view isKindOfClass:[AdminInforViewController class]]) {
                needPush = NO;
            }
        }
        if (needPush) {
            [self.navigationController pushViewController:self.adminController animated:NO];
        }
    }
#endif
}


- (void)adminMenuClickWithIndex:(NSInteger)index
{
    if (index == 0) { //主页
        self.adminTypeHomeController = nil;
        self.adminTypeHomeController = [[AdminHomeViewController alloc] init];
        NSArray *views = [self.navigationController viewControllers];
        BOOL needPush = YES;
        for (UIViewController *view in views) {
            if ([view isKindOfClass:[AdminHomeViewController class]]) {
                needPush = NO;
            }
        }
        if (needPush) {
            // todo 可能需要全局持有，以保证切换时不会重新创建对象
            [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0]]];
            [self.navigationController pushViewController:self.adminTypeHomeController animated:NO];
        }
    } else if (index == 1) { //现场管理
        // todo 可能需要全局持有，以保证切换时不会重新创建对象
        HDSuperviseManagerViewController *superviseVC = [[HDSuperviseManagerViewController alloc] init];
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0]]];
        [self.navigationController pushViewController:superviseVC animated:YES];
    } else if (index == 2) {
        // todo 可能需要全局持有，以保证切换时不会重新创建对象
        KFMonitorViewController *monitorVC = [[KFMonitorViewController alloc] init];
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0]]];
        [self.navigationController pushViewController:monitorVC animated:YES];
    } else if (index == 3) {
        // todo 可能需要全局持有，以保证切换时不会重新创建对象
        KFWarningViewController *warningVC = [[KFWarningViewController alloc] init];
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0]]];
        [self.navigationController pushViewController:warningVC animated:YES];
    }
}

- (void)onlineStatusClick:(UIView *)view;
{
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}
-(void)vecStatusClick:(UIView *)view{
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
}

- (void)willAutoReconnect{
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    
    if (error) {
        //        DDLogCInfo(@"didAutoReconnectFinished---%@",error.description);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"重连失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        //        DDLogCInfo(@"didAutoReconnectFinished");
    }
}

#pragma mark - private

//================appstore start=================
- (void)updateVersion:(id)dic
{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *updateInfo = (NSDictionary *)dic;
        NSString *version = [updateInfo objectForKey:@"versionCode"];
        NSString *appVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
        if ([version compare:appVersion options:NSNumericSearch] ==NSOrderedDescending) {
            DXUpdateView *updateView = [[DXUpdateView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) updateInfo:dic];
            [[UIApplication sharedApplication].keyWindow addSubview:updateView];
        } else {
            [MBProgressHUD showMessag:@"已经是最新版本" toView:[UIApplication sharedApplication].keyWindow];
        }
    } else {
//        [MBProgressHUD show:@"已经是最新版本" view:[UIApplication sharedApplication].keyWindow];
        [MBProgressHUD showMessag:@"已经是最新版本" toView:[UIApplication sharedApplication].keyWindow];
    }
}
//================appstore end=================

-(void)registerNotifications
{
    [[HDClient sharedClient] addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"showLeftView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"historyBackAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"settingBackAction" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAgoraRoom:) name:HDCALL_liveStreamInvitation_CreateAgoraRoom object:nil];
    
#pragma mark  -------- VEC 相关通知 注册加入房间的通知 ------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vec_createAgoraRoom:) name:HDCALL_KefuRtcCallRinging_VEC_CreateAgoraRoom object:nil];
    //测试通知方法 测试通过以后 请及时删除
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vec_createSessionHistory:) name:HDCALL_KefuRtcCallRinging_VEC_sessionhistory object:nil];
#pragma mark  -------- VEC 相关通知 注册加入房间的通知 edn------------
    
}

- (NSMutableDictionary*)_getSafeDictionary:(NSDictionary *)dic
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    if ([[userInfo allKeys] count] > 0) {
        for (NSString *key in [userInfo allKeys]){
            if ([userInfo objectForKey:key] == [NSNull null]) {
                [userInfo removeObjectForKey:key];
            } else {
                if ([[userInfo objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    [userInfo setObject:[self _getSafeDictionary:[userInfo objectForKey:key]] forKey:key];
                }
            }
        }
    }
    return userInfo;
}

- (void)dealloc {
    
    NSLog(@"dealloc __func__%s",__func__);
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    //    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    //    [[EMCDDeviceManager sharedInstance] playVibration];
}

#pragma mark  -------- 在线视频  收到视频邀请的通知消息  ------------
-(void)messagesDidReceive:(NSArray<HDMessage *> *)aMessages{

    if ([HDAppManager shareInstance].isAnswerView) {
                // 如果YEAS 说明已经有视频弹窗界面了 不能在接通其他视频了
        return;
    }
    if (![HDClient sharedClient].currentAgentUser.agoraVideoEnable) {

        return;
    }
    for (HDMessage *msg in aMessages) {

        // 处理视频邀请通知 两种方式 一种这个地方处理数据 一种 sdk 内部处理数据
        // 访客邀请坐席
        // 获取sessionid
        if ([[msg.nBody.msgExt allKeys] containsObject:@"type"]) {
            NSString * type = [msg.nBody.msgExt valueForKey:@"type"];
            if ([type isEqualToString:@"rtcmedia/video"]) {
                return;
            }
        }
        HDExtMsgType type = [HDUtils getMessageExtType:msg];

        if (type == HDExtMsgTypeGeneral) {

            return;

        }
        if (type == HDExtMsgTypeLiveStreamInvitation) {

            [self  onAgoraCallReceivedNickName:msg];

        }else if(type == HDExtMsgTypeVisitorCancelInvitation) {
            //访客取消邀请
            if ( [HDAgoraCallManager shareInstance].isCurrentCalling && [msg.sessionId isEqualToString:[HDAgoraCallManager shareInstance].message.sessionId]) {
                    // 来电铃
                if (self.kfAnswerView) {
                    [self.kfAnswerView stopSoundCustom];
                    [self.kfAnswerView removeFromSuperview];
                    self.kfAnswerView = nil;
                }

            }

        }else if(type == HDExtMsgTypeVisitorRejectInvitation) {
            //访客拒绝邀请  关闭当前页面 离开房间
            if ( [HDAgoraCallManager shareInstance].isCurrentCalling && [msg.sessionId isEqualToString:[HDAgoraCallManager shareInstance].message.sessionId]) {
                [[HDAgoraCallManager shareInstance] leaveChannel];
                [[HDCallViewController sharedManager]  removeView];
                [[HDCallViewController sharedManager] removeSharedManager];
            }
        }
    }
}
- (void)onAgoraCallReceivedNickName:(HDMessage *)message{
    
    // 收到消息 调用接口 从接口里边获取callid 加入房间
    [HDLog logI:@"收到消息 调用接口 从接口里边获取callid 加入房间 =%@",message.sessionId];
    if ([HDAgoraCallManager shareInstance].isCurrentCalling) {
       
        [HDLog logI:@"当前正在通话中 不进行 新的访客弹窗"];
        return;
    }
    // 全局视频通话中表示 不能同时接通多个视频 主要用于 VEC 视频和 在线聊天里边的视频  如果只接入一个。不需要使用这个属性
    [HDAppManager shareInstance].isAnswerView = YES;
    
    [HDAgoraCallManager shareInstance].isCurrentCalling = YES;
    [HDLog logI:@"当前没有通话进行新的访客弹窗 =%d",[HDAgoraCallManager shareInstance].isCurrentCalling];
    
    //创建
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    [[HDOnlineManager sharedInstance] getCurrentringingCallsCompletion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        NSLog(@"====%@",responseObject);
        
        if (error == nil) {
            
            //显示界面
            NSDictionary * dic =responseObject;
            
            if ([[dic allKeys] containsObject:@"entities"] && [[dic objectForKey:@"entities"] isKindOfClass:[NSArray class]]) {
            
                NSArray * array = [dic objectForKey:@"entities"];
                NSArray * ringingcalls = [NSArray yy_modelArrayWithClass:[KFVideoDetailAllModel class] json:array];
                
                if (ringingcalls.count > 0) {
                  
                    NSMutableArray *sessionIds = [[NSMutableArray alloc] init];
                    [ringingcalls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                         
                        KFVideoDetailAllModel * model = obj;
                        NSLog(@"==11111 - 22222==%@",message.sessionId);
                        [sessionIds addObject:model.channelName];
                        if ([model.channelName isEqualToString:message.sessionId]) {
                            
                            if (model.callDetails.count > 0) {
                                // 说明有 需要弹视频窗口
                                NSDictionary *callDetail = [model.callDetails lastObject];
                                KFRingingCallModel *model = [KFRingingCallModel yy_modelWithDictionary:callDetail];
                                
                                if (model) {
                                  // 创建视频
                                    //成功拿到token，发送信号量:
//                                    dispatch_semaphore_signal(semaphore);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                //        UI更新代码
                                        [self.kfAnswerView setMesage:message withRingCall:model];
                                        // 创建接听界面
                                        [[UIApplication sharedApplication].keyWindow addSubview:self.kfAnswerView];
                                        [self.kfAnswerView playSoundCustom];
                                        
                                    });
                                }else{
                                    
                                    [HDAgoraCallManager shareInstance].isCurrentCalling = NO;
                                    [HDAppManager shareInstance].isAnswerView = NO;
                                }
                            }else{
                                
//                                [HDAgoraCallManager shareInstance].sessionId = @"";
                                [HDAgoraCallManager shareInstance].isCurrentCalling = NO;
                                [HDAppManager shareInstance].isAnswerView = NO;
                                
                            }
                        }
                    }];
                    
                    BOOL isbool = [sessionIds containsObject:message.sessionId];

                    if (!isbool) {
                        // 如果不包含 允许下一个 请求进来
//                        [HDAgoraCallManager shareInstance].sessionId = @"";
                        [HDAgoraCallManager shareInstance].isCurrentCalling = NO;
                        [HDAppManager shareInstance].isAnswerView = NO;
                    }
                    
                }else{
//                    [HDAgoraCallManager shareInstance].sessionId = @"";
                    [HDAgoraCallManager shareInstance].isCurrentCalling = NO;
                    [HDAppManager shareInstance].isAnswerView = NO;
                }
            }
        }else{
            
//            [HDAgoraCallManager shareInstance].sessionId = @"";
            
            [HDAgoraCallManager shareInstance].isCurrentCalling = NO;
            [HDAppManager shareInstance].isAnswerView = NO;
            
        }
    }];
//
}
- (void)createAgoraRoom:(NSNotification *)notification{
    
    HDMessage *model = notification.object;
    if (model) {
      
    [self.kfAnswerView removeFromSuperview];
    self.kfAnswerView = nil;
       
       [[HDCallViewController sharedManager] showViewWithKeyCenter:model withType:HDVideoCallDirectionReceive];
        [HDCallViewController sharedManager].hangUpCallback = ^(HDCallViewController * _Nonnull callVC, NSString * _Nonnull timeStr) {
        
            [[HDCallViewController sharedManager]  removeView];
            [[HDCallViewController sharedManager] removeSharedManager];
       
           };
    }
    
}
- (KFAnswerView *)kfAnswerView{
    
    if (!_kfAnswerView) {
       _kfAnswerView =   [[KFAnswerView alloc] initWithFrame:UIScreen.mainScreen.bounds];
       _kfAnswerView.backgroundColor = [UIColor blackColor];
    }

    return _kfAnswerView;
}
#pragma mark  -------- 在线视频  收到视频邀请的通知消息 end ------------

#pragma mark ----------------------------VEC 视频相关 入口-------------------------------

//vec 加入房间的通知
- (void)vec_createAgoraRoom:(NSNotification *)notification{
    
    HDVECRingingCallModel *model = notification.object;
    if (model) {
    [self.kfVecAnswerView removeFromSuperview];
    self.kfVecAnswerView = nil;
    [[HDVECViewController sharedManager] vec_showViewWithKeyCenter:model];
    [HDVECViewController sharedManager].vechangUpCallback  = ^(HDVECViewController * _Nonnull callVC, NSString * _Nonnull timeStr) {
        [[HDVECViewController sharedManager]  removeView];
        [[HDVECViewController sharedManager] removeSharedManager];
    };
    }
}
// 收到VEC的新消息的通知
- (void)vec_KefuRtcNewMessageDidReceive:(NSDictionary *)dic{
    NSLog(@"================收到rtc新消息通知==========%@",dic);
    if ([[HDVECAgoraCallManager shareInstance] vec_isVisitorCancelInvitationMessage:dic]) {
        
        if (self.kfVecAnswerView) {
            [self.kfVecAnswerView vec_cancelKefuRtcCallRinging];
        }
    }
    
}
// 收到视频邀请的通知
-(void)vec_KefuRtcCallRingingDidReceive:(NSDictionary *)dic{
    
    if ([HDAppManager shareInstance].isAnswerView) {
        // 如果YEAS 说明已经有视频弹窗界面了 不能在接通其他视频了
        return;
    }
    
    [HDAppManager shareInstance].isAnswerView = YES;
    // 收到振铃消息 先解析需要的数据 开始弹视频界面
    //1、解析数据
    //2、调用接口获取声网数据 弹窗
    HDVECRingingCallModel * model = [[HDVECAgoraCallManager shareInstance] vec_parseKefuRtcCallRingingData:dic];
    [self  vec_onAgoraCallReceivedNickName:model];
    // 获取接口 数据 测试
//    [self vec_testApi];
}

- (void)vec_testApi{
    
    // 获取视频记录
    NSDictionary *dicHistory = [[HDVECAgoraCallManager shareInstance] vec_getSessionhistoryParameteData];
    [[HDVECAgoraCallManager shareInstance] vec_getRtcSessionhistoryParameteData:dicHistory completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        NSLog(@"=======%@",responseObject);

    }];

    /*
     * 获取视频详情
     */
    [[HDVECAgoraCallManager shareInstance] vec_getCallVideoDetailWithRtcSessionId:@"00edd4cd-57db-414c-8a6b-a5fd4d9ddab6" Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {


        NSLog(@"=======%@",responseObject);

    }];
    //待接入 相关接口
    /*
     * 待接入数量 这个接口需要需要轮训获取排队数量
     */
    NSString * agentId = [HDClient sharedClient].currentAgentUser.agentId;
    [[HDVECAgoraCallManager shareInstance] vec_getSessionsCallWaitWithAgentId:agentId Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        NSLog(@"=======%@",responseObject);

    }];

    /*
     * 待接入列表 这个接口需要需要轮训获取排队列表
     {
       "page": 0,
       "size": 20,
       "mode": "agent", //  如果要获取管理员下所有的列表 传admin
       "beginDate": "2022-05-05T00:00:00",
       "endDate": "2022-05-06T00:00:00",
       "techChannelId": 27230,
       "originType": "app",
       "visitorUserId": "id"
     }'
     */

    NSDictionary *dic = [[HDVECAgoraCallManager shareInstance] vec_getSessionCallWaitListParameteData];
    [[HDVECAgoraCallManager shareInstance] vec_postSessionsCallWaitListParameteData:dic Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        NSLog(@"=====================%@",responseObject);
    }];
    /*
     * 待接入 获取接听 音视频ticket 通行证
     */
    [[HDVECAgoraCallManager shareInstance] vec_getSessionsCallWaitTicketWithAgentId:agentId withRtcSessionId:@"00edd4cd-57db-414c-8a6b-a5fd4d9ddab6" Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        NSLog(@"=====================%@",responseObject);
    }];
    /*
     * 拒接待接入通话
     */
    [[HDVECAgoraCallManager shareInstance] vec_postSessionsCallWaitRejectWithAgentId:agentId withRtcSessionId:@"e973c39e-9d44-4eaf-a489-91c7467d00f4" Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        NSLog(@"=====================%@",responseObject);

    }];
    
}

// 创建vec 视频界面
- (void)vec_onAgoraCallReceivedNickName:(HDVECRingingCallModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
//        UI更新代码
        [self.kfVecAnswerView vec_setKefuRtcCallRingingModel:model];
        // 创建接听界面
        [[UIApplication sharedApplication].keyWindow addSubview:self.kfVecAnswerView];
        [self.kfVecAnswerView playSoundCustom];
        
    });
    
}
// 收到坐席状态改变的通知
- (void)vec_KefuRtcAgentStateChangeDidReceive:(NSDictionary *)dic{

    NSLog(@"================收到坐席状态改变消息通知==========%@",dic);
}
//  vec 历史消息通知
- (void)vec_RtcSessionHistoryClosedDidReceive:(NSDictionary *)dic{
    
    NSLog(@"================收到历史消息通知==========%@",dic);
    
}
-(KFVECAnswerView *)kfVecAnswerView{
    
    if (!_kfVecAnswerView) {
        _kfVecAnswerView =   [[KFVECAnswerView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _kfVecAnswerView.backgroundColor = [UIColor blackColor];
    }

    return _kfVecAnswerView;
    
}

// 测试接口api 代码
- (void)vec_createSessionHistory:(NSNotification *)notification{
    HDVECSessionHistoryViewController * vec = [[HDVECSessionHistoryViewController alloc]init];
    UINavigationController * nav= [[UINavigationController alloc] initWithRootViewController:vec];
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.windowLevel = 0.0;
    self.alertWindow.backgroundColor = [UIColor clearColor];
    self.alertWindow.rootViewController = nav;
    self.alertWindow.accessibilityViewIsModal = YES;
    [self.alertWindow makeKeyAndVisible];
    self.view.frame = [UIScreen mainScreen].bounds;
    [self.alertWindow  addSubview:vec.view];
    vec.window = self.alertWindow;
    vec.vectestHangUpCallback = ^{
        
        [self.alertWindow removeAllSubviews];
        self.alertWindow = nil;
    };
}

#pragma mark ----------------------------VEC 视频相关 入口 end-------------------------------
- (void)userAccountNeedRelogin:(HDAutoLogoutReason)reason{
    
    if (self.kfVecAnswerView) {
        [self.kfVecAnswerView vec_cancelKefuRtcCallRinging];
    }
    
}
@end

