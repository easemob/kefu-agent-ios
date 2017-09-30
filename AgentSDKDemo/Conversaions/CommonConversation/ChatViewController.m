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
#import "DXMessageManager.h"
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
#import "WebViewController.h"
#import "EMCDDeviceManager.h"
#import "HomeViewController.h"
#import "TransferViewController.h"
#import "AddTagViewController.h"
#import "TTOpenInAppActivity.h"
#import "EMChatHeaderTagView.h"
#import "EMUIWebViewController.h"
#import "EMFileViewController.h"
#import "EMPromptBoxView.h"
#import "DXRecordView.h"

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

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QuickReplyViewControllerDelegate,SRRefreshDelegate,EMCDDeviceManagerDelegate,EMUIWebViewControllerDelegate,HDChatManagerDelegate,HDClientDelegate,UIActionSheetDelegate,AddTagViewDelegate,EMPromptBoxViewDelegate,TransferViewControllerDelegate>
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
    NSIndexPath *_longPressIndexPath;
}

@property(nonatomic,strong) HDConversationManager *conversation;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者

@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) UIButton *tagBtn;//顶部打标签按钮
@property (strong, nonatomic) UIImageView *originTypeImage;//顶部渠道图片显示
@property (strong, nonatomic) UILabel *originTypeLable;//顶部渠道显示
@property (strong, nonatomic) UIButton *callBackBtn;//回呼按钮

@property (strong, nonatomic) UIView *moreView; //结束会话,会话标签,邀请评价,转接下拉菜单
@property (strong, nonatomic) NSMutableDictionary *sessionDic;
@property (strong, nonatomic) UIButton * backButton;
@property (strong, nonatomic) EMChatHeaderTagView *headview;
@property (strong, nonatomic) UIButton *folderButton;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) NSMutableDictionary *msgDic;

@property (nonatomic) BOOL isPlayingAudio;

@property (strong, nonatomic) NSDictionary *lastMsgExt;

@property (strong, nonatomic) EMPromptBoxView *promptBoxView;

@property(nonatomic,strong) DXRecordView *recordView;

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

- (instancetype)initWithtype:(ChatViewType)type
{
    self = [super init];
    if (self) {
        chatType = type;
        _page = 1;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.headview refreshHeaderView];
}

- (NSDictionary *)lastMsgExt {
    return _conversation.lastExtWeichat;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[HDClient sharedClient] removeDelegate:self];
    [[HDClient sharedClient].chatManager removeDelegate:self];
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
            BOOL success =  [fileManager removeItemAtPath:[dbDirectoryPath stringByAppendingPathComponent:filename] error:NULL];
            if (success) {
                NSLog(@"success");
            }
        }
    }
}

- (void)startNoti {
    [[HDClient sharedClient].chatManager removeDelegate:self];
    if ([HDClient sharedClient].chatManager==nil) {
        NSLog(@"error : [HDClient sharedClient].chatManager == nil");
    }
    [[HDClient sharedClient].chatManager addDelegate:self];
    
    [[HDClient sharedClient] removeDelegate:self];
    [[HDClient sharedClient] addDelegate:self delegateQueue:nil];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [KFManager sharedInstance].curChatViewConvtroller = self;
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
    if (chatType == ChatViewTypeChat) {
        UIView *titleView = [[UIView alloc] init];
        titleView.frame = self.tagBtn.frame;
        [titleView addSubview:self.tagBtn];
        [self.navigationItem setTitleView:titleView];
        [self.view addSubview:self.chatToolBar];
        [self.view addSubview:self.moreView];
        [self.view addSubview:self.headview];
        [self.view addSubview:self.folderButton];
        [self.view addSubview:self.promptBoxView];
    } else if (chatType == ChatViewTypeNoChat) {
        if (_conversationModel.vistor && _conversationModel.vistor.nicename.length > 0) {
            self.title = _conversationModel.vistor.nicename;
        }
        _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    } else if (chatType == ChatViewTypeCallBackChat) {
        UIView *titleView = [[UIView alloc] init];
        titleView.frame = self.tagBtn.frame;
        [titleView addSubview:self.tagBtn];
        [self.navigationItem setTitleView:titleView];

        _tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 48);
        [self.view addSubview:self.callBackBtn];
        [self.view addSubview:self.headview];
        [self.view addSubview:self.folderButton];
        [self.view addSubview:self.moreView];
    }
    _conversation = [[HDConversationManager alloc] initWithSessionId:_conversationModel.sessionId chatGroupId:_conversationModel.chatGroupId];
    [self markAsRead];
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.tableView addGestureRecognizer:tap];
//    [self setupForDismissKeyboard];
    
    [self loadMessage];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationRefreshAutoEnd:) name:NOTIFICATION_CONVERSATION_REFRESH_AUTOEND object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNumberChange:) name:NOTIFICATION_NOTIFY_NUMBER_CHANGE object:nil];
//    [fNotificationCenter addObserver:self selector:@selector(autoPop:) name:NOTIFICATION_CONVERSATION_REFRESH object:nil];
    [self loadTags];
    [[KFManager sharedInstance] setNavItemBadgeValueWithAllConversations:_allConversations];
    [self tableViewScrollToBottom];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)autoPop:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    if (dic) {
        if ([dic objectForKey:@"serviceSessionId"]) {
            if ([[dic objectForKey:@"serviceSessionId"] isEqualToString:self.conversationModel.sessionId]) {
                [self backAction];
            }
        }
    }
}

- (void)setupBarButtonItem
{
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, 36)];
    [_backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -44, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    
    if (chatType == ChatViewTypeChat) {
        _backButton.width = 100.f;
        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -44, 0, 0)];
        [_backButton setTitle:[NSString stringWithFormat:@"(%@)",_notifyNumber==nil?@"0":_notifyNumber] forState:UIControlStateNormal];
    }
    
    UIView *btnViews = [[UIView alloc] init];
    btnViews.frame = CGRectMake(0, 0, 100.f, 44);
    
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
        _promptBoxView.frame = CGRectMake(50, CGRectGetMaxY(self.tableView.frame) - 100, KScreenWidth - 100, 100);
        _promptBoxView.backgroundColor = [UIColor clearColor];
        _promptBoxView.backgroundColor = [UIColor redColor];
        _promptBoxView.delegate = self;
    }
    return _promptBoxView;
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
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:techChannelStr]];
        _originTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tagBtn.height - 17.5, self.tagBtn.width, 15)];
        _originTypeLable.textAlignment = NSTextAlignmentCenter;
        _originTypeLable.textColor = [UIColor whiteColor];
        _originTypeLable.attributedText = string;
//        if ([self.conversationModel.originType isEqualToString:@"app"]) {
//            _originTypeLable.text = @"APP";
//        } else if ([self.conversationModel.originType isEqualToString:@"webim"]) {
//            _originTypeLable.text = @"网页";
//        } else if ([self.conversationModel.originType isEqualToString:@"weixin"]) {
//            _originTypeLable.text = @"微信";
//        } else if ([self.conversationModel.originType isEqualToString:@"weibo"]) {
//            _originTypeLable.text = @"微博";
//        } else {
//            _originTypeLable.text = @"APP";
//        }
        _originTypeLable.font = [UIFont systemFontOfSize:15.f];
    }
    return _originTypeLable;
}

- (UIButton*)folderButton
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

- (UIButton*)callBackBtn
{
    if (_callBackBtn == nil) {
        _callBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _callBackBtn.frame = CGRectMake(0, KScreenHeight - 48 - 64, KScreenWidth, 48);
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

- (UIView*)moreView
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
            [satisfactionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
            [satisfactionBtn addTarget:self action:@selector(satisfactionyAction) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:satisfactionBtn];
            
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
        _tagBtn.frame = CGRectMake(0, 0, 200.0f, kNavBarHeight);
        _tagBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_tagBtn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
        [_tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [_tagBtn setTitleText:_conversationModel.chatter.nicename];
        [_tagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [_tagBtn layoutIfNeeded];
        
//        [_tagBtn addSubview:self.originTypeImage];
        [_tagBtn addSubview:self.originTypeLable];
    }
    return _tagBtn;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBACOLOR(235, 235, 235, 1);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
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
    }
}

- (void)downloadVoice:(HDMessage *)message {
    if (message.type == HDMessageBodyTypeVoice) {
        HDVoiceMessageBody *body = (HDVoiceMessageBody *)message.nBody;
        [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath completion:^(id responseObject, NSError *error) {
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
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(HDMessage *)obj];
    }
}

#pragma mark - DXMessageToolBarDelegate
- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.height = self.view.frame.size.height - toHeight;
        self.promptBoxView.top = self.view.frame.size.height - toHeight - self.promptBoxView.height;
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
                [weakSelf showHudInView:self.view hint:NSLocalizedString(@"media.timeShort", @"The recording time is too short")];
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
    HDMessage *message = [ChatSendHelper sendTextMessageWithString:@"自定义消息" toUser:_conversationModel.chatter.userId sessionId:_conversationModel.sessionId ext:nil];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:self.lastMsgExt];
    [parameters setObject:data forKey:MESSAGEBODY_MSGTYPE];
    message.body.msgExt = parameters;
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
    }];
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - EMPromptBoxViewDelegate

- (void)didSelectPromptBoxViewWithPhrase:(NSString*)phrase
{
    [self.promptBoxView searchText:@""];
    self.chatToolBar.inputTextView.text = phrase;
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UIGestureRecognizer *)gestureRecognizer
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    HDMessage *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        NSString *_dataString=[NSString stringWithUTF8String:[[userInfo objectForKey:@"url"] UTF8String]];
        WebViewController *webview = [[WebViewController alloc] initWithUrl:_dataString];
        [self.navigationController pushViewController:webview animated:YES];
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]){
        if (!model.isSender) {
            [self chatHeadImageBubblePressed:model];
        }
    } else if ([eventName isEqualToString:kResendButtonTapEventName]){
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
    }
}

- (void)chatFileCellBubblePressed:(HDMessage *)model
{
    EMFileViewController *viewController = [[EMFileViewController alloc] init];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(HDMessage *)model
{
    [self keyBoardHidden:nil];
    if (model.type != HDMessageBodyTypeImage) {
        return;
    }
    HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
    UIImage *image =  [[EMSDImageCache sharedImageCache] imageFromDiskCacheForKey:body.remotePath];
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
        [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath completion:^(id responseObject, NSError *error) {
            ;
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
            dispatch_async(dispatch_get_main_queue(), ^{
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
    WebViewController *webview = [[WebViewController alloc] initWithUrl:model.ext.msgtype.itemUrl];
    [self.navigationController pushViewController:webview animated:YES];
}

// 位置的bubble被点击
- (void)chatLocationCellBubblePressed:(HDMessage *)model
{
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.body.lat, model.body.lng)];
    [self.navigationController pushViewController:locationController animated:YES];
}



//头像被点击
- (void)chatHeadImageBubblePressed:(HDMessage *)model
{
    ClientInforViewController *clientView = [[ClientInforViewController alloc] init];
    clientView.userId = _conversationModel.chatter.userId;
    clientView.niceName = _conversationModel.chatter.nicename;
    clientView.tagImage = self.originTypeImage.image;
    if (clientView.userId.length == 0) {
        clientView.userId = _conversationModel.vistor.userId;
    }
    [self keyBoardHidden:nil];
    [self.navigationController pushViewController:clientView animated:YES];
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

- (void)backAction
{
    [[KFManager sharedInstance].conversation refreshData];
    
    _conversationModel.unreadCount = 0;
    [[KFManager sharedInstance] setTabbarBadgeValueWithAllConversations:_allConversations];
    [KFManager sharedInstance].curChatViewConvtroller = nil;
    if (chatType == ChatViewTypeChat) {
        if (_delegate && [_delegate respondsToSelector:@selector(refreshConversationList)]) {
            [_delegate refreshConversationList];
        }
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
    clientView.userId = _conversationModel.chatter.userId;
    clientView.niceName = _conversationModel.chatter.nicename;
    clientView.tagImage = self.originTypeImage.image;
    if (clientView.userId.length == 0) {
        clientView.userId = _conversationModel.vistor.userId;
    }
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
    [_conversation satisfactionStatusWithSessionId:self.conversationModel.sessionId completion:^(BOOL send, HDError *error) {
        if (error == nil) {
            if (send == YES) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"已经发送过满意度" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                return;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定发送满意度邀请吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
                alert.tag = 1001;
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
    [_conversation asyncGetSessionSummaryResultsWithSessionId:_conversationModel.sessionId completion:^(id responseObject, HDError *error) {
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
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1000) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"array", nil];
        if ([self.headview.dataSource count] > 0) {
            [self endConversation];
        } else {
            [_conversation asyncSaveSessionSummaryResultsWithSessionId:_conversationModel.sessionId parameters:parameters completion:^(id responseObject, HDError *error) {
                if (!error) {
                    [self endConversation];
                }
            }];
        }
    } else if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1001){
        [self showHintNotHide:@"发送中..."];
        WEAK_SELF
        [_conversation sendSatisfactionEvaluationWithSessionId:self.conversationModel.sessionId completion:^(BOOL send, HDError *error) {
            [self hideHud];
            if (error == nil) {
                [weakSelf showHint:@"已发送"];
//                DDLogInfo(@"send chat satisfaction --- %@ userId --- %@",[HDClient sharedClient].currentAgentUser,_conversationModel.chatter.userId);
            } else {
                
                [weakSelf showHint:@"发送失败"];
//                DDLogError(@"send chat satisfaction --- %@ userId --- %@ error:%@",[HDClient sharedClient].currentAgentUser.nicename,_conversationModel.chatter.userId,error.description);
            }
        }];
    }
}

- (void)endConversation {
    [_conversation endConversationWithVisitorId:_conversationModel.chatter.userId parameters:nil completion:^(id responseObject, HDError *error) {
        if (!error) {
            [self showHint:@"成功关闭"];
            [self.navigationController popViewControllerAnimated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(refreshConversationList)]) {
                [_delegate refreshConversationList];
            }
        } else {
            [self showHint:@"关闭失败"];
        }
    }];
}


- (void)callBackAction
{
    [self showHintNotHide:@"回呼中..."];
    WEAK_SELF
    [[HDClient sharedClient].chatManager asyncFetchCreateSessionWithVistorId:_conversationModel.vistor.userId completion:^(HDHistoryConversation *history, HDError *error) {
        [weakSelf hideHud];
        if (error ==  nil) {
            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeChat];
            history.chatter = history.vistor;
            chatView.conversationModel = history;
            [[KFManager sharedInstance] setCurChatViewConvtroller:chatView];
            [[KFManager sharedInstance].conversation refreshData];
            [weakSelf.navigationController pushViewController:chatView animated:YES];
        } else {
            if (error.code == 400) {
                [weakSelf showHint:@"回呼失败,用户正在会话"];
            } else {
                [weakSelf showHint:@"回呼失败"];
            }
        }
    }];
}

#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
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
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_messages addObject:message];
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

-(void)addMessagesToTop:(NSArray *)msgs
{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = msgs;
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
    HDMessage *message = [ChatSendHelper textMessageFormatWithText:text to:_conversationModel.chatter.userId sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
    }];
}


- (void)sendImageMessage:(UIImage*)orgImage
{
    HDMessage *message = [ChatSendHelper imageMessageFormatWithImageData:UIImageJPEGRepresentation(orgImage, 1.0) to:_conversationModel.chatter.userId sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
        if (error == nil) {
            HDImageMessageBody *bdy = (HDImageMessageBody *)aMessage.nBody;
            [[EMSDImageCache sharedImageCache] storeImage:orgImage forKey:bdy.remotePath];
        }
    }];
}


//recordPath为本地的amr path
-(void)sendAudioMessage:(NSString *)recordPath aDuration:(NSInteger )duration
{
    HDMessage *message = [ChatSendHelper voiceMessageFormatWithPath:recordPath to:_conversationModel.chatter.userId sessionId:_conversationModel.sessionId];
    [self addMessage:message];
    [self sendMessage:message completion:^(HDMessage *aMessage, HDError *error) {
        [self updateMessageWithMessage:aMessage];
        if (error == nil) {
            HDVoiceMessageBody *bdy = (HDVoiceMessageBody *)aMessage.nBody;
            NSString *uuid = [[KFFileCache sharedInstance] uuidWithUrlStr:bdy.remotePath];
            [[KFFileCache sharedInstance] moveItemAtPath:recordPath toCachePath:uuid];
            [[KFFileCache sharedInstance] storeFileWithRemoteUrl:bdy.remotePath completion:^(id responseObject, NSError *error) {
                ;
            }];
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
                    [self.dataSource replaceObjectAtIndex:index withObject:aMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
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
    [_conversation loadHistoryCompletion:^(NSArray<HDMessage *> *messages, HDError *error) {
        [self hideHud];
        [self addMessagesToTop:messages];
        for (HDMessage *msg in messages) {
            [self downloadVoice:msg];
        }
    }];
}

- (void)loadMessage{
    if (chatType == ChatViewTypeChat) {
        [self showHintNotHide:@""];
        [_conversation loadMessageCompletion:^(NSArray<HDMessage *> *messages, HDError *error) {
            [self hideHud];
            if (error == nil) {
                for (HDMessage *msg in messages) {
                    [self addMessage:msg];
                    [self downloadVoice:msg];
                }
            } else {
                [self showHint:error.errorDescription];
            }
            
        }];
    } else {
        _page = 0;
        WEAK_SELF
        [[HDClient sharedClient].chatManager asyncFetchHistoryMessagesWithSessionServicesId:_conversationModel.sessionId page:_page completion:^(id responseObject, HDError *error) {
            for (HDMessage *message in responseObject) {
                if (message.body) {
                    message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
                }
                if (![_msgDic objectForKey:message.messageId]) {
                    [_msgDic setObject:@"" forKey:message.messageId];
//                    [weakSelf downloadMessageAttachments:message];
                    [weakSelf addMessage:message];
                    [self downloadVoice:message];
                }
            }
        }];

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
    
    path = [NSString stringWithFormat:@"%@/%@",dbDirectoryPath,model.body.fileName];
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

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(HDMessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (messageType == HDMessageBodyTypeText) {
        [_menuController setMenuItems:@[_copyMenuItem]];
    }
    else{
        return;
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        HDMessage *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.body.content;
    }
    _longPressIndexPath = nil;
}

- (void)markAsRead {
    [_conversation markMessagesAsReadWithVisitorId:_conversationModel.chatter.userId parameters:nil completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            NSLog(@"标记已读成功");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
