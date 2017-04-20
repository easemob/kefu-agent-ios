//
//  MessageBodyModel.h
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define MESSAGEBODY @"body"
#define MESSAGEBODY_FILENAME @"filename"
#define MESSAGEBODY_THUMB_SECRET @"thumb_secret"
#define MESSAGEBODY_THUMBPATH @"thumb"
#define MESSAGEBODY_SIZE @"size"
#define MESSAGEBODY_HEIGHT @"height"
#define MESSAGEBODY_WIDHT @"width"
#define MESSAGEBODY_SECRET @"secret"
#define MESSAGEBODY_ORIGINALPATH @"url"
#define MESSAGEBODY_TYPE @"type"
#define MESSAGEBODY_LAT @"lat"
#define MESSAGEBODY_LNG @"lng"
#define MESSAGEBODY_ADDR @"addr"
#define MESSAGEBODY_LENGTH @"length"
#define MESSAGEBODY_FILE_LENGTH @"file_length"
#define MESSAGEBODY_MSGTYPE @"msgtype"
#define MESSAGEBODY_MSGEXT @"ext"

#define MESSAGEEXT_NAME @"name"
#define MESSAGEEXT_PEICE @"price"


typedef enum {
    kefuMessageBodyType_Text = 0,   //文字消息
    kefuMessageBodyType_Image,      //图片消息
    kefuMessageBodyType_Location,   //位置消息
    kefuMessageBodyType_ImageText,  //轨迹
    kefuMessageBodyType_Voice,      //语音消息
    kefuMessageBodyType_File,       //文件消息
    kefuMessageBodyType_Video,      //视频消息
    kefuMessageBodyType_Command     //命令消息
}KefuMessageBodyType;

@interface MessageBodyModel : NSObject

@property (copy, nonatomic) NSString *fileName;
@property (copy ,nonatomic) NSString *thumbSecret;
@property (copy, nonatomic) NSString *thumbPath;
@property (copy, nonatomic) NSString *secret;
@property (copy, nonatomic) NSString *originalPath;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSDictionary *msgExt;
@property(nonatomic,strong) UIImage *image;
@property (nonatomic) KefuMessageBodyType type;
@property (nonatomic) CGFloat fileSize;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (copy, nonatomic) NSString *addr;
@property (nonatomic) double lat;
@property (nonatomic) double lng;

@property (nonatomic) CGFloat length;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary*)selfDicDesc;

#pragma mark - 构造各类消息
//构造文字消息
- (instancetype)initWithText:(NSString *)text;
//构造图片消息
- (instancetype)initWithUIImage:(UIImage *)image;
//构造语音消息
- (instancetype)initWithAudioLocalPath:(NSString *)localPath;



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

