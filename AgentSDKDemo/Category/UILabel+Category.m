//
//  UILabel+Category.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/7/3.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "UILabel+Category.h"

@implementation UILabel (Category)

-(void)setLabelSpaceWithValue:(NSString*)str
            withFont:(UIFont*)font
     spaceLineHeight:(CGFloat)aHeight{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = aHeight; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 5.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    self.attributedText = attributeStr;
}

- (CGFloat)getSpaceLabelHeight:(NSString*)str
                      withFont:(UIFont*)font
                     withWidth:(CGFloat)width
               spaceLineHeight:(CGFloat)aHeight {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = aHeight;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 5.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle};
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
    
}
@end
