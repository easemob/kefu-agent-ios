//
//  EMBaseViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/18.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMBaseViewController.h"

@implementation EMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

@end
