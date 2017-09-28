//
//  UITextField+KFAdd.h
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (KFAdd)
@property(nonatomic,assign) NSInteger maxCharacterlength;
+ (UITextField *)textfieldCreateWithMargin:(CGFloat)margin originy:(CGFloat)y placeHolder:(NSString *)placeHolder returnKeyType:(UIReturnKeyType)returnKeyType keyboardType:(UIKeyboardType)keyboardType;
@end
