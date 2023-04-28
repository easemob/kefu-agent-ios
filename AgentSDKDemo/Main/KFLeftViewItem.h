//
//  KFLeftViewItem.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/20.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFLeftViewItem : NSObject
+ (KFLeftViewItem *)name:(NSString *)aName image:(UIImage *)aImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isShowTipImage;
@property (nonatomic, assign) int unreadCount;
@end
