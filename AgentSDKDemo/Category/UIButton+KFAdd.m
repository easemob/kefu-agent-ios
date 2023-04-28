//
//  UIButton+KFAdd.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "UIButton+KFAdd.h"

@implementation UIButton (KFAdd)
+ (UIButton *)buttonWithMargin:(CGFloat)margin originY:(CGFloat)y target:(id)target sel:(SEL)action title:(NSString *)title {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(margin, y, KScreenWidth - margin * 2, 45)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.clipsToBounds = YES;
    btn.layer.cornerRadius = 5.f;
    btn.titleLabel.font =  [UIFont boldSystemFontOfSize:18.0];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setBackgroundColor:RGBACOLOR(41, 170, 234, 1)];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
@end
