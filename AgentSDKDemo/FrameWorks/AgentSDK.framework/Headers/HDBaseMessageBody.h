//
//  HDBaseMessageBody.h
//  AgentSDK
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MESSAGEBODY @"body"
#define MESSAGEBODY_MSGEXT @"ext"

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

@property(nonatomic,copy) NSDictionary *msgExt;

/*
 *  消息体类型
 */
@property (nonatomic, readonly) HDMessageBodyType type;


- (NSMutableDictionary *)selfDicDesc;


@end

@interface MessageUserModel : NSObject

@property (copy, nonatomic) NSString* nicename;
@property (nonatomic) NSInteger tenantId;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary*)messageUserModelDicDesc;

@end

@interface MessageExtMsgtypeModel : NSObject

@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *imgUrl;
@property (copy, nonatomic) NSString *itemUrl;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *orderTitle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary*)selfDicDesc;

@end

@interface MessageExtModel : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *price;

@property (copy, nonatomic) NSString *imageName;
@property (strong, nonatomic) MessageExtMsgtypeModel *msgtype;
@property (copy, nonatomic) NSString *type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary*)selfDicDesc;
@end


