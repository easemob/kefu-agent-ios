//
//  DXTableViewCellType1.h
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXTipView;
@interface DXTableViewCellType1 : UITableViewCell

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) DXTipView *unreadLabel;

- (void)setModel:(HDConversation *)model;

@end
