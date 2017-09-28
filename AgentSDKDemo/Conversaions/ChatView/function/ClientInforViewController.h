//
//  ClientInforViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXBaseViewController.h"


@interface ClientInforViewController : DXBaseViewController

@property(nonatomic,copy) NSString *niceName; //昵称
@property(nonatomic,strong) UIImage *tagImage; //标记来源

@property(nonatomic,copy) NSString *customerId;

@property (copy, nonatomic) NSString* userId;

@property (strong, nonatomic) VisitorUserModel* vistor;

@property(nonatomic,assign) BOOL readOnly;

@end
