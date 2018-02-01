//
//  KFLeaveMsgViewController.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 29/01/2018.
//  Copyright © 2018 环信. All rights reserved.
//

#import "KFLeaveMsgViewController.h"
#import "MBProgressHUD.h"
#import "UIViewController+HUD.h"

@interface KFLeaveMsgViewController ()

@property (weak, nonatomic) IBOutlet UILabel *untreatedCount;
@property (weak, nonatomic) IBOutlet UILabel *processingCount;
@property (weak, nonatomic) IBOutlet UILabel *resolvedCount;
@property (weak, nonatomic) IBOutlet UILabel *undistributedCount;
@property (weak, nonatomic) IBOutlet UILabel *customLeaveMsgCount;

@end

@implementation KFLeaveMsgViewController

+ (NSString *)storyboardName {
    return @"KFLeaveMsgViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
