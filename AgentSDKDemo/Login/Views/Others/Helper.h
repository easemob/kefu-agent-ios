//
//  Helper.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject

//邮箱
+ (BOOL) isEmail:(NSString *)email;
//密码长度限制
+ (BOOL) isPasswordLength:(NSString *)passWord;
//密码格式限制
+ (BOOL) isPasswordFormat:(NSString *)passWord;
//手机号码验证
+ (BOOL) isMobile:(NSString *)mobile;

@end


