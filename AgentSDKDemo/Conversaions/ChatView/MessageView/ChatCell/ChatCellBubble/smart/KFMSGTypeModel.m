//
//  KFMSGTypeModel.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFMSGTypeModel.h"

@implementation KFMSGTypeModel
{
    CGFloat _cellHeight;
}

-(CGFloat)cellHeight{

    // 文字的最大尺寸
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 2*10, MAXFLOAT);
    // 计算文字的高度
    CGFloat textH = [self.title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19]} context:nil].size.height;
    CGFloat text1H = [self.digest boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:19]} context:nil].size.height;
    // c文字部分的高度
    _cellHeight = 44 + textH + 20 + text1H + 21 + 85;
    return _cellHeight;
    
}
@end
@implementation KFMSGTypeItemModel

@end
