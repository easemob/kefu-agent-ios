//
//  HDGrayModel.h
//  helpdesk_sdk
//
//  Created by houli on 2022/4/13.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDGrayModel : NSObject
@property (nonatomic, copy) NSString * grayName;
@property (nonatomic, copy) NSString * grayNameId;
@property (nonatomic, copy) NSString * grayNameTenantId;
@property (nonatomic, copy) NSString * status; //灰度状态 Enable 启用
@property (nonatomic, copy) NSString * createDateTime;
@property (nonatomic, copy) NSString * expireDatetime;
@property (nonatomic, copy) NSString * functionName;
@property (nonatomic, copy) NSString * lastUpdateDateTime;
@property (nonatomic, assign) BOOL  enable; //yes 启用 no 不启用

@end

NS_ASSUME_NONNULL_END
