//
//  KDAuthManager.h
//  KDAuthSDK
//
//  Created by sinapocket on 2017/11/13.
//
//

#import <Foundation/Foundation.h>


@interface KDAuthManager : NSObject

/**
 获取单例
 
 @return 返回授权管理单例
 */
+ (KDAuthManager *)manager;

/**
 获取sdk版本
 
 @return sdk版本
 */
+ (NSString *)getSdkVersion;

/**
 是否已安装口袋（需将口袋加入白名单）
 
 @return 结果
 */
+ (BOOL)isKDAppInstalled;

/**
 去安装口袋网页
 */
+ (void)goInstallKouDai;

/**
 获取授权结果
 
 @param appid 应用唯一标识
 @param params 用户参数
 @param result 结果回调
 */
- (void)getKDAuthWithAppid:(NSString *)appid
                    userid:(NSString *)userid
                    params:(NSDictionary *)params
                    result:(void(^)(BOOL bResult, NSInteger authResult,NSDictionary *dicInfo))result;

/**
 注销授权
 
 @param result 注销结果
 */
- (void)logOutResult:(void(^)(BOOL bResult,NSError *error))result;


@end
