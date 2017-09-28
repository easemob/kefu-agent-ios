//
//  HDBaseMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HDMessageBodyTypeText = 0,   //文字消息
    HDMessageBodyTypeImage,      //图片消息
    HDMessageBodyTypeVoice,      //语音消息
    HDMessageBodyTypeFile,       //文件消息
    HDMessageBodyTypeVideo,      //视频消息
    HDMessageBodyTypeCommand,     //命令消息
    HDMessageBodyTypeLocation,   //位置消息
    HDMessageBodyTypeImageText,  //轨迹
}HDMessageBodyType;

@interface HDBaseMessageBody : NSObject

/*
 *  消息体类型
 */
@property (nonatomic, readonly) HDMessageBodyType type;


- (NSDictionary *)selfDicDesc;

@end
