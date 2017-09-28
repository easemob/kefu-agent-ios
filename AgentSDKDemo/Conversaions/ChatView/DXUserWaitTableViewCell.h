//
//  DXUserWaitTableViewCell.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/18.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXUserWaitTableViewCell : UITableViewCell
{
    UserModel *_model;
}

@property (strong, nonatomic) UIImageView *headerImageView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIButton *joinupBtn;

@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UIView *lineView;


- (void)setModel:(HDWaitUser *)model;

@end
