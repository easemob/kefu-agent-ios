//
//  ChatSendHelper.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ChatSendHelper.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+Formatter.h"

@implementation UIImage (save)

- (NSString*)saveImageWithTime:(NSTimeInterval)time;
{
    NSData *data = UIImageJPEGRepresentation(self, 1);
    NSString *tempPath = NSTemporaryDirectory();
    tempPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.jpg",time]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:tempPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return tempPath;
}

@end

@implementation ChatSendHelper


+(HDMessage *)sendTextMessageWithString:(NSString *)str toUser:(NSString *)userId sessionId:(NSString*)sessionId
{
    return [self sendTextMessageWithString:str toUser:userId sessionId:sessionId ext:nil];
}

+(NSDictionary *)uploadImage:(HDMediaFile*)media
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"" forKey:@"msg"];
    [parameters setObject:@"img" forKey:@"type"];
    if (media.fileName) {
        [parameters setObject:media.fileName forKey:@"filename"];
    }
    if (media.uuid) {
        [parameters setObject:media.uuid forKey:@"mediaId"];
    }
    if (media.url) {
        [parameters setObject:media.url forKey:@"thumb"];
    }
    [parameters setObject:@(0) forKey:@"imageWidth"];
    [parameters setObject:@(0) forKey:@"imageHeight"];
    return parameters;
}

+ (NSDictionary *)uploadAudio:(HDMediaFile *)media {
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:@"audio" forKey:@"type"];
    if (media.fileName) {
        [parameters setObject:media.fileName forKey:@"filename"];
    }
    if (media.uuid) {
        [parameters setObject:media.uuid forKey:@"mediaId"];
    }
    if (media.url) {
        [parameters setObject:media.url forKey:@"url"];
    }
    [parameters setValue:@(media.contentLength) forKey:@"file_length"];
    [parameters setValue:@"" forKey:@"secret"];
    [parameters setValue:@(media.duration) forKey:@"audioLength"];
    
    return parameters;
}


#pragma mark - new

//客服同事文字消息
+ (HDMessage *)customerTextMessageFormatWithText:(NSString *)text to:(NSString *)toUser {
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    HDTextMessageBody *bdy = [[HDTextMessageBody alloc] initWithText:willSendText];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:toUser to:toUser messageBody:bdy];
    return message;
}

//客服同事image消息
+ (HDMessage *)customerImageMessageFormatWithImageData:(NSData *)imageData to:(NSString *)toUser {
    HDImageMessageBody *bdy = [[HDImageMessageBody alloc] initWithData:imageData displayName:@"imageName"];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:toUser to:toUser messageBody:bdy];
    return message;
}

//文字
+ (HDMessage *)textMessageFormatWithText:(NSString *)text to:(NSString *)toUser sessionId:(NSString *)sessionId {
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    HDTextMessageBody *bdy = [[HDTextMessageBody alloc] initWithText:willSendText];
//    bdy.msgExt = @{@"key":@"value1"};
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:bdy];
//    NSLog(@"body.msgExt:%@",bdy.msgExt);
    return message;
}

//图片
+ (HDMessage *)imageMessageFormatWithImageData:(NSData *)data to:(NSString *)toUser sessionId:(NSString *)sessionId {
    HDImageMessageBody *bdy = [[HDImageMessageBody alloc] initWithData:data displayName:@"imagetest"];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:bdy];
    return message;
}

+ (HDMessage *)voiceMessageFormatWithPath:(NSString *)path to:(NSString *)toUser sessionId:(NSString *)sessionId {
    HDVoiceMessageBody *bdy = [[HDVoiceMessageBody alloc] initWithLocalPath:path displayName:@"voicetest"];
    HDMessage *message = [[HDMessage alloc] initWithSessionId:sessionId to:toUser messageBody:bdy];
    
    return message;
}




@end
