//
//  MainViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 4/13/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "MainViewController.h"
#import "HDConversationViewController.h"
#import "HDSettingViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initControllers];
}

- (void)initControllers {
    NSArray* controllers = @[[[HDConversationViewController alloc] init],[[HDSettingViewController alloc]init]];
    NSMutableArray* navControllers = [[NSMutableArray alloc] init];
    NSArray* titles = @[@"会话",@"设置"];
    for (int i=0;i<controllers.count;i++) {
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controllers[i]];
        [navControllers addObject:navController];
    }
    self.viewControllers=navControllers;
    for (int i=0;i<controllers.count;i++) {
        UITabBarItem* item = self.tabBar.items[i];
        // 设置子控制器，tabbar和navigationBar上的title
        item.title = titles[i];
        [item setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon%d",i+1]]];
        [item setSelectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon%d_selected",i+1]]];
        [item setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
        [item setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor colorWithRed:130/255.0 green:92/255.0 blue:120/255.0 alpha:1]} forState:UIControlStateSelected];
    }
}

- (void)dealloc {
    NSLog(@"%s dealloc",__func__);
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
