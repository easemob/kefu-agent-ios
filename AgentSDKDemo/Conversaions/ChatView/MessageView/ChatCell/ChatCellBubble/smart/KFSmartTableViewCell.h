//
//  KFSmartTableViewCell.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFMSGTypeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KFSmartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *clickLabel;


- (void) setModel:(KFMSGTypeModel *)model;

@end

NS_ASSUME_NONNULL_END
