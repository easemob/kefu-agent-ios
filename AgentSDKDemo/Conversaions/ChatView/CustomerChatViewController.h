//
//  CustomerChatViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface CustomerChatViewController : UIViewController
{
    NSInteger _page;
}

@property (nonatomic, strong) UserModel *userModel;
@property (nonatomic, strong) ConversationModel *model;

@end
