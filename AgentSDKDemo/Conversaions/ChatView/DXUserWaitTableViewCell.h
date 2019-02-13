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
//    UserModel *_model;
}

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *joinupBtn;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIView *lineView;


- (void)setModel:(HDWaitUser *)model;

@end
