//
//  UserTagModel.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "UserTagModel.h"
//#import "NSDictionary+SafeValue.h"

@implementation SessionCategoryModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.serviceSessionCategoryId = [dictionary safeStringValueForKey:CATEGORY_ID];
        self.name = [dictionary safeStringValueForKey:CATEGORY_NAME];
        self.tenantId = [dictionary safeStringValueForKey:CATEGORY_TENANTID];
    }
    return self;
}

@end

@implementation SessionSubcategoryModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.serviceSessionSubcategoryId = [dictionary safeStringValueForKey:CATEGORY_SUBID];
    }
    return self;
}

@end
