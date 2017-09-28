//
//  HDImageMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDFileMessageBody.h"

@interface HDImageMessageBody : HDFileMessageBody



/**
 图片附件尺寸
 */
@property(nonatomic,assign) CGSize size;


/**
 缩略图名称
 */
@property (nonatomic, copy) NSString *thumbnailDisplayName;

/*
 *  缩略图的本地路径
 */
@property (nonatomic, copy) NSString *thumbnailLocalPath;

/*
 *  缩略图远程路径
 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;


/*
 *  缩略图的尺寸
 */
@property (nonatomic) CGSize thumbnailSize;

/*
 *  缩略图文件的大小, 以字节为单位
 */
@property (nonatomic) long long thumbnailFileLength;


/**
 图片数据
 */
@property(nonatomic,strong) NSData *imageData;

/*!
 *  \~chinese
 *  缩略图下载状态
 *
 *  \~english
 *  Download status of a thumbnail
 */
@property (nonatomic)HDDownloadStatus thumbnailDownloadStatus;

//构造图片消息
- (instancetype)initWithUIImage:(UIImage *)image displayName:(NSString *)displayName;

@end
