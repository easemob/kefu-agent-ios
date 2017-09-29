//
//  KFTabBarController.m
//  EMCSApp
//
//  Created by afanda on 5/15/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFTabBarController.h"
#import "KFBaseNavigationController.h"
#import "ConversationsController.h"
#import "WaitQueueViewController.h"
#import "NotifyViewController.h"
#import "LeaveMsgViewController.h"



@interface KFTabBarController ()

@end

@implementation KFTabBarController

+(void)initialize {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    attrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSFontAttributeName] = attrs[NSFontAttributeName];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    
    [[UITabBar appearance] setTintColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1)];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ConversationsController *conversationVC = [[ConversationsController alloc] init];
    [self setupChildVc:conversationVC title:@"会话22" image:@"tabbar_icon_ongoing" selectedImage:@"tabbar_icon_ongoinghighlight"];
    WaitQueueViewController *waitVC = [[WaitQueueViewController alloc] init];
    [self setupChildVc:waitVC title:@"待接入22" image:@"tabbar_icon_visitor_Text6" selectedImage:@"tabbar_icon_visitorhighlight_Text6"];
    NotifyViewController *notiVC = [[NotifyViewController alloc] init];
    [self setupChildVc:notiVC title:@"通知22" image:@"tabbar_icon_notice" selectedImage:@"tabbar_icon_crmhighlight"];
    LeaveMsgViewController *leaveVC = [[LeaveMsgViewController alloc] init];
    [self setupChildVc:leaveVC title:@"留言22" image:@"tabbar_icon_crm" selectedImage:@"tabbar_icon_crmhighlight"];
}



/**
 * 初始化子控制器
 */
- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置文字和图片
    vc.navigationItem.title = title;
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 包装一个导航控制器, 添加导航控制器为tabbarcontroller的子控制器
    KFBaseNavigationController *nav = [[KFBaseNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
