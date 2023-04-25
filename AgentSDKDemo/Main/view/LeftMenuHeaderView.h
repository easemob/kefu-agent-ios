//
//  LeftMenuHeaderView.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMHeaderImageView.h"

@interface LeftMenuHeaderView : UIView

@property (nonatomic, strong) EMHeaderImageView *headImageView;

@property (nonatomic, strong) UILabel *nickLabel;

@property (nonatomic, strong) UIButton *onlineButton;
@property (nonatomic, strong) UIButton *vecButton;
@property (nonatomic, strong) UIImageView *vecImageView;

@end
