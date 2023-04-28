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
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *userTagId;
@property (nonatomic, copy) NSString *visitorUserId;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

