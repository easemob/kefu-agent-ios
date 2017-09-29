//
//  HDFileMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HDDownloadStatus) {
    HDDownloadStatusDownloading =0, //正在下载
    HDDownloadStatusSucceed,    //下载成功
    HDDownloadStatusFailed, //下载失败
    HDDownloadStatusPending //准备下载
};

//附件

#import <Foundation/Foundation.h>

@interface HDFileMessageBody : HDBaseMessageBody


/**
 附件显示名称
 */
@property (nonatomic, copy) NSString *displayName;


/**
 附件本地路径
 */
@property(nonatomic,copy) NSString *localPath;


/**
 附件远程路径
 */
@property(nonatomic,copy) NSString *remotePath;


/**
 附件大小:byte
 */
@property (nonatomic) long long fileLength;


/**
 初始化消息体

 @param localPath 本地路径
 @param displayName 显示名称
 @return 实例
 */
- (instancetype)initWithLocalPath:(NSString *)localPath
                      displayName:(NSString *)displayName;


/**
 初始化消息体

 @param data 数据
 @param displayName 显示名称
 @return 实例
 */
- (instancetype)initWithData:(NSData *)data
                 displayName:(NSString *)displayName;

@end
