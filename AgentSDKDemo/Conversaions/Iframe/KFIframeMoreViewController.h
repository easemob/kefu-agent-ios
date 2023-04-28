//
//  KFIframeMoreViewController.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/3/2.
//  Copyright © 2023 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFIframeMoreViewController : UIViewController
@property (nonatomic, strong) HDConversation *conversation;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@end

NS_ASSUME_NONNULL_END
