//
//  KFVECCallTableViewCell.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/25.
//  Copyright © 2023 环信. All rights reserved.
//

#import "SWTableViewCell.h"
#import "KFVecCallHistoryModel.h"
@class DXTipView;
@class HDConversation;
@class HDMessage;
NS_ASSUME_NONNULL_BEGIN

@interface KFVECCallTableViewCell : SWTableViewCell
@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *unreadLabel;

@property (nonatomic, strong) DXTipView *tipView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *reasonLabel;

@property (nonatomic, strong) UILabel *timeLabel;

- (void)setVECHistoryModel:(KFVecCallHistoryModel*)model;
@end
//"加载更多"的cell
@interface KFVECDXLoadmoreCell : UITableViewCell

@property (nonatomic, assign) BOOL hasMore;

@end
NS_ASSUME_NONNULL_END
