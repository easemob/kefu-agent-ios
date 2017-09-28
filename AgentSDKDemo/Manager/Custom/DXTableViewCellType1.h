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

@property (strong, nonatomic) UIImageView *headerImageView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) DXTipView *unreadLabel;

- (void)setModel:(HDConversation *)model;

@end
