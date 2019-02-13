//
//  CompileTableViewCell.h
//  EMCSApp
//
//  Created by EaseMob on 16/1/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kVisitorInfomationContentWidth 4*KScreenWidth/5-30

@interface CompileTableViewCell : UITableViewCell

@property (nonatomic, strong) HDVisitorInfoItem *model;

@property (nonatomic, strong) UIImageView *nextimage;
@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) UILabel *title;

@end
