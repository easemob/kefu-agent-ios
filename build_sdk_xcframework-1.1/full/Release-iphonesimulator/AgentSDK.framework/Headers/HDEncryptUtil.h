//
//  HDEncryptUtil.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2019/2/13.
//  Copyright © 2019 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDEncryptUtil : NSObject
//十六进制加密
+ (NSString *)encryptUseDESData:(NSString *)clearText key:(NSString *)key;
//十六进制解密
+ (NSString*)decryptUseDESData:(NSString*)cipherText key:(NSString*)key;

//
+ (NSString *)encryptUseDES:(NSString *)clearText key:(NSString *)key;
+ (NSString*)decryptUseDES:(NSString*)cipherText key:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
