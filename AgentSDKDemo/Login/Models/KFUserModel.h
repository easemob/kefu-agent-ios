//
//  KFUserModel.h
//  EMCSApp
//
//  Created by afanda on 16/11/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFUserModel : NSObject
@property(nonatomic,copy) NSString *username;   //用户名/邮箱
@property(nonatomic,copy) NSString *password;   //密码
@property(nonatomic,copy) NSString *confirmPsw; //确认密码
@property(nonatomic,copy) NSString *company;    //公司
@property(nonatomic,copy) NSString *codeId;     //图形验证码id
@property(nonatomic,copy) NSString *phone;      //电话号码
@property(nonatomic,copy) NSString *codeValue;  //输入的图形验证码
@property(nonatomic,copy) NSString *verifyCode; //输入的手机验证码
@end
