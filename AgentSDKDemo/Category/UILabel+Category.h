//
//  UILabel+Category.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/7/3.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Category)
-(void)setLabelSpaceWithValue:(NSString *)str
            withFont:(UIFont*)font
     spaceLineHeight:(CGFloat)aHeight;

- (CGFloat)getSpaceLabelHeight:(NSString *)str
                      withFont:(UIFont*)font
                     withWidth:(CGFloat)width
               spaceLineHeight:(CGFloat)aHeight;
@end
