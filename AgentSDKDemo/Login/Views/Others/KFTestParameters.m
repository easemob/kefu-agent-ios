//
//  KFTestParameters.m
//  EMCSApp
//
//  Created by afanda on 16/11/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFTestParameters.h"
#import "Helper.h"

@implementation KFTestParameters

/**
 @property (nonatomic, copy) NSString *username;   //用户名/邮箱
 @property (nonatomic, copy) NSString *password;   //密码
 @property (nonatomic, copy) NSString *confirmPsw; //确认密码
 @property (nonatomic, copy) NSString *company;    //公司
 @property (nonatomic, copy) NSString *phone;      //电话号码
 @property (nonatomic, copy) NSString *codeValue;  //输入的图形验证码
 */

- (NSString *)testParametersWithDictionary:(NSDictionary *)dict {
    if (dict == nil)  return @"请填写注册信息";
    if ([[dict valueForKey:@"username"] isEqualToString:@""]) {
        return @"邮箱(用户名)不能为空";
    }
    if ([[dict valueForKey:@"password"] isEqualToString:@""]) {
        return @"请填写密码";
    }
    if ([[dict valueForKey:@"confirmPsw"] isEqualToString:@""]) {
        return @"请确认密码";
    }
    if ([[dict valueForKey:@"company"] isEqualToString:@""]) {
        return @"请填写所在公司";
    }
    if ([[dict valueForKey:@"phone"] isEqualToString:@""]) {
        return @"请填写手机号";
    }
    if ([[dict valueForKey:@"codeValue"] isEqualToString:@""]) {
        return @"请填写图形验证码,如果没有图形验证码,请点击验证码区域刷新";
    }
    
    if (![Helper isEmail:[dict valueForKey:@"username"]]) {
        return @"请检查邮箱格式";
    }
    if (![Helper isPasswordLength:[dict valueForKey:@"password"]]) {
        return @"密码有效长度6~22位";
    }
    if (![Helper isPasswordFormat:[dict valueForKey:@"password"]]) {
        return @"密码至少包含大写字母、小写字母、数字、符号中的两种";
    }
    if (![[dict valueForKey:@"password"] isEqualToString:[dict valueForKey:@"confirmPsw"]]) {
        return @"两次输入密码不一致";
    }
    if (![Helper isMobile:[dict valueForKey:@"phone"]]) {
        return @"手机格式不正确";
    }
    
    return nil;
}

@end
