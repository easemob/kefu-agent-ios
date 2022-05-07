//
//  UIButton+KFAdd.h
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (KFAdd)
+(UIButton *)buttonWithMargin:(CGFloat)margin originY:(CGFloat)y  target:(id)target sel:(SEL)action title:(NSString *)title;
@end
