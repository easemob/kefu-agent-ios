//
//  CustomerChatViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//  客服聊天窗口

#import <UIKit/UIKit.h>

@interface CustomerChatViewController : EMBaseViewController
{
    NSInteger _page;
}

@property (nonatomic, strong) UserModel *userModel;
@property (nonatomic, strong) HDConversation *model;

@end
