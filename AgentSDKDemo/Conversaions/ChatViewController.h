//
//  ChatViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/15.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ChatViewTypeChat,
    ChatViewTypeNoChat,
    ChatViewTypeCallBackChat
}ChatViewType;


@protocol ChatViewControllerDelegate <NSObject>
- (void)refreshConversationList;
@end

@interface ChatViewController : UIViewController

@property(nonatomic,assign) id<ChatViewControllerDelegate> delegate;
@property (strong, nonatomic) ConversationModel* conversationModel;
@property (copy, nonatomic) NSString *notifyNumber;

- (instancetype)initWithtype:(ChatViewType)type;

+ (BOOL)isExistFile:(MessageModel*)model;

@end
