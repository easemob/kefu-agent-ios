//
//  UserTagModel.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户标签
@interface HDUserTag : NSObject

@property (assign, nonatomic) BOOL checked;
@property (copy, nonatomic) NSString *tagName;
@property (copy, nonatomic) NSString *tenantId;
@property (copy, nonatomic) NSString *userTagId;
@property (copy, nonatomic) NSString *visitorUserId;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

