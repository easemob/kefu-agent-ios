//
//  HDWhiteboardManager.h
//  HelpDeskLite
//
//  Created by houli on 2022/4/8.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDOnlineWhiteboardManagerDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface HDOnlineWhiteboardManager : NSObject
+ (instancetype _Nullable )shareInstance;
#pragma mark - Delegate
/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 */
- (void)addDelegate:(id<HDOnlineWhiteboardManagerDelegate>_Nullable)aDelegate
      delegateQueue:(dispatch_queue_t _Nullable )aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 */
- (void)removeDelegate:(id<HDOnlineWhiteboardManagerDelegate>_Nullable)aDelegate;

#pragma mark - 上传文档
- (void)whiteBoardUploadFileWithFilePath:(NSString *)filePath
                                fileData:(NSData *)data
                                fileName:(NSString *)fileName
                                mimeType:(NSString *)mimeType
                                 progress:(void (^)(int64_t total, int64_t now)) progress
                                completion:(void(^)(id responseObject,HDError *error))completion;

- (void)hd_joinWiteBoardRoom;
- (void)hd_joinVecWiteBoardRoom;
//文档转换
- (void)hd_wordConverterPptPage:(NSString *)url type:(NSString *)type completion:(void (^)(id _Nonnull responseObject, HDError * _Nonnull error))completion;
//文档转换进度
- (void)hd_wordConverterPptPageProgress:(NSString *)url type:(NSString *)type callId:(NSString *)callId taskId:(NSString *)taskid completion:(void (^)(id, HDError *))completion;

//转码签名
- (void)hd_whiteConverterPptPage:(NSDictionary *) page completion:(void (^)(id _Nonnull responseObject, HDError * _Nonnull error))completion;
@end

NS_ASSUME_NONNULL_END
