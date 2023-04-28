//
//  Helper.m
//

#import "Helper.h"

@implementation Helper

+ (BOOL) isEmail:(NSString *)email
{
    NSString *emailRegex = @"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL) isPasswordLength:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9_,\\.;\\:\"'!*&]{6,22}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

+ (BOOL)isPasswordFormat:(NSString *)passWord {
    NSString *passWordRegex = @"^(?![A-Z]+$)(?![a-z]+$)(?!\\d+$)(?![\\W_]+$)\\S+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

+ (BOOL) isMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}




+ (NSString *)getMessageContent:(HDMessage *)message {
    NSString *content = @"";
    switch (message.type) {
        case HDMessageBodyTypeText: {
            HDExtMsgType type = HDExtMsgTypeGeneral;
            type = [HDUtils getMessageExtType:message];
            if (type == HDExtMsgTypeForm) {
                content = @"[表单]";
                break;
            }
            HDTextMessageBody *body = (HDTextMessageBody *)message.nBody;
            content = body.text;
            break;
        }
        case HDMessageBodyTypeImage: {
            content = @"[图片]";
            break;
        }
        case HDMessageBodyTypeVoice:{
            content = @"[语音]";
            break;
        }
        case HDMessageBodyTypeFile:{
            content = @"[文件]";
            break;
        }
        case HDMessageBodyTypeImageText:{
            content = @"[轨迹消息]";
            break;
        }
        case HDMessageBodyTypeLocation: {
            content = @"[位置消息]";
            break;
        }
        case HDMessageBodyTypeVideo: {
            content = @"[视频]";
            break;
        }
        default:
            content = @"[自定义消息]";
            break;
    }
    return content;
}

@end
