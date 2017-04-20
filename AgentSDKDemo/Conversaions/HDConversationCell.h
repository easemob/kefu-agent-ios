//
//  HDConversationCell.h
//  AgentSDKDemo
//
//  Created by afanda on 4/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDConversationCell : UITableViewCell
@property (strong, nonatomic) UIImageView *headerImageView;

@property (strong, nonatomic) UILabel *unreadLabel;


@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UILabel *timeLabel;

- (void)setModel:(ConversationModel *)model;
@end
