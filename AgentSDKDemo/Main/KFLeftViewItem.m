//
//  KFLeftViewItem.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/20.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFLeftViewItem.h"

@implementation KFLeftViewItem
+ (KFLeftViewItem *)name:(NSString *)aName image:(UIImage *)aImage {
    KFLeftViewItem *item = [[KFLeftViewItem alloc] init];
    item.image = aImage;
    item.name = aName;
    return item;
}
@end
