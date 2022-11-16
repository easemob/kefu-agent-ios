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

#import "DXChatBarMoreView.h"
#import "KFChatBarMoreModel.h"
#define CHAT_BUTTON_SIZE 80
#define CHAT_BUTTON_HEIGHT 90
#define CHAT_BUTTON_IMAGE_EDGEINSETS UIEdgeInsetsMake(0,7.5,25,7.5)
#define CHAT_BUTTON_TITLE_EDGEINSETS UIEdgeInsetsMake(CHAT_BUTTON_SIZE - 10, -CHAT_BUTTON_SIZE + 15, 0, 0)
#define INSETS 8
#define CHAT_IMAGE_UIEDGE 10
#define CHAT_BUTTON_TEXT_FONT 12
#define CHAT_BUTTON_TEXT_COLOR BUTTON_TITLE_COLOR

#define CHAT_BUTTON_TAG 1111

@implementation DXChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame typw:(KFChatMoreType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.backgroundColor = [UIColor clearColor];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
        [self addSubview:backgroundImageView];
        [self setupSubviewsForType:type];
        
    }
    return self;
}

- (void)setupSubviewsForType:(KFChatMoreType)type
{
    self.backgroundColor = [UIColor clearColor];
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
    [self constructDataCustomBtn];
    _takePicButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicButton setFrame:CGRectMake(insets, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
    [_takePicButton setImage:[UIImage imageNamed:@"btn_icon_camera"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"btn_icon_camera"] forState:UIControlStateHighlighted];
    [_takePicButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
    [_takePicButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    [_takePicButton setTitle:@"相机" forState:UIControlStateNormal];
    [_takePicButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
    [_takePicButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [_takePicButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _takePicButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
    _takePicButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_takePicButton];
    
    _fileButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_fileButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
    [_fileButton setImage:[UIImage imageNamed:@"btn__icon_qubz"] forState:UIControlStateNormal];
    [_fileButton setImage:[UIImage imageNamed:@"btn__icon_qubz"] forState:UIControlStateHighlighted];
    [_fileButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
    [_fileButton addTarget:self action:@selector(fileAction) forControlEvents:UIControlEventTouchUpInside];
    [_fileButton setTitle:@"文件" forState:UIControlStateNormal];
    [_fileButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
    [_fileButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [_fileButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _fileButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
    _fileButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_fileButton];
    
    _quickReplyButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_quickReplyButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
    [_quickReplyButton setImage:[UIImage imageNamed:@"btn_icon_phrase"] forState:UIControlStateNormal];
    [_quickReplyButton setImage:[UIImage imageNamed:@"btn_icon_phrase"] forState:UIControlStateHighlighted];
    [_quickReplyButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
    [_quickReplyButton addTarget:self action:@selector(quickReplyAction) forControlEvents:UIControlEventTouchUpInside];
    [_quickReplyButton setTitle:@"常用语" forState:UIControlStateNormal];
    [_quickReplyButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
    [_quickReplyButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [_quickReplyButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _quickReplyButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
    _quickReplyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_quickReplyButton];
    
    [self createBtn:insets];
    
    
//    if ( [HDClient sharedClient].currentAgentUser.agoraVideoEnable) {
//
//        _videoButton =[UIButton buttonWithType:UIButtonTypeCustom];
//        [_videoButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE *2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
//        [_videoButton setImage:[UIImage imageNamed:@"btn__icon_video"] forState:UIControlStateNormal];
//        [_videoButton setImage:[UIImage imageNamed:@"btn__icon_video"] forState:UIControlStateHighlighted];
//        [_videoButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
//        [_videoButton addTarget:self action:@selector(takeVideoAction) forControlEvents:UIControlEventTouchUpInside];
//        [_videoButton setTitle:@"视频通话" forState:UIControlStateNormal];
//        [_videoButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
//        [_videoButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
//        [_videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        _videoButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
//        _videoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:_videoButton];
//
//    }else{
//
//
//    }
   
    
    
    
    
    CGRect frame = self.frame;
    if (type == KFChatMoreTypeChat) {
//        _quickReplyButton =[UIButton buttonWithType:UIButtonTypeCustom];
//        if ( [HDClient sharedClient].currentAgentUser.agoraVideoEnable) {
//
//            [_quickReplyButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
//
//        }else{
//
//            [_quickReplyButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
//        }
//
//
//
//        [_quickReplyButton setImage:[UIImage imageNamed:@"btn_icon_phrase"] forState:UIControlStateNormal];
//        [_quickReplyButton setImage:[UIImage imageNamed:@"btn_icon_phrase"] forState:UIControlStateHighlighted];
//        [_quickReplyButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
//        [_quickReplyButton addTarget:self action:@selector(quickReplyAction) forControlEvents:UIControlEventTouchUpInside];
//        [_quickReplyButton setTitle:@"常用语" forState:UIControlStateNormal];
//        [_quickReplyButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
//        [_quickReplyButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
//        [_quickReplyButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//        _quickReplyButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
//        _quickReplyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:_quickReplyButton];
//
        /*
        _transferButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_transferButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
        [_transferButton setImage:[UIImage imageNamed:@"icon_keyboard_chenge"] forState:UIControlStateNormal];
        [_transferButton setImage:[UIImage imageNamed:@"icon_keyboard_chenge"] forState:UIControlStateHighlighted];
        [_transferButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
        [_transferButton addTarget:self action:@selector(transferAction) forControlEvents:UIControlEventTouchUpInside];
        [_transferButton setTitle:@"转接" forState:UIControlStateNormal];
        [_transferButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
        [_transferButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [_transferButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
        _transferButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_transferButton];*/
        
//        if ([[HDClient sharedClient].currentAgentUser.customUrl length] > 0) {
//            _customButton =[UIButton buttonWithType:UIButtonTypeCustom];
//            if ( [HDClient sharedClient].currentAgentUser.agoraVideoEnable) {
//
//                [_customButton setFrame:CGRectMake(insets, 216/2, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
//
//            }else{
//
//                [_customButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
//            }
//
//            [_customButton setImage:[UIImage imageNamed:@"btn_icon_iframe"] forState:UIControlStateNormal];
//            [_customButton setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
//            [_customButton addTarget:self action:@selector(customeAction) forControlEvents:UIControlEventTouchUpInside];
//            [_customButton setTitle:@"自定义消息" forState:UIControlStateNormal];
//            [_customButton setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
//            [_customButton setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
//            [_customButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//            _customButton.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
//            _customButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//            [self addSubview:_customButton];
//            frame.size.height = 216;
//        }
//        else{
//            frame.size.height = 108;
//        }
    }
    else if (type == KFChatMoreTypeGroupChat)
    {
        frame.size.height = 80;
    } else if (type == KFChatMoreTypeCustomerChat) {
        if ([HDClient sharedClient].currentAgentUser.agoraVideoEnable) {
            
            frame.size.height = 216;
            
        }else{
           
            frame.size.height = 108;
        }
        
    }
    self.frame = frame;
}

#pragma mark - 自定义按钮组装
- (void)constructDataCustomBtn{
    
    [self.btnMarray removeAllObjects];
    if ([HDClient sharedClient].currentAgentUser.agoraVideoEnable) {
        
        KFChatBarMoreModel * videoMessageModel = [[KFChatBarMoreModel alloc] init];
        videoMessageModel.btnName =@"视频通话";
        videoMessageModel.btnType = KFChatMoreBtnVideoCall;
        [self.btnMarray addObject:videoMessageModel];
    }
    if ([[HDClient sharedClient].currentAgentUser.customUrl length] > 0) {
        
        KFChatBarMoreModel *customMessageModel = [[KFChatBarMoreModel alloc] init];
        customMessageModel.btnType = KFChatMoreBtnCustomMessage;
        customMessageModel.btnName =@"自定义消息";
        [self.btnMarray addObject:customMessageModel];
    }
    if([[HDClient sharedClient].currentAgentUser.iframeModel.url length] > 0){

        KFChatBarMoreModel *iframeMessageModel = [[KFChatBarMoreModel alloc] init];
        iframeMessageModel.btnType = KFChatMoreBtnIframeBase;
        iframeMessageModel.btnName =[HDClient sharedClient].currentAgentUser.iframeModel.iframeName;
        [self.btnMarray addObject:iframeMessageModel];


    }
    if([[HDClient sharedClient].currentAgentUser.iframeModel.roboturl length] > 0){

        KFChatBarMoreModel *iframeRobotMessageModel = [[KFChatBarMoreModel alloc] init];
        iframeRobotMessageModel.btnType = KFChatMoreBtnIframeRobot;
        iframeRobotMessageModel.btnName =[HDClient sharedClient].currentAgentUser.iframeModel.iframeRobotName;
        [self.btnMarray addObject:iframeRobotMessageModel];
    }
   
}
#pragma mark - 生产按钮
- (void)createBtn:(CGFloat)insets{
    __block int  t = 0;
    __block int  p = 1;
    [self.btnMarray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        KFChatBarMoreModel * model = obj;
        UIButton * btn =[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = CHAT_BUTTON_TAG + idx;
        if (idx == 0) {
           
            [btn setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];

        }else{
            
            // 如果是 2排
            if (t > 3) {
                p++;
                t = 0;
            }
//            float p = ceil((self.btnMarray.count -1 )/4.0);
            if (t == 0) {
                [btn setFrame:CGRectMake(insets , (CHAT_BUTTON_HEIGHT + 10 + 10)*p, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
            }else{
               
                [btn setFrame:CGRectMake(insets * (t+1) + CHAT_BUTTON_SIZE *t, (CHAT_BUTTON_HEIGHT + 10 + 10)*p , CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
                
            }
            t++;
            
            
        }
       
        switch (model.btnType) {
            case KFChatMoreBtnVideoCall:
                [btn setImage:[UIImage imageNamed:@"btn__icon_video"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"btn__icon_video"] forState:UIControlStateHighlighted];
                [btn setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
                [btn addTarget:self action:@selector(takeVideoAction) forControlEvents:UIControlEventTouchUpInside];
               
                break;
            case KFChatMoreBtnCustomMessage:
                [btn setImage:[UIImage imageNamed:@"btn_icon_iframe"] forState:UIControlStateNormal];
                [btn setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
                [btn addTarget:self action:@selector(customeAction) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            case KFChatMoreBtnIframeBase:
                [btn setImage:[UIImage imageNamed:@"btn_icon_iframe"] forState:UIControlStateNormal];
                [btn setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
                [btn addTarget:self action:@selector(iframeBaseAction) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            case KFChatMoreBtnIframeRobot:
                [btn setImage:[UIImage imageNamed:@"btn_icon_iframe"] forState:UIControlStateNormal];
                [btn setImageEdgeInsets:CHAT_BUTTON_IMAGE_EDGEINSETS];
                [btn addTarget:self action:@selector(iframeRobotAction) forControlEvents:UIControlEventTouchUpInside];
                
                break;
                
            default:
                break;
                
        }
        
        [btn setTitle:model.btnName forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:CHAT_BUTTON_TITLE_EDGEINSETS];
        [btn setTitleColor:CHAT_BUTTON_TEXT_COLOR forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:CHAT_BUTTON_TEXT_FONT];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:btn];
    
    }];
    
    NSLog(@"===当前自定义按钮行数===%d",p);
    CGRect frame = self.frame;
    frame.size.height = (CHAT_BUTTON_HEIGHT + 10 + 10)*(p+1);
    self.frame =frame;
}
#pragma mark - action

- (void)takePicAction{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}
- (void)takeVideoAction{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoAction:)]) {
        [_delegate moreViewVideoAction:self];
    }
}

- (void)fileAction{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewFileAction:)]) {
        [_delegate moreViewFileAction:self];
    }
}
/*
- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

- (void)takeVideoAction{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewVideoAction:self];
    }
}

- (void)takeAudioCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
        [_delegate moreViewAudioCallAction:self];
    }
}
*/

- (void)transferAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewTransferAction:)]) {
        [_delegate moreViewTransferAction:self];
    }
}

- (void)quickReplyAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewQuickReplyAction:)]) {
        [_delegate moreViewQuickReplyAction:self];
    }
}

- (void)customeAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewCustomAction:)]) {
        [_delegate moreViewCustomAction:self];
    }
}

- (void)iframeBaseAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewIframeBaseAction:)]) {
        [_delegate moreViewIframeBaseAction:self];
    }
}
- (void)iframeRobotAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewIframeRobotAction:)]) {
        [_delegate moreViewIframeRobotAction:self];
    }
}

-(NSMutableArray *)btnMarray{
    
    
    if (!_btnMarray) {
        _btnMarray = [[NSMutableArray alloc] init];
    }
    
    return _btnMarray;
}
@end
