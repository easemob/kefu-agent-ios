//
//  KFHttpManager.h
//  EMCSApp
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface KFHttpManager : AFHTTPSessionManager
singleton_interface(KFHttpManager)
/**
 下载文件

 @param urlPath 文件的url
 @param completion 返回文件的NSData
 @return
 */
- (NSURLSessionDownloadTask *)asyncDownLoadFileWithFilePath:(NSString*)urlPath
                                                       completion:(void(^)(id responseObject,NSError *error))completion;

#pragma mark - 管理员

//会话总数
- (void)asyncGetCountWithPath:(NSString *)path
                   parameters:(NSDictionary *)parameters
                   completion:(void(^)(id responseObject,NSError *error))completion;
//会话量趋势
- (void)asyncGetSessionTrendWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject,NSError *error))completion;
//消息量趋势
- (void)asyncGetMessageTrendWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject,NSError *error))completion;
//今日客服新进会话数
- (void)aysncGetNewSessionTodayWithPath:(NSString *)path completion:(void (^)(id responseObject, NSError *error))completion;

- (void)asyncGetTrendDataWithUrl:(NSString *)url  parameters:(NSDictionary *)parameters completion:(void (^)(id responseObject,NSError *error))completion;

#pragma mark 现场管理
- (void)asyncGetAgentQueuesWithPath:(NSString *)path
                         completion:(void(^)(id responseObject,NSError *error))completion;
//管理详情
- (void)asyncGetMonitorDetailWithPath:(NSString *)path
                           completion:(void(^)(id responseObject,NSError *error))completion;

//告警信息
- (void)asyncGetWarningsWithPath:(NSString *)path
                       pageIndex:(NSInteger)pageIndex
                        pageSize:(NSInteger)pageSize
                      completion:(void(^)(id responseObject,NSError *error))completion;

@end
