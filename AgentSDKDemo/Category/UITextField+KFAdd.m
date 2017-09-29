//
//  UITextField+KFAdd.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "UITextField+KFAdd.h"
#import <objc/runtime.h>

static const void *associateKey;
@implementation UITextField (KFAdd)
//set
- (void)setMaxCharacterlength:(NSInteger)maxCharacterlength {
    objc_setAssociatedObject(self, associateKey, [NSNumber numberWithInteger:maxCharacterlength], OBJC_ASSOCIATION_ASSIGN);
    if (maxCharacterlength>0) {
        [self addTarget:self action:@selector(characterAlreadyChanged:) forControlEvents:UIControlEventAllEditingEvents];
    } else {
        [self removeTarget:self action:@selector(characterAlreadyChanged:) forControlEvents:UIControlEventAllEditingEvents];
    }
}
//get
- (NSInteger)maxCharacterlength {
    return [objc_getAssociatedObject(self, associateKey) integerValue];
}
//change
- (void)characterAlreadyChanged:(UITextField *)textField {
    if (self.maxCharacterlength == 0) return;
    UITextRange *markedRange = textField.markedTextRange;
    NSInteger markedLenth = [[textField textInRange:markedRange] length];
     if ([textField.text length] - markedLenth <= self.maxCharacterlength) return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符数不能超过%ld个",(long)self.maxCharacterlength]delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    NSString *subString = [textField.text substringToIndex:self.maxCharacterlength];
    textField.text = subString;
}

+ (UITextField *)textfieldCreateWithMargin:(CGFloat)margin originy:(CGFloat)y placeHolder:(NSString *)placeHolder returnKeyType:(UIReturnKeyType)returnKeyType keyboardType:(UIKeyboardType)keyboardType{
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(margin, y, KScreenWidth-2*margin , 35)];
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:RGBACOLOR(0x99, 0x99, 0x99, 1)}];
    tf.font = [UIFont systemFontOfSize:16.0];
    tf.clipsToBounds = YES;
    tf.backgroundColor = [UIColor whiteColor];
    tf.textAlignment = NSTextAlignmentLeft;
    tf.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
    tf.font = [UIFont systemFontOfSize:16];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.keyboardType = keyboardType;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.returnKeyType = returnKeyType;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(tf.frame) - 1.f, CGRectGetWidth(tf.frame), 1.f)];
    line.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [tf addSubview:line];
    return tf;
}

@end
