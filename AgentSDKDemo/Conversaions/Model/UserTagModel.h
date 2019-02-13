//
//  UserTagModel.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TAG_CHECKED @"checked"
#define TAG_TAGNAME @"tagName"
#define TAG_TENANTID @"tenantId"
#define TAG_ID @"tagId"
#define TAG_USERID @"visitorUserId"

#define CATEGORY_ID @"serviceSessionCategoryId"
#define CATEGORY_NAME @"name"
#define CATEGORY_TENANTID @"tenantId"
#define CATEGORY_SUBID @"serviceSessionSubcategoryId"
//会话小结,分类1标签
@interface SessionCategoryModel : NSObject

@property (nonatomic, copy) NSString *serviceSessionCategoryId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tenantId;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

//会话小结,分类2标签
@interface SessionSubcategoryModel : SessionCategoryModel

@property (nonatomic, copy) NSString *serviceSessionSubcategoryId;

@end
