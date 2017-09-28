//
//  HistoryCompileTableViewCell.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/15.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "HistoryCompileTableViewCell.h"

@implementation HistoryCompileTableViewCell

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 230, 231, 1).CGColor);
    //    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));
    //下分割线
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nickName.textAlignment = NSTextAlignmentRight;
    self.nickName.left = self.width - self.nickName.width - 40;
    
    self.title.font = [UIFont systemFontOfSize:18.f];
    self.title.textColor = RGBACOLOR(26, 26, 26, 1);
    self.nickName.font = [UIFont systemFontOfSize:18.f];
    self.nickName.textColor = RGBACOLOR(26, 26, 26, 1);
}

@end
