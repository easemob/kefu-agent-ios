//
//  HDVideoMessageBody.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/12/28.
//  Copyright © 2018 环信. All rights reserved.
//

#import <AgentSDK/AgentSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDVideoMessageBody : HDBaseMessageBody

/**
 附件显示名称
 */
@property (nonatomic, copy) NSString *displayName;


/**
 附件本地路径
 */
@property (nonatomic, copy) NSString *localPath;


/**
 附件远程路径
 */
@property (nonatomic, copy) NSString *remotePath;


/*
 *  视频时长, 秒为单位, 目前未使用
 */
@property (nonatomic) int duration;

/*
 *  视频大小, 目前未使用
 */
@property (nonatomic) long long fileLength;


@end

NS_ASSUME_NONNULL_END
