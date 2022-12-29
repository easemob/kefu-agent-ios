//
//  KFIframeModel.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFIframeModel : NSObject <NSCoding>
@property (nonatomic, copy) NSString *iframeName;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *encryptKey;
@property (nonatomic, assign) BOOL encryptAll;

@property (nonatomic, copy) NSString *iframeRobotName;
@property (nonatomic, copy) NSString *roboturl;
@property (nonatomic, copy) NSString *robotencryptKey;
@property (nonatomic, assign) BOOL robotencryptAll;



@end

NS_ASSUME_NONNULL_END
