//
//  ChatViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/15.
//  Copyright (c) 2015年 easemob. All rights reserved.
//
#import "ChatViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "DXMessageToolBar.h"
#import "QuickReplyViewController.h"
#import "ClientInforViewController.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "MessageReadManager.h"
#import "NSDate+Formatter.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "ChatSendHelper.h"
#import "SRRefreshView.h"
#import "LocationViewController.h"
#import "EMCDDeviceManager.h"
#import "HomeViewController.h"
#import "TransferViewController.h"
#import "AddTagViewController.h"
#import "EMChatHeaderTagView.h"
#import "EMUIWebViewController.h"
#import "EMFileViewController.h"
#import "EMPromptBoxView.h"
#import "DXRecordView.h"
#import "HDWebViewController.h"
#import "KFPredictView.h"
#import "HDMessage+Category.h"
#import "KFChatViewRecallCell.h"
#import "KFFileCache.h"
#import <AVKit/AVKit.h>
#import "KFWebViewController.h"
#import "HDAgoraCallViewController.h"
#import "HDAgoraCallManager.h"
#import "KFVideoDetailViewController.h"
#import "KFVideoDetailModel.h"
#import "KFICloudManager.h"
#import "HDSanBoxFileManager.h"
#import "KFChatSmartView.h"
#import "KFSmartModel.h"
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)

#define kNavBarHeight 44.f

@implementation UIButton (TagButton)

- (void)setTitleText:(NSString *)titleText
{
    self.titleLabel.text = titleText;
    [self setTitle:titleText forState:UIControlStateNormal];
}

@end

typedef NS_ENUM(NSUInteger, HChatMenuType) {
    HChatMenuTypeTransfer = 1356,
    HChatMenuTypeInvitation,
    HChatMenuTypeSessionTag,
    HChatMenuTypeEndSession
};

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QuickReplyViewControllerDelegate,SRRefreshDelegate,EMCDDeviceManagerDelegate,EMUIWebViewControllerDelegate,HDChatManagerDelegate,HDClientDelegate,UIActionSheetDelegate,AddTagViewDelegate,EMPromptBoxViewDelegate,TransferViewControllerDelegate,UIGestureRecognizerDelegate>
{
    dispatch_queue_t _messageQueue;
    NSMutableArray *_messages;
    NSTimeInterval startSessionTimestamp;
    int lastSeqId;
    ChatViewType chatType;
    int _page;
    BOOL _enquiryStatus;
    
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_recallMenuItem;
    NSIndexPath *_longPressIndexPath;
}

@property (nonatomic, strong) HDConversationManager *conversation;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DXMessageToolBar *chatToolBar;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) MessageReadManager *messageReadManager;//message阅读的管理者

@property (nonatomic, strong) NSDate *chatTagDate;

@property (nonatomic, strong) UIButton *tagBtn;//顶部打标签按钮
@property (nonatomic, strong) UIImageView *originTypeImage;//顶部渠道图片显示
@property (nonatomic, strong) UILabel *originTypeLable;//顶部渠道显示
@property (nonatomic, strong) UIButton *callBackBtn;//回呼按钮

@property (nonatomic, strong) UIView *moreView; //结束会话,会话标签,邀请评价,转接下拉菜单
@property (nonatomic, strong) NSMutableDictionary *sessionDic;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) EMChatHeaderTagView *headview;
@property (nonatomic, strong) UIButton *folderButton;

@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) NSMutableDictionary *msgDic;

@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic, strong) NSDictionary *lastMsgExt;

@property (nonatomic, strong) EMPromptBoxView *promptBoxView;

@property (nonatomic, strong) KFPredictView *visitorPredictView;

@property (nonatomic, strong) DXRecordView *recordView;

@property (nonatomic, strong) UIButton *satisfactionBtn;
@property (nonatomic, strong) UIButton *sessionAssistantBtn;
@property (nonatomic, strong) HDAgoraCallViewController *hdCallVC;

@property (nonatomic, strong) NSArray  *recordVideoDetailAll;
@property (nonatomic, strong) KFChatSmartView  *smartView;

@end

@implementation ChatViewController
{
    BOOL _hasTags;
}

- (DXRecordView *)recordView
{
    if (_recordView == nil) {
        _recordView = [[DXRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    
    return _recordView;
}
- (KFChatSmartView *)smartView{
    
    if (!_smartView) {
        _smartView = [[KFChatSmartView alloc] init];
//        _smartView.backgroundColor = [UIColor redColor];
    }
    
    return _smartView;
}
- (instancetype)initWithtype:(ChatViewType)type
{
    self = [super init];
    if (self) {
        chatType = type;
        _page = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.headview refreshHeaderView];
}

- (NSDictionary *)lastMsgExt {
    return _conversation.lastExtWeichat;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //clear本地的wav文件
    [self clearTempWav];
}
- (void)clearTempWav {
    NSString *libDir = NSHomeDirectory();
    libDir = [libDir stringByAppendingPathComponent:@"Library"];
    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:dbDirectoryPath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([[filename pathExtension] isEqualToString:@"wav"]) {
            [fileManager removeItemAtPath:[dbDirectoryPath stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

- (void)startNoti {
    [[HDClient sharedClient].chatManager removeDelegate:self];
    [[HDClient sharedClient].chatManager addDelegate:self];
    [[HDClient sharedClient] removeDelegate:self];
    [[HDClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    __weak typeof(self) weakSelf = self;
    [KFManager sharedInstance].curChatViewConvtroller = weakSelf;
    [KFManager sharedInstance].currentSessionId = weakSelf.conversationModel.sessionId;
    
    NSLog(@"==currentSessionId=== %@",weakSelf.conversationModel.sessionId);
    
    
    [self startNoti];
     
    // Do any additional setup after loading the view.
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _messageQueue = dispatch_queue_create("kefu.easemob.com", NULL);
    
    self.view.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.tableView.backgroundColor = RGBACOLOR(244, 244, 242, 1);
    [self setupBarButtonItem];
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    
    _conversation = [[HDConversationManager alloc] initWithSessionId:_conversationModel.sessionId chatGroupId:_conversationModel.chatGroupId];
    
    [self markAsRead];
    if (chatType == ChatViewTypeChat) {
        [self.navigationItem setTitleView:[[UIView alloc] initWithFrame:self.tagBtn.bounds]];
        [self.navigationItem.titleView addSubview:self.tagBtn];
        self.tagBtn.center = self.navigationItem.titleView.center;
        [self.view addSubview:self.chatToolBar];
        [self.chatToolBar addSubview:self.visitorPredictView];
        [self.view addSubview:self.moreView];
        // 获取满意度是否已经评价过
        [_conversation satisfactionStatusCompletion:^(HDSatisfationStatus status, HDError *error) {
            _satisfactionBtn.selected = (status != HDSatisfationStatusNone);
        }];
        [self.view addSubview:self.headview];
        [self.view addSubview:self.folderButton];
        [self.view addSubview:self.promptBoxView];
        
    } else if (chatType == ChatViewTypeNoChat) {
        if (_conversationModel.vistor && _conversationModel.vistor.nicename.length > 0) {
            self.title = _conversationModel.vistor.nicename;
        }
        _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-iPhoneXBottomHeight);
    } else if (chatType == ChatViewTypeCallBackChat) {
        UIView *titleView = [[UIView alloc] init];
        titleView.frame = self.tagBtn.frame;
        [titleView addSubview:self.tagBtn];
        [self.navigationItem setTitleView:titleView];
        
        _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 48 - iPhoneXBottomHeight);
        [self.view addSubview:self.callBackBtn];
        [self.view addSubview:self.headview];
        [self.view addSubview:self.folderButton];
        [self.view addSubview:self.moreView];
    }
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    tap.delegate = self;
    [self.tableView addGestureRecognizer:tap];
    
    [self loadMessage];
    
    [self loadTags];
    [self tableViewScrollToBottom];
    
    [self setupVoiceType];
    
    //每次进入聊天会话 都要获取一次 获取会话全部视频通话详情 接口
    
     
}
- (void)getCurrentSessionRecordVideoDetailAll{
    
    

    
    
}
- (NSArray *)recordVideoDetailAll {
    if (!_recordVideoDetailAll) {
        self.recordVideoDetailAll = [[NSArray alloc] init];
    }
    return _recordVideoDetailAll;
}
- (void)appDidBecomeActiveNotif:(NSNotification *)aNoti {
    HomeViewController *homeVC = (HomeViewController *)[HomeViewController homeViewController];
    homeVC.conversationVCUnreadCount -= self.conversationModel.unreadCount;
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_UPDATE_SERVICECOUNT
                                                      object:[NSString stringWithFormat:@"%d",homeVC.conversationVCUnreadCount]
                                                    userInfo:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)setupBarButtonItem
{
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 36)];
    [_backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    
    if (chatType == ChatViewTypeChat) {
        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [_backButton setTitle:[NSString stringWithFormat:@"(%@)",_notifyNumber==nil?@"0":_notifyNumber] forState:UIControlStateNormal];
    }
    
    UIView *btnViews = [[UIView alloc] init];
    btnViews.frame = CGRectMake(0, 0, 100.f, 440);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [button setImage:[UIImage imageNamed:@"history_icon_more"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:button]];
}

#pragma mark - getter

- (EMPromptBoxView*)promptBoxView
{
    if (_promptBoxView == nil) {
        _promptBoxView = [[EMPromptBoxView alloc] init];
        _promptBoxView.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame) - 100 - iPhoneXBottomHeight, KScreenWidth - 100, 100);
        _promptBoxView.backgroundColor = [UIColor clearColor];
        _promptBoxView.delegate = self;
    }
    return _promptBoxView;
}

- (KFPredictView *)visitorPredictView {
    if (_visitorPredictView == nil) {
        _visitorPredictView = [[KFPredictView alloc] initWithFrame:CGRectMake(0, -preconentHeight, self.view.width, preconentHeight)];
        _visitorPredictView.hidden = YES;
    }
    return _visitorPredictView;
}

- (UIImageView*)originTypeImage
{
    if (_originTypeImage == nil) {
        _originTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, self.tagBtn.height - 17.5, 15, 15)];
        _originTypeImage.layer.cornerRadius = _originTypeImage.width/2;
        _originTypeImage.layer.masksToBounds = YES;
        if ([self.conversationModel.originType isEqualToString:@"app"]) {
            _originTypeImage.image = [UIImage imageNamed:@"channel_APP_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"webim"]) {
            _originTypeImage.image = [UIImage imageNamed:@"channel_web_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"weixin"]) {
            _originTypeImage.image = [UIImage imageNamed:@"channel_wechat_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"weibo"]) {
            _originTypeImage.image = [UIImage imageNamed:@"channel_weibo_icon"];
        } else {
            _originTypeImage.image = [UIImage imageNamed:@"channel_APP_icon"];
        }
    }
    return _originTypeImage;
}

- (void)setupVoiceType {
    if ([self.conversationModel.originType isEqualToString:@"webim"]) {
        [self.chatToolBar disableVoice];
    }
}

- (UILabel*)originTypeLable
{
    if (_originTypeLable == nil) {
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        if ([self.conversationModel.originType isEqualToString:@"app"]) {
            attach.image = [UIImage imageNamed:@"channel_APP_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"webim"]) {
            attach.image = [UIImage imageNamed:@"channel_web_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"weixin"]) {
            attach.image = [UIImage imageNamed:@"channel_wechat_icon"];
        } else if ([self.conversationModel.originType isEqualToString:@"weibo"]) {
            attach.image = [UIImage imageNamed:@"channel_weibo_icon"];
        } else {
            attach.image = [UIImage imageNamed:@"channel_APP_icon"];
        }
        attach.bounds = CGRectMake(0, 0, 15, 15);
        NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
        [string appendAttributedString:attachString];
        NSString *techChannelStr = [NSString stringWithFormat:@"会话来自:%@",self.conversationModel.techChannelName];
        if (self.conversationModel.techChannelName) {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:techChannelStr]];
        }
        
        _originTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tagBtn.height - 17.5, self.tagBtn.width, 15)];
        _originTypeLable.textAlignment = NSTextAlignmentCenter;
        _originTypeLable.textColor = [UIColor whiteColor];
        _originTypeLable.attributedText = string;
        _originTypeLable.font = [UIFont systemFontOfSize:15.f];
        _originTypeLable.userInteractionEnabled = NO;
    }
    return _originTypeLable;
}

- (UIButton *)folderButton
{
    if (_folderButton == nil) {
        _folderButton = [[UIButton alloc] initWithFrame:CGRectMake((KScreenWidth-48)/2, 0, 48, 24)];
        [_folderButton setImage:[UIImage imageNamed:@"expand_arror_sesstion_tag_display"] forState:UIControlStateNormal];
        [_folderButton setImage:[UIImage imageNamed:@"expand_arror_sesstion_tag_display_2"] forState:UIControlStateSelected];
        [_folderButton addTarget:self action:@selector(folderButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _folderButton;
}

- (EMChatHeaderTagView*)headview
{
    if (_headview == nil) {
        _headview = [[EMChatHeaderTagView alloc] initWithSessionId:_conversationModel.sessionId edit:NO];
        _headview.hidden = YES;
        _headview.top = -KScreenHeight;
    }
    return _headview;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIButton *)callBackBtn
{
    if (_callBackBtn == nil) {
        _callBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _callBackBtn.frame = CGRectMake(0, KScreenHeight - 48 - 64 - iPhoneXBottomHeight, KScreenWidth, 48);
        [_callBackBtn setBackgroundColor:RGBACOLOR(27, 168, 237, 1)];
        [_callBackBtn setTitle:@"回呼" forState:UIControlStateNormal];
        [_callBackBtn addTarget:self action:@selector(callBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callBackBtn;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UIView *)moreView
{
    if (_moreView == nil) {
        _moreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _moreView.userInteractionEnabled = YES;
        _moreView.backgroundColor = RGBACOLOR(0, 0, 0, 0.14902);
        _moreView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction)];
        [_moreView addGestureRecognizer:tap];
        
        if (chatType == ChatViewTypeChat) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth - 160, 0, 150, 40*4)];
            contentView.backgroundColor = [UIColor whiteColor];
            contentView.userInteractionEnabled = YES;
            contentView.layer.cornerRadius = 2.f;
            [_moreView addSubview:contentView];
            
            
//            UIButton *sessionAssistantBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            sessionAssistantBtn.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.frame), 40);
//            [sessionAssistantBtn setTitle:@"会话助手" forState:UIControlStateNormal];
//            sessionAssistantBtn.titleLabel.font = [UIFont systemFontOfSize:17];
//            [sessionAssistantBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
//            [sessionAssistantBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
//
//            [sessionAssistantBtn setImage:[UIImage imageNamed:@"expand_icon_session_on"] forState:UIControlStateSelected ];
//
//            [sessionAssistantBtn setImage:[UIImage imageNamed:@"expand_icon_session_off"] forState:UIControlStateNormal];
//
//            //这个地方的逻辑是。如果 本地没有存状态说明是首次进入并且没有修改状态 那就走默认的移动助手开关设置 如果有状态 说明 这个会话根据自己是操作状态 进行展示
//            NSUserDefaults *def= [NSUserDefaults standardUserDefaults];
//
//            if ([def valueForKey:self.conversationModel.sessionId]) {
//                BOOL selected;
//                NSString * state =[def valueForKey:self.conversationModel.sessionId] ;
//                if ([state isEqualToString:@"YES" ]) {
//                    selected = YES;
//                }else{
//                    selected = NO;
//                }
//                sessionAssistantBtn.selected = selected;
//            }else{
//
//                sessionAssistantBtn.selected =[HDClient sharedClient].currentAgentUser.appAssistantEnable;
//
//            }
//            [sessionAssistantBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
//            [sessionAssistantBtn addTarget:self action:@selector(sessionAssistantAction:) forControlEvents:UIControlEventTouchUpInside];
//            [contentView addSubview:sessionAssistantBtn];
//            _sessionAssistantBtn = sessionAssistantBtn;
//            UIView *line0 = [[UIView alloc] init];
//            line0.frame = CGRectMake(0, CGRectGetMaxY(sessionAssistantBtn.frame) - 0.5, contentView.width, 1);
//            line0.backgroundColor = [UIColor lightGrayColor];
//            [contentView addSubview:line0];
//
            
            UIButton *transferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            transferBtn.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.frame), 40);
            [transferBtn setTitle:@"会话转接" forState:UIControlStateNormal];
            transferBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [transferBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
            [transferBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [transferBtn setImage:[UIImage imageNamed:@"expand_icon_transfer"] forState:UIControlStateNormal];
            [transferBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [transferBtn addTarget:self action:@selector(transferAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:transferBtn];
            
            UIView *line = [[UIView alloc] init];
            line.frame = CGRectMake(0, CGRectGetMaxY(transferBtn.frame) - 0.5, contentView.width, 1);
            line.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:line];
            
            UIButton *satisfactionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            satisfactionBtn.frame = CGRectMake(0, CGRectGetMaxY(transferBtn.frame), CGRectGetWidth(contentView.frame), 40);
            [satisfactionBtn setTitle:@"邀请评价" forState:UIControlStateNormal];
            satisfactionBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [satisfactionBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
            [satisfactionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [satisfactionBtn setImage:[UIImage imageNamed:@"expand_icon_vote"] forState:UIControlStateNormal];
            [satisfactionBtn setImage:[UIImage imageNamed:@"expand_icon_vote_over"] forState:UIControlStateSelected];
            [satisfactionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [satisfactionBtn addTarget:self action:@selector(satisfactionyAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:satisfactionBtn];
            _satisfactionBtn = satisfactionBtn;
            
            UIView *line2 = [[UIView alloc] init];
            line2.frame = CGRectMake(0, CGRectGetMaxY(satisfactionBtn.frame) - 0.5, contentView.width, 1);
            line2.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:line2];
            
            UIButton *conversationTagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            conversationTagBtn.frame = CGRectMake(0, CGRectGetMaxY(satisfactionBtn.frame), CGRectGetWidth(contentView.frame), 40);
            [conversationTagBtn setTitle:@"会话标签" forState:UIControlStateNormal];
            conversationTagBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [conversationTagBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
            [conversationTagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [conversationTagBtn setImage:[UIImage imageNamed:@"expand_icon_sessiontag"] forState:UIControlStateNormal];
            [conversationTagBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [conversationTagBtn addTarget:self action:@selector(conclusionClickAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:conversationTagBtn];
            
            UIView *line3 = [[UIView alloc] init];
            line3.frame = CGRectMake(0, CGRectGetMaxY(conversationTagBtn.frame) - 0.5, contentView.width, 1);
            line3.backgroundColor = [UIColor lightGrayColor];
            [contentView addSubview:line3];
            
            UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            endBtn.frame = CGRectMake(0, CGRectGetMaxY(conversationTagBtn.frame), CGRectGetWidth(contentView.frame), 40);
            [endBtn setTitle:@"结束会话" forState:UIControlStateNormal];
            endBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [endBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
            [endBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [endBtn setImage:[UIImage imageNamed:@"expand_icon_sessionend"] forState:UIControlStateNormal];
            [endBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [endBtn addTarget:self action:@selector(endChatAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:endBtn];
        } else if (chatType == ChatViewTypeCallBackChat) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(KScreenWidth - 160, 0, 150, 40)];
            contentView.backgroundColor = [UIColor whiteColor];
            contentView.userInteractionEnabled = YES;
            contentView.layer.cornerRadius = 2.f;
            [_moreView addSubview:contentView];
            
            UIButton *conversationTagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            conversationTagBtn.frame = CGRectMake(0, 0, CGRectGetWidth(contentView.frame), 40);
            [conversationTagBtn setTitle:@"会话标签" forState:UIControlStateNormal];
            conversationTagBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [conversationTagBtn setTitleColor:RGBACOLOR(77, 77, 77, 1) forState:UIControlStateNormal];
            [conversationTagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [conversationTagBtn setImage:[UIImage imageNamed:@"expand_icon_sessiontag"] forState:UIControlStateNormal];
            [conversationTagBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [conversationTagBtn addTarget:self action:@selector(conclusionClickAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:conversationTagBtn];
        }
    }
    return _moreView;
}

- (UIButton *)tagBtn
{
    if (_tagBtn == nil) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:19]};
        _tagBtn = [[UIButton alloc] init];
        _tagBtn.frame = CGRectMake(0, 0, 180, kNavBarHeight);
        _tagBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_tagBtn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
        [_tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        NSString *title = @"";
        if (chatType == ChatViewTypeCallBackChat) {
            title = _conversationModel.vistor.nicename;
        } else {
            title = _conversationModel.chatter.nicename;
        }
        [_tagBtn setTitleText:title];
        [_tagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        
        [_tagBtn addSubview:self.originTypeLable];
    }
    return _tagBtn;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height - iPhoneXBottomHeight) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBACOLOR(235, 235, 235, 1);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight] - iPhoneXBottomHeight, self.view.frame.size.width, [DXMessageToolBar defaultHeight]) type:KFChatMoreTypeChat];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = NO;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}
#pragma mark - HDChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages {
    for (HDMessage *msg in aMessages) {
        if (![_conversationModel.sessionId isEqualToString:msg.sessionId]) {
            return;
        }
        [self markAsRead];
        [self addMessage:msg];
        [self downloadVoice:msg];
        
        // 处理视频邀请通知 两种方式 一种这个地方处理数据 一种 sdk 内部处理数据
        if ([msg.messageType isEqualToString:@"AgoraRtcMediaForInitiative"]) {
            [self  onAgoraCallReceivedNickName:@"nickName"];
        }
    
    }
}

- (void)downloadVoice:(HDMessage *)message {
    if (message.type == HDMessageBodyTypeVoice) {
        HDVoiceMessageBody *body = (HDVoiceMessageBody *)message.nBody;
        [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath completion:^(id responseObject, NSString *path, NSError *error) {
            ;
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            HDMessage *model = (HDMessage *)obj;
            if ([model isRecall]) {
                KFChatViewRecallCell *recallCell = (KFChatViewRecallCell *)[tableView dequeueReusableCellWithIdentifier:@"KFChatViewRecall"];
                if (!recallCell) {
                    recallCell = [[KFChatViewRecallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KFChatViewRecall"];
                }
                return recallCell;
            }else {
                NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
                EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.messageModel = model;
                
                return cell;
            }

        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"errorCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"errorCell"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource count] <= indexPath.row) {
        return 0.f;
    }
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 25;
    }
    else{
        HDMessage *msg = (HDMessage *)obj;
        if ([msg isRecall]) {
            return 40;
        }else {
            return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:msg];
        }
    }
}

#pragma mark - DXMessageToolBarDelegate
- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.height = self.view.frame.size.height - toHeight - iPhoneXBottomHeight;
        self.promptBoxView.top = self.view.frame.size.height - toHeight - self.promptBoxView.height - iPhoneXBottomHeight;
    }];
    [self scrollViewToBottom:NO];
}

- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self.promptBoxView searchText:nil];
        [self sendTextMessage:text];
    }
}

- (void)inputTextViewDidChange:(XHMessageTextView *)messageInputTextView
{
    if (messageInputTextView.text.length >= 2) {
        [_promptBoxView searchText:messageInputTextView.text];
    } else {
        [_promptBoxView searchText:nil];
    }
    if (messageInputTextView.text) {
        [[HDClient sharedClient].chatManager postContent:messageInputTextView.text sessionId:self.conversationModel.sessionId completion:^(id responseObject, HDError *error) {
            NSLog(@"postContent %@",responseObject);
        }];
    }
}

/**
 开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView {
    UIView *cover = [[UIView alloc] initWithFrame:fKeyWindow.bounds];
    cover.tag = 10010;
    [fKeyWindow addSubview:cover];
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchDown];
    }
    if ([self isSupportRecord]) {
        DXRecordView *tmpView = (DXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
                                                                 completion:^(NSError *error)
         {
             if (error) {
                 NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
             }
         }];
    }
}
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView {
    [[fKeyWindow viewWithTag:10010] removeFromSuperview];
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    
    [self.recordView removeFromSuperview];
    
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    [[fKeyWindow viewWithTag:10010] removeFromSuperview];
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error && recordPath!= nil && aDuration > 0) {
            //amr path
            [weakSelf sendAudioMessage:recordPath aDuration:aDuration];
        }else {
            if (![self isSupportRecord]) {
                [weakSelf showHudInView:self.view hint:@"未授权"];
            } else {
                [weakSelf showHudInView:self.view hint:@"时间过短"];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                weakSelf.chatToolBar.recordButton.enabled = YES;
            });
            
        }
    }];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
        [self keyBoardHidden:nil];
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
    } else if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
        [self keyBoardHidden:nil];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照上传", @"本地相册", nil];
    [actionSheet showInView:self.view];
}

/// 视频通话详情
/// @param moreView  moreView
- (void)moreViewVideoDetailAction:(DXChatBarMoreView *)moreView{
    
    [self clickVideoDatail];
    
}

- (void) clickVideoDatail{
    
    
//    KFVideoDetailViewController * vc = [[KFVideoDetailViewController alloc] init];
////    vc.recordVideos = detailArray;
//    vc.callId = @"344";
//    [self.navigationController pushViewController:vc animated:YES];
//
//    return;
    
    [[HDAgoraCallManager shareInstance] getAllVideoDetailsSession:_conversationModel.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        if (error == nil) {
            NSArray * detailArray = [NSArray yy_modelArrayWithClass:[KFVideoDetailModel class] json:responseObject];
            
            for (KFVideoDetailModel * model in detailArray) {
                NSLog(@"kf-callId= %@ \n recordStart= %@ \n playbackUrl = %@",model.callId,model.recordStart,model.playbackUrl);
            }
            self.recordVideoDetailAll =  [self sortVideoDetails:detailArray];
            KFVideoDetailViewController * vc = [[KFVideoDetailViewController alloc] init];
            vc.recordVideos = detailArray;
            vc.callId = @"344";
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }];
}

- (NSArray *)sortVideoDetails:(NSArray *)modelArray{
    
    //降序 要是升序ascending传yes
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"recordStart" ascending:NO];
    NSArray* sortPackageResListArr = [modelArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSLog(@"%@",sortPackageResListArr);

    return  sortPackageResListArr;
}

/// 获取文件
/// @param moreView  moreView
- (void)moreViewFileAction:(DXChatBarMoreView *)moreView
{
    [self presentDocumentPicker];
}

/// 视频通话
/// @param moreView  moreView
- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView
{
    //创建 声网房间入口
//    [self sendVideoTextMessage:@"邀请访客进行视频"];

    [self moreViewVideoDetailAction:moreView];
    return;

}
- (void)sendVideoTextMessage:(NSString *)text{
   
    HDMessage *message =  [[HDAgoraCallManager shareInstance]  creteVideoInviteMessageWithSessionId:_conversationModel.sessionId to:_conversationModel.chatter.agentId WithText:text];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
       // 如果通知回来 在这个地方处理。现在后台没有做移动的 所以还不知道如何回来
//        if ([aMessage.messageType isEqualToString:@"AgoraRtcMediaForInitiative"]) {
//            [self onAgoraCallReceivedNickName:@"nickName"];
//        }
    
        [[HLCallManager  sharedInstance] getAgoraTicketWithCallId:@"344" withSessionId:_conversationModel.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
            if (error == nil) {
                
                [self onAgoraCallReceivedNickName:@"nickName"];
            }
        }] ;
        
        [self updateMessageWithMessage:aMessage];
    }];
}
- (void)onAgoraCallReceivedNickName:(NSString *)nickName{
    [HDAgoraCallManager shareInstance].sessionId = _conversationModel.sessionId;
    [HDAgoraCallManager shareInstance].chatter = _conversationModel.chatter;
    if ([HDAgoraCallManager shareInstance].hdVC) {
        [[HDAgoraCallManager shareInstance].hdVC showView];
    }else{
        [self.hdCallVC showView];
    }
    [HDAgoraCallManager shareInstance].hdVC.hangUpCallback = ^(HDAgoraCallViewController * _Nonnull callVC, NSString * _Nonnull timeStr, id  _Nonnull result) {
        NSLog(@"------%@",timeStr);
        HDMessage *message =    [[HDAgoraCallManager shareInstance] hangUpVideoInviteMessageWithSessionId:[HDAgoraCallManager shareInstance].sessionId to:[HDAgoraCallManager shareInstance].chatter.agentId WithText:@"视频通话已结束"];
        [self addVideoMessage:message];
        [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
            [self updateMessageWithMessage:aMessage];
        }];
    };
    
   
}
- (void)addVideoMessage:(HDMessage *)message{
    
    [self prehandle:message];
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *msgs = [weakSelf formatMessage:message];
        hd_dispatch_main_async_safe(^{
            [_messages addObject:message];
            [weakSelf.dataSource addObjectsFromArray:msgs];
            NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
            NSInteger count = msgs.count;
            for (int i=0; i<count; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:weakSelf.dataSource.count-1-i inSection:0];
                [paths addObject:ip];
            }
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:paths.copy withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
    });
    
}
- (HDAgoraCallViewController *)hdCallVC{
    
    if (!_hdCallVC) {
        _hdCallVC =  [HDAgoraCallViewController hasReceivedCallWithAgentName:[HDClient sharedClient].currentAgentUser.nicename
                                                                                     avatarStr:@"HelpDeskUIResource.bundle/user"
                                                                                      nickName:[HDClient sharedClient].currentAgentUser.nicename];
        [HDAgoraCallManager shareInstance].hdVC = _hdCallVC;
    }
    
    return _hdCallVC;
    
}
- (void)moreViewQuickReplyAction:(DXChatBarMoreView *)moreView
{
    QuickReplyViewController *quickView = [[QuickReplyViewController alloc] init];
    quickView.delegate = self;
    [self.navigationController pushViewController:quickView animated:YES];
    [self keyBoardHidden:nil];
}

- (void)moreViewTransferAction:(DXChatBarMoreView *)moreView
{
    TransferViewController *transfer = [[TransferViewController alloc] init];
    transfer.conversation = _conversation;
    [self.navigationController pushViewController:transfer animated:YES];
    [self keyBoardHidden:nil];
}

- (void)conversationHasTransfered {
    if (_delegate && [_delegate respondsToSelector:@selector(refreshConversationList)]) {
        [_delegate refreshConversationList];
    }
}


- (void)moreViewCustomAction:(DXChatBarMoreView *)moreView
{
    EMUIWebViewController *webView = [[EMUIWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"http:%@",[HDClient sharedClient].currentAgentUser.customUrl]];
    webView.delegate = self;
    [self.navigationController pushViewController:webView animated:YES];
    [self keyBoardHidden:nil];
}

#pragma mark - EMUIWebViewControllerDelegate

-(void)clickCustomWebView:(NSDictionary *)data
{
    
    HDMessage *message = [ChatSendHelper textMessageFormatWithText:@"自定义消息" to:_conversationModel.chatter.agentId sessionId:_conversationModel.sessionId];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:self.lastMsgExt];
    [parameters setObject:data forKey:@"msgtype"];
    message.nBody.msgExt = parameters;
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
    }];
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - EMPromptBoxViewDelegate

- (void)didSelectPromptBoxViewWithPhrase:(NSString *)phrase
{
    [self.promptBoxView searchText:@""];
    self.chatToolBar.inputTextView.text = phrase;
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UIGestureRecognizer *)gestureRecognizer
{
    [self.chatToolBar endEditing:YES];
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view.tag == 1990) {
        return NO;
    }
    return YES;
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    HDMessage *model = [userInfo objectForKey:KMESSAGEKEY];
    
    
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        NSString *url=[NSString stringWithUTF8String:[[userInfo objectForKey:@"url"] UTF8String]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        //        WebViewController *webview = [[WebViewController alloc] initWithUrl:_dataString];
        //        [self.navigationController pushViewController:webview animated:YES];
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]){
        if (!model.isSender) {
            [self chatHeadImageBubblePressed:model];
        }
    }else if ([eventName isEqualToString:kSmartButtonTapEventName]){
        [self chatTextSmartCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventCopyTextTapEventName]){
        [self chatTextSmartCopyCellBubblePressed:[userInfo objectForKey:@"smartModel"]];
    } else if ([eventName isEqualToString:kRouterEventSendMessageTapEventName]){
        [self chatTextSmartSendMessageCellBubblePressed:[userInfo objectForKey:@"smartModel"]];
    }  else if ([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        HDMessage *messageModel = resendCell.messageModel;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [self chatResendButtonPressed:messageModel];
    } else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventImageTextBubbleTapEventName]) {
        [self chatImageTextCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventFileBubbleTapEventName]) {
        [self chatFileCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventFormBubbleTapEventName]) {
        HDFormItem *item = [userInfo objectForKey:KMESSAGEKEY];
        [self chatFormCcellBubblePressed:item];
    }else if ([eventName isEqualToString:kRouterEventVideoBubbleTapEventName]) {
        HDVideoMessageBody *body = (HDVideoMessageBody *)model.nBody;
        [self showHintNotHide:@"正在下载文件"];
        WEAK_SELF
        [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath
                                                  completion:^(id responseObject, NSString *path, NSError *error)
        {
            [weakSelf hideHud];
            if (!error) {
                NSString *toPath = @"";
                if ([path pathExtension] && [path pathExtension].length > 0) {
                    toPath = path;
                }else {
                    toPath = [path stringByAppendingPathExtension:@"mp4"];
                }
                
                [NSFileManager.defaultManager moveItemAtPath:path toPath:toPath error:nil];
                NSURL *videoURL = [NSURL fileURLWithPath:toPath];;
                AVPlayerViewController *pVC = [AVPlayerViewController new];
                pVC.player = [AVPlayer playerWithURL:videoURL];
                [pVC.player play];
                [self presentViewController:pVC animated:YES completion:nil];
            }else {
                [self showHint:@"下载失败"];
            }
        }];
    }
}

- (void)chatFormCcellBubblePressed:(HDFormItem *)form {
    HDWebViwController *web = [[HDWebViwController alloc] init];
    web.url = form.url;
    [self.navigationController pushViewController:web animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)chatFileCellBubblePressed:(HDMessage *)model
{
    EMFileViewController *viewController = [[EMFileViewController alloc] init];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 自动发送 接收到通知上屏 逻辑
-  (void)kf_smartAutoSendMessageReloadDataUI{
    
    [_conversation loadMessageCompletion:^(NSArray<HDMessage *> *messages, HDError *error) {
        [self hideHud];
        if (error == nil) {
            for (HDMessage *msg in messages) {
                
                NSString *msgType = [msg.nBody.msgExt objectForKey:@"messageType"];
                 
                if ([msgType isEqualToString:@"cooperationAnswer"]) {
                    NSLog(@"===%@",msgType);
                    [self markAsRead];
                    [self addMessage:msg];
                }
            }
        } else {

        }
    }];
    
    
    
}

// 文本的小书被点击
- (void)chatTextSmartCellBubblePressed:(HDMessage *)model{
    
    [self.view addSubview:self.smartView];
    
    [self.smartView setModel:model];
    
    [self.smartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.trailing.offset(0);
        make.bottom.mas_equalTo(self.chatToolBar.mas_top).offset(-5);
        make.height.offset(300);
    }];
}

- (void)chatTextSmartCopyCellBubblePressed:(KFSmartModel *)model{
    
    if (model) {
        self.chatToolBar.inputTextView.text = model.answer;
        [[HDClient sharedClient].setManager kf_getCooperationWithstatisticsWithOperationEnum:@"quote" withAnswerId:model.answerId withSessionId:self.conversationModel.sessionId withMsgId:@"" completion:^(id responseObject, HDError *error) {
            
            NSLog(@"====%@",responseObject);
            
        }];
    }
   
    
}
- (void)chatTextSmartSendMessageCellBubblePressed:(KFSmartModel *)model{
    
    switch (model.msgtype) {
        case HDSmartExtMsgTypeText:
            if (model.answer && model.answer.length > 0) {
                [self.promptBoxView searchText:nil];
                [self sendTextMessage:model.answer];
            }
            break;
        case HDSmartExtMsgTypeImamge:
            [self sendImageMessage:model.sendImage];
            break;
        case HDSmartExtMsgTypearticle:
//            [self sendImageMessage:[UIImage imageNamed:@""]];
            break;
        case HDSmartExtMsgTypeMenu:
            [self sendTextMessage:model.answer];
            break;
        default:
            break;
    }
   
    [[HDClient sharedClient].setManager kf_getCooperationWithstatisticsWithOperationEnum:@"send" withAnswerId:model.answerId withSessionId:self.conversationModel.sessionId withMsgId:@"" completion:^(id responseObject, HDError *error) {
        
        NSLog(@"====%@",responseObject);
        
    }];
    
    
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(HDMessage *)model
{
    [self keyBoardHidden:nil];
    if (model.type != HDMessageBodyTypeImage) {
        return;
    }
    HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
    id image =  [[EMSDImageCache sharedImageCache] imageFromDiskCacheForKey:body.remotePath];
    if (!image) {
        image = [NSURL URLWithString:body.remotePath];
    }
    if (image) {
        [self.messageReadManager showBrowserWithImages:@[image]];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(HDMessage *)model
{
    if (model.type != HDMessageBodyTypeVoice) {
        return;
    }
    HDVoiceMessageBody *body = (HDVoiceMessageBody *)model.nBody;
    NSString *filePath = [[KFFileCache sharedInstance] filePathFromDiskCacheForKey:body.remotePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self showHint:@"正在下载声音,请稍后点击"];
        [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath
                                                  completion:^(id responseObject, NSString *path, NSError *error) {
            
        }];
        return;
    }
    
    // 播放音频
    __weak ChatViewController *weakSelf = self;
    BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(HDMessage *prevAudioModel, HDMessage *currentAudioModel) {
        if (prevAudioModel || currentAudioModel) {
            [weakSelf.tableView reloadData];
        }
    }];
    
    if (isPrepare) {
        _isPlayingAudio = YES;
        WEAK_SELF
        [[EMCDDeviceManager sharedInstance] enableProximitySensor];
        [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:filePath completion:^(NSError *error) {
            [weakSelf.messageReadManager stopMessageAudioModel];
            hd_dispatch_main_async_safe(^{
                [weakSelf.tableView reloadData];
                weakSelf.isPlayingAudio = NO;
                [[EMCDDeviceManager sharedInstance] disableProximitySensor];
            });
        }];;
    }
    else{
        _isPlayingAudio = NO;
    }
}

// 图文混排的bubble被点击
- (void)chatImageTextCellBubblePressed:(HDMessage *)model
{
    //ios 2020-4-30 提交appstore 必须使用 WKWebView 使用UIWebView 审核不通过 开始替换WebViewController 中的UIWebView
    KFWebViewController *webview = [[KFWebViewController alloc] initWithUrl:model.ext.msgtype.itemUrl];
    [self.navigationController pushViewController:webview animated:YES];
}

// 位置的bubble被点击
- (void)chatLocationCellBubblePressed:(HDMessage *)model
{
    HDLocationMessageBody *body = (HDLocationMessageBody *)model.nBody;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatHeadImageBubblePressed:(HDMessage *)model
{
    [self tagAction:nil];
}

- (void)chatResendButtonPressed:(HDMessage *)model
{
    model.status = HDMessageDeliveryState_Delivering;
    [self sendMessage:model completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
    }];
}

#pragma mark - action

- (void)folderButtonAction
{
    self.folderButton.selected = !self.folderButton.selected;
    if (self.folderButton.selected) {
        [self.headview refreshHeaderView];
        self.headview.hidden = NO;
        self.headview.top = -self.headview.height;
        [UIView animateWithDuration:0.2 animations:^{
            self.headview.top = 0;
            self.folderButton.top = self.headview.height;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.headview.top = -self.headview.height;
            self.folderButton.top = 0;
        } completion:^(BOOL finished) {
            self.headview.hidden = YES;
        }];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [[KFManager sharedInstance].conversation refreshData];
    _conversationModel.unreadCount = 0;
    [KFManager sharedInstance].curChatViewConvtroller = nil;
    [KFManager sharedInstance].currentSessionId = @"";
}

- (void)backAction {
    if (chatType == ChatViewTypeChat) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tagAction:(id)sender
{
    if (self.folderButton.selected) {
        [self folderButtonAction];
    }
    _moreView.hidden = YES;
    ClientInforViewController *clientView = [[ClientInforViewController alloc] init];
    clientView.userId = _conversationModel.chatter.agentId;
    clientView.niceName = _conversationModel.chatter.nicename;
    
    clientView.serviceSessionId = _conversation.sessionId;
    [self keyBoardHidden:nil];
    [self.navigationController pushViewController:clientView animated:YES];
}

- (void)moreAction
{
    [self.view bringSubviewToFront:_moreView];
    if (_moreView.hidden) {
        _moreView.hidden = NO;
    } else {
        _moreView.hidden = YES;
    }
}
- (void)sessionAssistantAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    // 会话开关   设置 先判断 设置页的移动助手有没有开启 如果开启了 才能开启 这个会话助手
    [self keyBoardHidden:nil];
    self.moreView.hidden = YES;
    
    NSUserDefaults *def= [NSUserDefaults standardUserDefaults];
    
    NSString * state;
    if (sender.selected) {
        
        state = @"YES";
    }else{
        
        state = @"NO";
    }
    [def setObject:state forKey:self.conversationModel.sessionId];
    [def synchronize];
    
    //调用接口的时候 没开通智能辅助提示
//    [self showHint:@"您请联系此管理员开通权限"];
}
- (void)transferAction
{
    //转接
    if (self.folderButton.selected) {
        [self folderButtonAction];
    }
    self.moreView.hidden = YES;
    TransferViewController *transfer = [[TransferViewController alloc] init];
    transfer.conversation = _conversation;
    transfer.delegate = self;
    [self.navigationController pushViewController:transfer animated:YES];
    [self keyBoardHidden:nil];
}

- (void)satisfactionyAction
{
    //邀请评价
    self.moreView.hidden = YES;
    [_conversation satisfactionStatusCompletion:^(HDSatisfationStatus status, HDError *error) {
        if (error == nil) {
            if (status == HDSatisfationStatusNone) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定发送满意度邀请吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
                alert.tag = 1001;
                [alert show];
                return;
            }
            if (status == HDSatisfationStatusOver) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"会话已评价" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                return;
            }
            if (status == HDSatisfationStatusInvited) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您已发送,不能重复发送" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                return;
            }
        }
    }];
    [self keyBoardHidden:nil];
}

- (void)conclusionClickAction
{
    //会话标签
    if (self.folderButton.selected) {
        [self folderButtonAction];
    }
    self.moreView.hidden = YES;
    AddTagViewController *addTag = [[AddTagViewController alloc] init];
    addTag.sessionId = _conversationModel.sessionId;
    [self.navigationController pushViewController:addTag animated:YES];
    [self keyBoardHidden:nil];
}

- (void)endChatAction
{
    if (self.folderButton.selected) {
        [self folderButtonAction];
    }
    self.moreView.hidden = YES;
    
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    if (user.isStopSessionNeedSummary && !_hasTags) {
        //会话标签
        AddTagViewController *addTag = [[AddTagViewController alloc] init];
        addTag.saveAndEnd = YES;
        addTag.sessionId = _conversationModel.sessionId;
        addTag.delegate = self;
        [self.navigationController pushViewController:addTag animated:YES];
        [self keyBoardHidden:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确认结束会话吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 1000;
        [alert show];
    }
}


#pragma mark 加载会话标签
- (void)loadTags {
    [_conversation asyncGetSessionSummaryResultsCompletion:^(id responseObject, HDError *error) {
        if (!error) {
            NSArray *json = responseObject;
            if (json.count>0) {
                _hasTags = YES;
            } else {
                _hasTags = NO;
            }
        }
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[HDMessage class]]) {
            HDMessage *msg = (HDMessage *)object;
            if ([msg isRecall]) {
                return;
            }
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1000) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"array", nil];
        if ([self.headview.dataSource count] > 0) {
            [self endConversation];
        } else {
            [_conversation asyncSaveSessionSummaryResultsParameters:parameters completion:^(id responseObject, HDError *error) {
                if (!error) {
                    [self endConversation];
                }
            }];
        }
    } else if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1001){
        [self showHintNotHide:@"发送中..."];
        WEAK_SELF
        [_conversation sendSatisfactionEvaluationCompletion:^(BOOL send, HDError *error) {
            [self hideHud];
            if (error == nil) {
                [weakSelf showHint:@"发送成功"];
                _satisfactionBtn.selected = YES;
            } else {
                [weakSelf showHint:@"发送失败"];
                //                DDLogError(@"send chat satisfaction --- %@ userId --- %@ error:%@",[HDClient sharedClient].currentAgentUser.nicename,_conversationModel.chatter.userId,error.description);
            }
        }];
    }
}

- (void)endConversation {
    [_conversation endConversationWithVisitorId:_conversationModel.chatter.agentId parameters:nil completion:^(id responseObject, HDError *error) {
        if (!error) {
            [self showHint:@"关闭成功"];
            
            if (_delegate && [_delegate respondsToSelector:@selector(refreshConversationList)]) {
                [_delegate refreshConversationList];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:@"关闭失败"];
        }
    }];
}

- (void)visitorInputStateChange:(NSString *)content {
    if (content != nil) {
        content = [@"[输入中...]  " stringByAppendingString:content];
        self.visitorPredictView.hidden = NO;
        self.visitorPredictView.content = content;
    } else {
        self.visitorPredictView.hidden = YES;
    }
}


- (void)callBackAction
{
    [self showHintNotHide:@"回呼中..."];
    WEAK_SELF
    [[HDClient sharedClient].chatManager asyncFetchCreateSessionWithVistorId:_conversationModel.vistor.agentId completion:^(HDHistoryConversation *history, HDError *error) {
        [weakSelf hideHud];
        if (error ==  nil) {
            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeChat];
            history.chatter = history.vistor;
            chatView.conversationModel = history;
            [[KFManager sharedInstance] setCurChatViewConvtroller:chatView];
            [[KFManager sharedInstance] setCurrentSessionId:history.sessionId];
            [[KFManager sharedInstance].conversation refreshData];
            [weakSelf.navigationController pushViewController:chatView animated:YES];
        } else {
            [weakSelf showHint:error.errorDescription];
        }
    }];
}

#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
#if !TARGET_IPHONE_SIMULATOR
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
#endif
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [self sendImageMessage:orgImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QuickReplyViewControllerDelegate
- (void)sendQuickReplyMessage:(NSString *)message
{
    if (message && message.length > 0) {
        //[self sendTextMessage:message];
        [self.navigationController popToViewController:self animated:YES];
        //        [self.chatToolBar quickReplyViewSeletedTitle:message];
        self.chatToolBar.inputTextView.text = [self.chatToolBar.inputTextView.text stringByAppendingString:message];
        [self.chatToolBar.inputTextView becomeFirstResponder];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadHistory];
    
    [_slimeView endRefresh];
}

#pragma mark - AddTagViewDelegate
- (void)saveAndEndChat
{
    [self endConversation];
}

#pragma mark - private


- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (void)tableViewScrollToBottom
{
    if (self.dataSource.count==0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height)
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)addMessage:(HDMessage *)message
{
    [self prehandle:message];
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *msgs = [weakSelf formatMessage:message];
        hd_dispatch_main_async_safe(^{
            [_messages addObject:message];
            [weakSelf.dataSource addObjectsFromArray:msgs];
            NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
            NSInteger count = msgs.count;
            for (int i=0; i<count; i++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:weakSelf.dataSource.count-1-i inSection:0];
                [paths addObject:ip];
            }
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:paths.copy withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [UIView setAnimationsEnabled:YES];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
    });
}

-(void)addMessagesToTop:(NSArray *)msgs
{
    if (msgs.count == 0) {
        return;
    }
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = msgs;
        
        hd_dispatch_main_async_safe(^{
            [_messages addObjectsFromArray:messages];
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                   NSMakeRange(0,[messages count])];
            [weakSelf.dataSource insertObjects:messages atIndexes:indexes];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

-(NSMutableArray *)formatMessage:(HDMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)message.localTime/1000];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate minuteDescription]];
        self.chatTagDate = createDate;
    }
    
    if (message) {
        [ret addObject:message];
    }
    return ret;
}

- (void)sendMessage:(HDMessage *)message completion:(void(^)(HDMessage *aMessage,HDError *error))completion {
    [_conversation sendMessage:message progress:nil completion:^(HDMessage *aMessage, HDError *aError) {
        aMessage.messageId = message.messageId;
        if (completion) {
            completion(aMessage,aError);
        }
    }];
}

#pragma mark sendMessage

- (void)sendTextMessage:(NSString *)text
{
    HDMessage *message = [ChatSendHelper textMessageFormatWithText:text to:_conversationModel.chatter.agentId sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
    }];
}


- (void)sendImageMessage:(UIImage*)orgImage
{
    HDMessage *message = [ChatSendHelper imageMessageFormatWithImage:orgImage
                                                                  to:_conversationModel.chatter.agentId
                                                           sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        if (error == nil) {
            HDImageMessageBody *body = (HDImageMessageBody *)aMessage.nBody;
            [[EMSDImageCache sharedImageCache] storeImage:orgImage forKey:body.remotePath];
        }
        [self updateMessageWithMessage:aMessage];
    }];
}


//recordPath为本地的amr path
-(void)sendAudioMessage:(NSString *)recordPath aDuration:(NSInteger )duration
{
    HDMessage *message = [ChatSendHelper voiceMessageFormatWithPath:recordPath to:_conversationModel.chatter.agentId sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
        if (error == nil) {
            HDVoiceMessageBody *body = (HDVoiceMessageBody *)aMessage.nBody;
            NSString *uuid = [[KFFileCache sharedInstance] uuidWithUrlStr:body.remotePath];
            [[KFFileCache sharedInstance] moveItemAtPath:recordPath toCachePath:uuid];
            [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath completion:^(id responseObject, NSString *path, NSError *error) {
                
            }];
        }
    }];
}
//文件路径
-(void)sendFileMessagePath:(NSString *)localPath withDisplayName:(NSString *)withDisplayName
{
    HDMessage *message = [ChatSendHelper fileMessageFormatWithPath:localPath to:_conversationModel.chatter.agentId sessionId:_conversationModel.sessionId withDisplayName:withDisplayName];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
        if (error == nil) {
          
        }
    }];
}
- (void)updateMessageWithMessage:(HDMessage *)aMessage {
    dispatch_async(_messageQueue, ^{
        //更新
        self.conversationModel.lastMessage = aMessage;
        __block NSUInteger index = NSNotFound;
        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HDMessage class]]) {
                HDMessage *model = (HDMessage *)obj;
                if ([model.messageId isEqualToString:aMessage.messageId]) {
                    index = idx;
                    *stop = YES;
                }
                if (index != NSNotFound)
                {
                    [self prehandle:aMessage];
                    [self.dataSource replaceObjectAtIndex:index withObject:aMessage];
                    hd_dispatch_main_async_safe(^{
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                    });
                }
            }
            
        }];
    });
}


- (void)loadHistory
{
    [self showHintNotHide:@"加载历史会话"];
    if (chatType == ChatViewTypeChat) {
        [_conversation loadHistoryCompletion:^(NSArray<HDMessage *> *messages, HDError *error) {
            [self hideHud];
            for (HDMessage *msg in messages) {
                [self prehandle:msg];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self downloadVoice:msg];
                });
                
            }
            [self addMessagesToTop:messages];
            
        }];
    }
    
    if (chatType == ChatViewTypeCallBackChat) {
        WEAK_SELF
        [[HDClient sharedClient].chatManager asyncFetchHistoryMessagesWithSessionServicesId:_conversationModel.sessionId page:_page completion:^(id responseObject, HDError *error) {
            [self hideHud];
            if (error == nil) {
                _page ++ ;
                for (HDMessage *message in responseObject) {
                    [self prehandle:message];
                    if (message.nBody) {
                        if (message.type == HDMessageBodyTypeText) {
                            ((HDTextMessageBody *)message.nBody).text =  [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:((HDTextMessageBody *)message.nBody).text];
                        }
                        
                    }
                    if (![_msgDic objectForKey:message.messageId]) {
                        [_msgDic setObject:@"" forKey:message.messageId];
                        //                    [weakSelf downloadMessageAttachments:message];
                        [weakSelf addMessagesToTop:@[message]];
                        [self downloadVoice:message];
                    }
                }
            }
        }];
    }
    
}

- (void)loadMessage{
    
    __weak typeof(self) weakSelf = self;
    if (chatType == ChatViewTypeChat) {
        [self showHintNotHide:@""];
        
        [_conversation loadMessageCompletion:^(NSArray<HDMessage *> *messages, HDError *error) {
            [self hideHud];
            if (error == nil) {
                for (HDMessage *msg in messages) {
                    //计算text高度
                    [weakSelf addMessage:msg];
                    [weakSelf downloadVoice:msg]; // 这步是不是应该获取的时候，sdk自动做？
                }
            } else {
                [weakSelf showHint:error.errorDescription];
            }
        }];
    } else {
        [weakSelf loadHistory];
    }
}

- (void)prehandle:(HDMessage *)message {
    if (message.type == HDMessageBodyTypeText) {
        message.att = [EMChatTextBubbleView getAttributedString:message];
        CGSize size = [EMChatTextBubbleView textSize:message];
        message.textSize = size;
    }
      
}


+ (BOOL)isExistFile:(HDMessage *)model
{
    NSString *libDir = NSHomeDirectory();
    libDir = [libDir stringByAppendingPathComponent:@"Library"];
    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL isCreate = NO;
    if (![fm fileExistsAtPath:dbDirectoryPath isDirectory:&isDirectory]) {
        isCreate = [fm createDirectoryAtPath:dbDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        if (!isCreate) {
            dbDirectoryPath = nil;
        }
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",dbDirectoryPath,model.messageId];
    if ([fm fileExistsAtPath:path]) {
        model.localPath = path;
        return YES;
    }
    HDFileMessageBody *file = (HDFileMessageBody *)model.nBody;
    path = [NSString stringWithFormat:@"%@/%@",dbDirectoryPath,file.displayName];
    if ([fm fileExistsAtPath:path]) {
        model.localPath = path;
        return YES;
    }
    return NO;
}

#pragma mark - notification
- (void)conversationRefreshAutoEnd:(NSNotification*)notification
{
    NSDictionary *dic = notification.object;
    if (dic) {
        if ([dic objectForKey:@"serviceSessionId"]) {
            if ([[dic objectForKey:@"serviceSessionId"] isEqualToString:self.conversationModel.sessionId]) {
                [self backAction];
            }
        }
    }
}

- (void)setUnreadBadgeValue:(NSString *)unreadBadgeValue {
    if (unreadBadgeValue==nil) {
        unreadBadgeValue = @"0";
    }
    [_backButton setTitle:[NSString stringWithFormat:@"(%@)",unreadBadgeValue] forState:UIControlStateNormal];
}

- (void)notifyNumberChange:(NSNotification*)notification
{
    //    NSString *number = [HomeViewController currentBadgeValue];
    [_backButton setTitle:[NSString stringWithFormat:@"(%@)",notification.object==nil?@(0):notification.object] forState:UIControlStateNormal];
}


#pragma mark - private

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(HDMessage *)message
{    
    NSDate *date = [NSDate dateWithTimeInterval:-120 sinceDate:[NSDate new]];
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:message.timestamp / 1000];

    
    BOOL isCanRecall = [date isEqualToDate:[date earlierDate:messageDate]] && [message.fromUser.userId isEqualToString:HDClient.sharedClient.currentAgentUser.agentId] && message.isSender;

    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (_recallMenuItem == nil) {
        _recallMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMenuAction:)];
    }

    NSMutableArray *itemAry = [NSMutableArray array];
    switch (message.type) {
        case HDMessageBodyTypeText:
        {
            [itemAry addObject:_copyMenuItem];
        }
        case HDMessageBodyTypeImage:
        case HDMessageBodyTypeVoice:
        case HDMessageBodyTypeLocation:
        case HDMessageBodyTypeFile:
        case HDMessageBodyTypeVideo:
        case HDMessageBodyTypeImageText:
        {
            if (isCanRecall) {
                [itemAry addObject:_recallMenuItem];
            }
        }
            
        default:
            break;
    }
    [_menuController setMenuItems:itemAry];
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_menuController setMenuVisible:YES animated:YES];
    });
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        HDMessage *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSString *content = @"";
        if (model.type == HDMessageBodyTypeText) {
            content = ((HDTextMessageBody *)model.nBody).text;
        }
        pasteboard.string = content;
    }
    _longPressIndexPath = nil;
}

- (void)recallMenuAction:(id)sender {
    if (_longPressIndexPath.row > 0) {
        HDMessage *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        [HDClient.sharedClient.chatManager recallMessage:model
                                              completion:^(HDMessage *message,
                                                           HDError *error)
        {
            // message仍然是之前的指针没有变化，所以发送结束后，可以直接根据是否有error，刷新tableView
            hd_dispatch_main_async_safe(^{
                if (error) {
                    [self showHint:error.errorDescription];
                }else {
                    [self prehandle:message]; // 重新计算 text bubble size
                    [self.tableView reloadData];
                }
            });
        
            /*  如果指针变化了，可以使用以下方式找到之前的对象
            __block NSInteger index = -1;
            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[HDMessage class]]) {
                    HDMessage *msg = (HDMessage *)obj;
                    if ([msg.messageId isEqualToString:message.messageId]) {
                        *stop = YES;
                        index = idx;
                    }
                }
            }];
            
            if (index != -1) {
                [self.dataSource replaceObjectAtIndex:index withObject:message];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
             */
        }];
    }
    _longPressIndexPath = nil;
}

- (void)markAsRead {
    [_conversation markMessagesAsReadWithVisitorId:_conversationModel.chatter.agentId parameters:nil completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            NSLog(@"标记已读成功");
        }
    }];
}
#pragma mark - 文件上传

- (void)presentDocumentPicker {

    [self presentViewController:self.documentPickerVC animated:YES completion:nil];
}
- (UIDocumentPickerViewController *)documentPickerVC {
    if (!_documentPickerVC) {
        NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        _documentPickerVC.delegate = self;
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet; //设置模态弹出方式
    }
    return _documentPickerVC;
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            if (error) {
                //读取出错
            } else {
//                if ([KFICloudManager iCloudEnable]) {
                    [KFICloudManager downloadWithDocumentURL:newURL callBack:^(id obj) {
                        NSData *data = obj;
                        //写入沙盒Documents
                        NSArray *array = [[newURL absoluteString] componentsSeparatedByString:@"/"];
                        NSString *fileName = [array lastObject];
                        fileName = [fileName stringByRemovingPercentEncoding];
//                        NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",fileName]];
                                        
//                        [self writeToFile:docPath withData:data withDisplayName:fileName];
                        [self writeToFileData:data withFileName:fileName];
                    }];
                        
//                }
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        //授权失败
        
    }
}
- (void)writeToFileData:(NSData *)data withFileName:(NSString *)fileName{
    NSError * error;
    NSString * fileDir = [NSString stringWithFormat:@"%@/%@/%@",[HDSanBoxFileManager libraryDir],kfAgentUploadFile,fileName];
    BOOL success = [HDSanBoxFileManager createFileAtPath:fileDir content:data overwrite:NO error:&error];
    if (success) {
        [self sendFileMessagePath:fileDir withDisplayName:fileName];
    }
    
}

- (void)writeToFile:(NSString *)path withData:(NSData *)data withDisplayName:(NSString *)displayName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //访问【沙盒的document】目录下的问题件，该目录下支持手动增加、修改、删除文件及目录
    if(![fileManager fileExistsAtPath:path]){
        //如果不存在
        BOOL success =   [data writeToFile:path atomically:YES];
        if (success) {
            //取出来
            [self sendFileMessagePath:path withDisplayName:displayName];
        }
    }else{
        //取出来 发送
        [self sendFileMessagePath:path withDisplayName:displayName];
    }
}

- (void)dealloc {
    [_conversation unbindSessionId];
    NSLog(@"___dealloc___%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
