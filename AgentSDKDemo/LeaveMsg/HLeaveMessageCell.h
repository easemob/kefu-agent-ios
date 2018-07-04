//
//  HLeaveMessageCell.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/12.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLeaveMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lLeaveMsgTypeName;
@property (weak, nonatomic) IBOutlet UILabel *lLeaveMsgCount;
- (void)setupUnreadCountTextColor:(UIColor *)aColor;
- (void)setupUnreadCountBgColor:(UIColor *)aColor;
@end
