//
//  HDError.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDErrorCode.h"

/*!
 *  \~chinese
 *  SDK定义的错误
 *
 *  \~english
 *  SDK defined error
 */
@interface HDError : NSObject
/*!
 *  \~chinese
 *  错误码
 *
 *  \~english
 *  Error code
 */
@property (nonatomic) HDErrorCode code;

/*!
 *  \~chinese
 *  错误描述
 *
 *  \~english
 *  Error description
 */
@property (nonatomic, copy) NSString *errorDescription;


/*!
 *  \~chinese
 *  初始化错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 错误实例
 */
- (instancetype)initWithDescription:(NSString *)aDescription
                               code:(HDErrorCode)aCode;

/*!
 *  \~chinese
 *  创建错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 对象实例
 */
+ (instancetype)errorWithDescription:(NSString *)aDescription
                                code:(HDErrorCode)aCode;

+ (instancetype)errorWithDescription:(NSError *)error;

@end
