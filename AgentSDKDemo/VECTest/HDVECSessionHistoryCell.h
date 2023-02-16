//
//  HDVECSessionHistoryCell.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDVECSessionHistoryModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HDVECSessionHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *visitorName;
@property (weak, nonatomic) IBOutlet UILabel *rtcSessionId;


-(void)setModel:(HDVECSessionHistoryModel *)model;
@end

NS_ASSUME_NONNULL_END
