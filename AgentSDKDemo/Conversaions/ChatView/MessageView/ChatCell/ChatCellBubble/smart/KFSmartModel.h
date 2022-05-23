//
//  KFSmartModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HDSmartExtMsgType) {
    HDSmartExtMsgTypeGeneral = 0, //正常消息
    HDSmartExtMsgTypeMenu ,  //菜单消息
    HDSmartExtMsgTypeImamge, //图片
    HDSmartExtMsgTypeText,   //文本
    HDSmartExtMsgTypearticle, //图文
    HDSmartExtMsgTypeGroup // 答案组
};
@interface KFSmartModel : NSObject


@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSArray *answerDataGroup;
@property (nonatomic, copy) NSString *answerId;
@property (nonatomic, copy) NSString *audioLength;
@property (nonatomic, copy) NSString *cooperationSource;
@property (nonatomic, copy) NSDictionary *ext;
@property (nonatomic, assign) NSInteger sendFrequencyStr;
@property (nonatomic, assign) NSInteger quoteFrequencyStr;
@property (nonatomic, assign) HDSmartExtMsgType msgtype;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *imageHeight;
@property (nonatomic, copy) NSString *imageWidth;
@property (nonatomic, copy) NSString *length;
@property (nonatomic, copy) NSString *mediaFileUrl;
@property (nonatomic, copy) NSString *mediaId;
@property (nonatomic, copy) NSString *cancelFrequencyStr;
@property (nonatomic, copy) UIImage *sendImage;
@property (nonatomic,assign)CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
