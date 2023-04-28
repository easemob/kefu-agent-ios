//
//  KFIframeModel.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KFIframeModel :JSONModel
@property (nonatomic, copy) NSString<Optional> *iFrameId;
@property (nonatomic, copy) NSString<Optional> *createDatetime;
@property (nonatomic, assign) BOOL iframeEcryptAll;
@property (nonatomic, copy) NSString<Optional> *iframeEncryptKey;
@property (nonatomic, copy) NSString<Optional> *iframeId;
@property (nonatomic, copy) NSString<Optional> *iframeLoadTimeout;
@property (nonatomic, assign) BOOL iframeOrder;
@property (nonatomic, assign) BOOL iframeSyncVisitorMsg;
@property (nonatomic, copy) NSString<Optional> *iframeTabTitle;
@property (nonatomic, copy) NSString<Optional> *iframeUrl;
@property (nonatomic, copy) NSString<Optional> *updateDateTime;
@property (nonatomic, assign) NSUInteger tenantId;


@end

NS_ASSUME_NONNULL_END
