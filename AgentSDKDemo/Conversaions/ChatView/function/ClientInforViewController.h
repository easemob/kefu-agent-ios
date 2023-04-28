//
//  ClientInforViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXBaseViewController.h"


@interface ClientInforViewController : DXBaseViewController

@property (nonatomic, copy) NSString *niceName; //昵称
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) UIImage *tagImage; //标记来源
@property (nonatomic, strong) VisitorUserModel *vistor;
@property (nonatomic, assign) BOOL readOnly;
@property (nonatomic, copy) NSString *serviceSessionId;
@property (nonatomic, strong) HDConversation *conversation;

@end
