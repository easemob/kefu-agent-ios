//
//  DXTableViewCellTypeConversation.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@class DXTipView;
@class HDConversation;
@class HDMessage;
@interface DXTableViewCellTypeConversation : SWTableViewCell

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *unreadLabel;

@property (nonatomic, strong) DXTipView *tipView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *timeLabel;

- (void)setModel:(HDConversation *)model;
- (void)setMsgModel:(HDMessage *)model;
- (void)setHistoryModel:(HDConversation *)model;

@end

//"加载更多"的cell
@interface DXLoadmoreCell : UITableViewCell

@property (nonatomic, assign) BOOL hasMore;

@end
