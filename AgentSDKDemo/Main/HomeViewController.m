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
#import "LeaveMsgViewController.h"
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
@interface HomeViewController ()<EMChatManagerDelegate,LeftMenuViewDelegate>
{
    UITapGestureRecognizer *_tap;
    BOOL _isEnterChat;
    NSString *_serviceSessionId;
}

@property (strong, nonatomic) KFConversationsController *conversationsController;
@property (strong, nonatomic) CustomerViewController *customerController;
@property (strong, nonatomic) NotifyViewController *notifyController;
@property (strong, nonatomic) WaitQueueViewController *waitqueueController;
@property (strong, nonatomic) LeaveMsgViewController *leaveMsgController;
//非管理员
@property(nonatomic,strong) HomeViewController *homeViewController;
@property (strong, nonatomic) HistoryConversationsController *historyController;
@property (strong, nonatomic) AdminInforViewController *adminController;

//管理员
@property (strong, nonatomic) AdminHomeViewController *adminTypeHomeController;
@property (strong, nonatomic) DXTipView *tipView;
@property (strong, nonatomic) DXTipView *tipCustomerView;
@property (strong, nonatomic) DXTipView *tipNotifyView;
@property (nonatomic, strong) DXTipView *tipLeaveMsgView;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property (strong, nonatomic) UIView *tapView;

@end

static HomeViewController *homeViewController;
static NSString *currentBadgeValue;
static NSString *currentWaitBadgeValue;
static NSString *currentNotifyBadgeValue;
static NSString *currentLeaveMessageBadgeValue;
static NSInteger currentTotalBadgeValue;

@implementation HomeViewController

- (void)setCustomerWithBadgeValue:(NSString *)badge {
    
}


+(id) HomeViewController
{
    @synchronized(self) {
        if(homeViewController == nil) {
            homeViewController = [[super allocWithZone:NULL] init];
        }
    }
    return homeViewController;
}

+(void) HomeViewControllerDestory
{
    @synchronized(self) {
        homeViewController = nil;
    }
}
+(NSString*)currentBadgeValue
{
    return currentBadgeValue;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [fNotificationCenter addObserver:self selector:@selector(setTotalBadgeValue) name:NOTIFICATION_CONVERSATION_REFRESH object:nil];
    [self printViewHierarchy:self.tabBarController.view];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    ReminderView *remindView = [[ReminderView alloc] initWithDictionary:responseObject];
                    [[UIApplication sharedApplication].keyWindow addSubview:remindView];
                });
            }
            
        }];
    });
    [self _setupChildrenVC];
    //    [self _setupSubviews];
    
    [self registerNotifications];
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
    
    _leaveMsgController = [[LeaveMsgViewController alloc] init];
    [KFManager sharedInstance].leaveMsg = _leaveMsgController;
    [self setupChildVc:_leaveMsgController title:@"留言"
                 image:@"tabbar_icon_crm"
         selectedImage:@"tabbar_icon_crmhighlight" index:3];
    [_leaveMsgController viewDidLoad];
    
    self.view.backgroundColor = RGBACOLOR(25, 25, 25, 1);
    
    self.viewControllers = @[_conversationsController, _waitqueueController, _notifyController,_leaveMsgController];
    
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

- (UIView*)tapView
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
        self.navigationItem.leftBarButtonItem = _leaveMsgController.headerViewItem;
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

-(UIImage*)convertViewToImage:(UIView*)v{
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

-(void) setConversationWithBadgeValue:(NSString*)badgeValue
{
    currentBadgeValue = badgeValue;
    //设置提醒数
    if (badgeValue && [badgeValue intValue] >= 100) {
        _tipView.tipNumber = @"99+";
    } else {
        _tipView.tipNumber = badgeValue;
    }
    [self setTotalBadgeValue];
    if (badgeValue == nil) {
        [self setConversationUnRead:NO];
    } else {
        [self setConversationUnRead:YES];
    }
}

-(void) setConversationUnRead:(BOOL) aFlag
{
    KFConversationsController *conversation = (KFConversationsController*)[self.viewControllers objectAtIndex:0];
    if (aFlag) {
        [conversation.tabBarItem setFinishedSelectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_ongoinghighlight"] rightImage:[self convertViewToImage:_tipView]] withFinishedUnselectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_ongoing"] rightImage:[self convertViewToImage:_tipView]]];
    }else {
        [conversation.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_icon_ongoinghighlight"] tabBarImage] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_icon_ongoing"] tabBarImage]];
    }
}

-(void) setWaitQueueWithBadgeValue:(NSString*)badgeValue
{
    //currentWaitBadgeValue = badgeValue;
    _tipCustomerView.tipNumber = badgeValue;
    [self setTotalBadgeValue];
    if (badgeValue == nil) {
        [self setWaitQueueUnRead:NO];
    } else {
        [self setWaitQueueUnRead:YES];
    }
}

-(void) setWaitQueueUnRead:(BOOL) aFlag
{
    WaitQueueViewController *customer = (WaitQueueViewController*)[self.viewControllers objectAtIndex:1];
    if (aFlag) {
        [customer.tabBarItem setFinishedSelectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_visitorhighlight_Text6"] rightImage:[self convertViewToImage:_tipCustomerView]] withFinishedUnselectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_visitor_Text6"] rightImage:[self convertViewToImage:_tipCustomerView]]];
    }else {
        [customer.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_icon_visitorhighlight_Text6"] tabBarImage] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_icon_visitor_Text6"] tabBarImage]];
    }
}

- (void)setNotifyWithBadgeValue:(NSString*)badgeValue
{
    currentNotifyBadgeValue = badgeValue;
    if (badgeValue && [badgeValue intValue] >= 100) {
        _tipNotifyView.tipNumber = @"99+";
    } else {
        _tipNotifyView.tipNumber = badgeValue;
    }
    [self setTotalBadgeValue];
    if (badgeValue == nil) {
        [self setNotifyUnRead:NO];
    } else {
        [self setNotifyUnRead:YES];
    }
}

-(void) setNotifyUnRead:(BOOL) aFlag
{
    NotifyViewController *customer = (NotifyViewController*)[self.viewControllers objectAtIndex:2];
    if (aFlag) {
        [customer.tabBarItem setFinishedSelectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_noticehighlight"] rightImage:[self convertViewToImage:_tipNotifyView]] withFinishedUnselectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_notice"] rightImage:[self convertViewToImage:_tipNotifyView]]];
    }else {
        [customer.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_icon_noticehighlight"] tabBarImage] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_icon_notice"] tabBarImage]];
    }
}

- (void)setLeaveMessageWithBadgeValue:(NSString*)badgeValue{
    currentLeaveMessageBadgeValue = badgeValue;
    if (badgeValue && [badgeValue intValue] >= 100) {
        _tipLeaveMsgView.tipNumber = @"99+";
    } else {
        _tipLeaveMsgView.tipNumber = badgeValue;
    }
    [self setTotalBadgeValue];
    if (badgeValue == nil) {
        [self setLeaveMessageyUnRead:NO];
    } else {
        [self setLeaveMessageyUnRead:YES];
    }
}

- (void)setLeaveMessageyUnRead:(BOOL) aFlag {
    LeaveMsgViewController *customer = (LeaveMsgViewController*)[self.viewControllers objectAtIndex:3];
    if (aFlag) {
        [customer.tabBarItem setFinishedSelectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_crmhighlight"] rightImage:[self convertViewToImage:_tipLeaveMsgView]] withFinishedUnselectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_crm"] rightImage:[self convertViewToImage:_tipLeaveMsgView]]];
    }else {
        [customer.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_icon_crmhighlight"] tabBarImage] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_icon_crm"] tabBarImage]];
    }
}

- (void)setTotalBadgeValue
{
    //设置提醒数
    currentTotalBadgeValue = [currentBadgeValue integerValue] + [currentWaitBadgeValue integerValue] + [currentNotifyBadgeValue integerValue] + [currentLeaveMessageBadgeValue integerValue];
    KFLeftViewController *leftVC = (KFLeftViewController*)self.mm_drawerController.leftDrawerViewController;
    [leftVC refreshUnreadView:currentTotalBadgeValue];
}

- (NSInteger)totleBadgeValue {
    return currentTotalBadgeValue;
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

- (void)onlineStatusClick:(UIView*)view;
{
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
        NSDictionary *updateInfo = (NSDictionary*)dic;
        NSString *version = [updateInfo objectForKey:@"versionCode"];
        NSString *appVersion = [[[NSBundle mainBundle]infoDictionary]valueForKey:@"CFBundleVersion"];
        if ([version compare:appVersion options:NSNumericSearch] ==NSOrderedDescending) {
            DXUpdateView *updateView = [[DXUpdateView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) updateInfo:dic];
            [[UIApplication sharedApplication].keyWindow addSubview:updateView];
        } else {
            [MBProgressHUD show:@"已经是最新版本" view:[UIApplication sharedApplication].keyWindow];
        }
    } else {
        [MBProgressHUD show:@"已经是最新版本" view:[UIApplication sharedApplication].keyWindow];
    }
}
//================appstore end=================

-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"showLeftView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"historyBackAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"settingBackAction" object:nil];
}


//- (void)showNotificationWithMessage:(NSString *)message dic:(NSDictionary*)dic;
//{
//    //发送本地推送
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate date]; //触发通知的时间
//    notification.alertBody = message;
//    notification.alertAction = NSLocalizedString(@"open", @"Open");
//    notification.timeZone = [NSTimeZone defaultTimeZone];
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
//    if (timeInterval < kDefaultPlaySoundInterval) {
//        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
//    } else {
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        self.lastPlaySoundDate = [NSDate date];
//    }
//    
//    if (dic) {
//        @try {
//            NSMutableDictionary *userInfo = [self _getSafeDictionary:dic];
//            notification.userInfo = userInfo;
//        } @catch (NSException *exception) {
//            NSLog(@"exception : %@",exception);
//        } @finally {
//            
//        }
//    }
//    
//    if ([notification.userInfo objectForKey:@"body"]) {
//        HDConversation *model = [[HDConversation alloc] initWithDictionary:[notification.userInfo objectForKey:@"body"]];
//        if (_serviceSessionId.length > 0) {
//            if ([_serviceSessionId isEqualToString:model.sessionId]) {
//                _isEnterChat = YES;
//            } else {
//                _isEnterChat = NO;
//            }
//        } else {
//            _isEnterChat = YES;
//            _serviceSessionId = model.sessionId;
//        }
//    }
//    
//    //发送通知
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//}

- (NSMutableDictionary*)_getSafeDictionary:(NSDictionary*)dic
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


//- (void)didReceiveLocalNotification:(UILocalNotification *)notification
//{
//    if (![HDClient sharedClient].isLoggedInBefore) {
//        return;
//    }
//    NSDictionary *userInfo = notification.userInfo;
//    if (userInfo) {
//        //新回话就到会话界面
//        NSDictionary *body = [userInfo valueForKey:@"body"];
//        if ([body.allKeys containsObject:@"newSession"]) {
//            if( [[body valueForKey:@"newSession"] boolValue] ) { //是新回话
//                [self.navigationController popToRootViewControllerAnimated:NO];
//                [self setSelectedViewController:_conversationsController];
//                [self tabBar:self.tabBar didSelectItem:_conversationsController.tabBarItem];
//                return;
//            }
//        }
//        NSString *type = [userInfo objectForKey:MESSAGE_TYPE];
//        if ([type isEqualToString:MESSAGE_TYPE_NEWCHARMESSAGE]) {
//            [self.navigationController popToRootViewControllerAnimated:NO];
//            [self setSelectedViewController:_conversationsController];
//            [self tabBar:self.tabBar didSelectItem:_conversationsController.tabBarItem];
//            if (_isEnterChat) {
//                if ([userInfo objectForKey:@"body"]) {
//                    HDConversation *model = [[HDConversation alloc] initWithDictionary:[userInfo objectForKey:@"body"]];
//                    ChatViewController *chatView = [[ChatViewController alloc] init];
//                    chatView.conversationModel = model;
//                    model.chatter = model.vistor;
//                    [[DXMessageManager shareManager] setCurSessionId:model.sessionId];
////                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONVERSATION_REFRESH object:nil];
//                    [self.navigationController pushViewController:chatView animated:NO];
//                }
//            }
//            _serviceSessionId = nil;
//            _isEnterChat = YES;
//        } else if ([type isEqualToString:MESSAGE_TYPE_ACTIVITY_CREATE]) {
//            [self setSelectedViewController:_notifyController];
//            [self tabBar:self.tabBar didSelectItem:_notifyController.tabBarItem];
//        }
//    }
//}

- (void)dealloc {
    
    NSLog(@"dealloc __func__%s",__func__);
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

@end

