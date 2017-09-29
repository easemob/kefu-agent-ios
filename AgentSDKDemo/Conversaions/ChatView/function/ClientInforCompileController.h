//
//  ClientInforCompileController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/18.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ClientInforCompileControllerDelegate <NSObject>

- (void)saveClientInfor;

- (void)saveParameter:(NSString*)value key:(NSString*)key;

- (void)savePatameter:(NSString *)value index:(NSInteger)index;

@end

@interface ClientInforCompileController : UIViewController

@property(nonatomic,assign) BOOL isPlaceHolder;
@property(nonatomic,assign) BOOL isNumberPad;
@property (copy, nonatomic) NSString *editContent;

@property (weak, nonatomic) id<ClientInforCompileControllerDelegate> delegate;

- (instancetype)initWithType:(int)type;

@end
