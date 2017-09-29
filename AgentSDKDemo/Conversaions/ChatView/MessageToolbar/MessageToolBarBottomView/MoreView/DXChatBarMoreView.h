/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>

typedef enum{
    ChatMoreTypeChat,
    ChatMoreTypeClientChat,
    ChatMoreTypeGroupChat,
}ChatMoreType;

@protocol DXChatBarMoreViewDelegate;
@interface DXChatBarMoreView : UIView

@property (nonatomic,assign) id<DXChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *quickReplyButton;
@property (nonatomic, strong) UIButton *transferButton;
@property (nonatomic, strong) UIButton *customButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;

- (instancetype)initWithFrame:(CGRect)frame typw:(ChatMoreType)type;

- (void)setupSubviewsForType:(ChatMoreType)type;

@end

@protocol DXChatBarMoreViewDelegate <NSObject>

@required
- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView;
/*
- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView;
- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView;
- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView;
- (void)moreViewSatisfactionyAction:(DXChatBarMoreView *)moreView;
*/

@optional
- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView;
- (void)moreViewTransferAction:(DXChatBarMoreView *)moreView;
- (void)moreViewQuickReplyAction:(DXChatBarMoreView *)moreView;
- (void)moreViewCustomAction:(DXChatBarMoreView *)moreView;

@end


