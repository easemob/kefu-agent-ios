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
#import "MediaFileModel.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "MessageReadManager.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "SRRefreshView.h"
#import "LocationViewController.h"
#import "WebViewController.h"
#import "EMCDDeviceManager.h"

#import "TTOpenInAppActivity.h"
#import "EMFileViewController.h"
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

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SRRefreshDelegate,EMCDDeviceManagerDelegate,UIActionSheetDelegate,HDChatManagerDelegate>
{
    dispatch_queue_t _messageQueue;
    NSMutableArray *_messages;
    NSTimeInterval startSessionTimestamp;
    int lastSeqId;
    ChatViewType chatType;
    int _page;
    NSString *_enquiryStatus;
    
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    NSIndexPath *_longPressIndexPath;
}

@property(nonatomic,strong) HDConversation *conversation;

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
@property (strong, nonatomic) UIButton *folderButton;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) NSMutableDictionary *msgDic;

@property (nonatomic) BOOL isPlayingAudio;

@property (strong, nonatomic) NSDictionary *lastMsgExt;

@property(nonatomic,strong) DXRecordView *recordView;

@end

@implementation ChatViewController

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
        self.lastMsgExt = [NSDictionary dictionary];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
//    [self.headview refreshHeaderView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
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
    [[HDClient shareClient].chatManager removeDelegate:self];
     [[HDClient shareClient].chatManager addDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startNoti];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
        [self.view addSubview:self.folderButton];
    } else if (chatType == ChatViewTypeNoChat) {
        if (_conversationModel.vistor && _conversationModel.vistor.nicename.length > 0) {
            self.title = _conversationModel.vistor.nicename;
        }
        _tableView.frame = CGRectMake(0, 0, hScreenWidth, hScreenHeight);
    } else if (chatType == ChatViewTypeCallBackChat) {
        UIView *titleView = [[UIView alloc] init];
        titleView.frame = self.tagBtn.frame;
        [titleView addSubview:self.tagBtn];
        [self.navigationItem setTitleView:titleView];

        _tableView.frame = CGRectMake(0, 0, hScreenWidth, hScreenHeight - 48);
        [self.view addSubview:self.callBackBtn];
        [self.view addSubview:self.folderButton];
        [self.view addSubview:self.moreView];
    }
    _conversation = [[HDConversation alloc] initWithSessionId:_conversationModel.serciceSessionId chatGroupId:_conversationModel.chatGroupId];
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.tableView addGestureRecognizer:tap];
    
    [self loadMessage];
    [self loadEnquiryStatus];
}

#pragma mark - HDChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages {
    for (MessageModel *msg in aMessages) {
        [self addMessage:msg];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)autoPop:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    if (dic) {
        if ([dic objectForKey:@"serviceSessionId"]) {
            if ([[dic objectForKey:@"serviceSessionId"] isEqualToString:self.conversationModel.serciceSessionId]) {
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
        _originTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.originTypeImage.frame), self.tagBtn.height - 17.5, self.tagBtn.width, 15)];
        _originTypeLable.textColor = [UIColor whiteColor];
        if ([self.conversationModel.originType isEqualToString:@"app"]) {
            _originTypeLable.text = @"APP";
        } else if ([self.conversationModel.originType isEqualToString:@"webim"]) {
            _originTypeLable.text = @"网页";
        } else if ([self.conversationModel.originType isEqualToString:@"weixin"]) {
            _originTypeLable.text = @"微信";
        } else if ([self.conversationModel.originType isEqualToString:@"weibo"]) {
            _originTypeLable.text = @"微博";
        } else {
            _originTypeLable.text = @"APP";
        }
        _originTypeLable.font = [UIFont systemFontOfSize:15.f];
    }
    return _originTypeLable;
}

- (UIButton*)folderButton
{
    if (_folderButton == nil) {
        _folderButton = [[UIButton alloc] initWithFrame:CGRectMake((hScreenWidth-48)/2, 0, 48, 24)];
        [_folderButton setImage:[UIImage imageNamed:@"expand_arror_sesstion_tag_display"] forState:UIControlStateNormal];
        [_folderButton setImage:[UIImage imageNamed:@"expand_arror_sesstion_tag_display_2"] forState:UIControlStateSelected];
        [_folderButton addTarget:self action:@selector(folderButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _folderButton;
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
        _callBackBtn.frame = CGRectMake(0, hScreenHeight - 48 - 64, hScreenWidth, 48);
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
        _moreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hScreenWidth, hScreenHeight)];
        _moreView.userInteractionEnabled = YES;
        _moreView.backgroundColor = RGBACOLOR(0, 0, 0, 0.14902);
        _moreView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction)];
        [_moreView addGestureRecognizer:tap];
        
        if (chatType == ChatViewTypeChat) {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(hScreenWidth - 160, 0, 150, 40*4)];
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
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(hScreenWidth - 160, 0, 150, 40)];
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
        _tagBtn.frame = CGRectMake(0, 0, 100.0f, kNavBarHeight);
        _tagBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_tagBtn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
        [_tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [_tagBtn setTitleText:_conversationModel.chatter.nicename];
        [_tagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [_tagBtn layoutIfNeeded];
        
        [_tagBtn addSubview:self.originTypeImage];
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
            MessageModel *model = (MessageModel *)obj;
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
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - DXMessageToolBarDelegate
- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.height = self.view.frame.size.height - toHeight;
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
        [self sendTextMessage:text];
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
        if (!error) {
            //upload
            
            [weakSelf sendAudioMessage:recordPath aDuration:aDuration];
            
//            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
//                                                       displayName:@"audio"];
//            voice.duration = aDuration;
        }else {
            [weakSelf showHudInView:self.view hint:NSLocalizedString(@"media.timeShort", @"The recording time is too short")];
            weakSelf.chatToolBar.recordButton.enabled = NO;
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



- (void)moreViewCustomAction:(DXChatBarMoreView *)moreView
{
//    EMUIWebViewController *webView = [[EMUIWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"http:%@",[DXCSManager shareManager].loginUser.customUrl]];
//    webView.delegate = self;
//    [self.navigationController pushViewController:webView animated:YES];
    [self keyBoardHidden:nil];
}

#pragma mark - EMUIWebViewControllerDelegate

-(void)clickCustomWebView:(NSDictionary *)data
{
//    MessageModel *message = [ChatSendHelper sendTextMessageWithString:@"自定义消息" toUser:_conversationModel.chatter.userId serciceSessionId:_conversationModel.serciceSessionId ext:nil];
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:self.lastMsgExt];
//    [parameters setObject:data forKey:MESSAGEBODY_MSGTYPE];
//    message.body.msgExt = parameters;
//    __weak MessageModel *weakMessage = message;
//    [[DXCSManager shareManager] asyncFetchSendMessageVersionTwoWithUserId:_conversationModel.chatter.userId
//                                                                ServiceId:_conversationModel.serciceSessionId
//                                                          otherParameters:[message.body selfDicDesc]
//                                                               completion:^(id responseObject, DXError *error) {
//                                                                   if (!error) {
//                                                                       if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                                                                           MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                                                                           model.status = kefuMessageDeliveryState_Delivered;
//                                                                           [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                                                                       }
//                                                                       weakMessage.status = kefuMessageDeliveryState_Delivered;
//                                                                       self.conversationModel.lastMessage = weakMessage;
//                                                                   } else {
//                                                                       weakMessage.status = kefuMessageDeliveryState_Pending;
//                                                                       self.conversationModel.lastMessage = weakMessage;
//                                                                       [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//                                                                   }
//                                                                   dispatch_async(dispatch_get_main_queue(), ^{
//                                                                       [self.tableView reloadData];
//                                                                   });
//                                                               }];
//    if (message.body) {
//        message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
//    }
//    [self addMessage:message];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - EMPromptBoxViewDelegate


#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UIGestureRecognizer *)gestureRecognizer
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        NSString *_dataString=[NSString stringWithUTF8String:[[userInfo objectForKey:@"url"] UTF8String]];
        _dataString = [_dataString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
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
        MessageModel *messageModel = resendCell.messageModel;
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

- (void)chatFileCellBubblePressed:(MessageModel *)model
{
    
    EMFileViewController *viewController = [[EMFileViewController alloc] init];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    if (![model.localPath hasSuffix:@"amr"]) {
        [self showHint:@"正在下载声音,请稍后点击"];
//        [self downloadMessageAttachments:model];
        return;
    }
    
    // 播放音频
    if (model.type == kefuMessageBodyType_Voice) {
        __weak ChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            WEAK_SELF
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.localPath completion:^(NSError *error) {
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
}

// 图文混排的bubble被点击
- (void)chatImageTextCellBubblePressed:(MessageModel *)model
{
    WebViewController *webview = [[WebViewController alloc] initWithUrl:model.ext.msgtype.itemUrl];
    [self.navigationController pushViewController:webview animated:YES];
}

// 位置的bubble被点击
- (void)chatLocationCellBubblePressed:(MessageModel *)model
{
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.body.lat, model.body.lng)];
    [self.navigationController pushViewController:locationController animated:YES];
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(MessageModel *)model
{
    [self keyBoardHidden:nil];
    if (model.image) {
        [self.messageReadManager showBrowserWithImages:@[model.image]];
    }
}

//头像被点击
- (void)chatHeadImageBubblePressed:(MessageModel *)model
{
//    ClientInforViewController *clientView = [[ClientInforViewController alloc] init];
//    clientView.userId = _conversationModel.chatter.userId;
//    clientView.niceName = _conversationModel.chatter.nicename;
//    clientView.tagImage = self.originTypeImage.image;
//    if (clientView.userId.length == 0) {
//        clientView.userId = _conversationModel.vistor.userId;
//    }
    [self keyBoardHidden:nil];
//    [self.navigationController pushViewController:clientView animated:YES];
}

- (void)chatResendButtonPressed:(MessageModel *)model
{
//    model.status = kefuMessageDeliveryState_Delivering;
//    if (model.type == kefuMessageBodyType_Text) {
//        __weak MessageModel *weakMessage = model;
//        [[DXCSManager shareManager] asyncFetchSendMessageVersionTwoWithUserId:_conversationModel.chatter.userId
//                                                                    ServiceId:_conversationModel.serciceSessionId
//                                                              otherParameters:[model.body selfDicDesc]
//                                                                   completion:^(id responseObject, DXError *error) {
//            if (!error) {
//                weakMessage.status = kefuMessageDeliveryState_Delivered;
//                self.conversationModel.lastMessage = weakMessage;
//                if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                    MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                    model.status = kefuMessageDeliveryState_Delivered;
//                    [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                } else {
//                    [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                }
//            } else {
//                weakMessage.status = kefuMessageDeliveryState_Pending;
//                self.conversationModel.lastMessage = weakMessage;
//                [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//            });
//        }];
//    } else if (model.type == kefuMessageBodyType_Image) {
//        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:model.body.thumbPath];
//        if (imageData) {
//            __weak MessageModel *weakMessage = model;
//            [[DXCSManager shareManager] asyncFetchUploadWithFile:imageData Completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    MediaFileModel *media = [[MediaFileModel alloc] initWithDictionary:responseObject];
//                    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[ChatSendHelper uploadImage:media]];
//                    if (self.lastMsgExt) {
//                        [parameters setObject:self.lastMsgExt forKey:MESSAGEBODY_MSGEXT];
//                    }
//                    [[DXCSManager shareManager] asyncFetchSendMessageVersionTwoWithUserId:_conversationModel.chatter.userId
//                                                                                ServiceId:_conversationModel.serciceSessionId
//                                                                          otherParameters:parameters
//                                                                               completion:^(id responseObject, DXError *error) {
//                        if (!error) {
//                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                                MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                                model.status = kefuMessageDeliveryState_Delivered;
//                                [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:weakMessage.body.thumbPath];
//                            }
//                            weakMessage.status = kefuMessageDeliveryState_Delivered;
//                            self.conversationModel.lastMessage = weakMessage;
//                        } else {
//                            weakMessage.status = kefuMessageDeliveryState_Pending;
//                            self.conversationModel.lastMessage = weakMessage;
//                            [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//                        }
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.tableView reloadData];
//                        });
//                    }];
//                } else {
//                    weakMessage.status = kefuMessageDeliveryState_Pending;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.tableView reloadData];
//                    });
//                }
//            }];
//        }
//    }
}

#pragma mark - action

- (void)folderButtonAction
{
    self.folderButton.selected = !self.folderButton.selected;
//    if (self.folderButton.selected) {
//        self.headview.hidden = NO;
//        self.headview.top = -self.headview.height;
//        [UIView animateWithDuration:0.2 animations:^{
//            self.headview.top = 0;
//            self.folderButton.top = self.headview.height;
//        }];
//    } else {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.headview.top = -self.headview.height;
//            self.folderButton.top = 0;
//        } completion:^(BOOL finished) {
//            self.headview.hidden = YES;
//        }];
//    }
}

- (void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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




- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1000) {
//        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray array],@"array", nil];
//        if ([self.headview.dataSource count] > 0) {
//            [self endConversation];
//        } else {
//            [[DXCSManager shareManager] asyncFetchSaveServiceSessionSummaryResultsWithSessionId:_conversationModel.serciceSessionId otherParameters:parameters completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    [self endConversation];
//                }
//            }];
//        }
//    } else if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1001){
//        [self showHintNotHide:@"发送中..."];
//        WEAK_SELF
//        [[DXCSManager shareManager] asyncSendSatisfaction:self.conversationModel.serciceSessionId completion:^(id responseObject, DXError *error) {
//            [weakSelf hideHud];
//            if (!error) {
//                _enquiryStatus = @"invited";
//                DDLogInfo(@"send chat satisfaction --- %@ userId --- %@",[DXCSManager shareManager].loginUserName,_conversationModel.chatter.userId);
//            } else {
//                [weakSelf showHint:@"发送失败"];
//                DDLogError(@"send chat satisfaction --- %@ userId --- %@ error:%@",[DXCSManager shareManager].loginUserName,_conversationModel.chatter.userId,error.description);
//            }
//        }];
//    }
}


- (void)callBackAction
{
//    [self showHintNotHide:@"回呼中..."];
//    WEAK_SELF
//    [[DXCSManager shareManager] asyncFetchCreateSessionWithVistorId:_conversationModel.chatter.userId Completion:^(id responseObject, DXError *error) {
//        [weakSelf hideHud];
//        if (!error) {
//            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
//                ConversationModel *model = [[ConversationModel alloc] initWithDictionary:responseObject];
//                ChatViewController *chatView = [[ChatViewController alloc] init];
//                chatView.conversationModel = model;
//                model.chatter = model.vistor;
//                [[DXMessageManager shareManager] setCurSessionId:model.serciceSessionId];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONVERSATION_REFRESH object:nil];
//                [weakSelf.navigationController pushViewController:chatView animated:YES];
//            }
//
//        } else {
//            if (error.statusCode == 400) {
//                [weakSelf showHint:@"回呼失败,用户正在会话"];
//            } else {
//                [weakSelf showHint:@"回呼失败"];
//            }
//        }
//    }];
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
    [self showHint:@"结束会话..."];
    WEAK_SELF
//    [[DXCSManager shareManager] asyncFetchEndChatWithVisitorId:_conversationModel.chatter.userId
//                                              serviceSessionId:_conversationModel.serciceSessionId
//                                                withParameters:nil completion:^(id responseObject, DXError *error) {
//                                                    [weakSelf hideHud];
//                                                    if (!error) {
//                                                        DDLogInfo(@"end chat succeed --- %@ userId --- %@",[DXCSManager shareManager].loginUserName,_conversationModel.chatter.userId);
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENDCHAT object:_conversationModel.serciceSessionId];
//                                                        [[KefuDBManager shareManager] deleteConversationBySessionId:_conversationModel.serciceSessionId];
//                                                        [self.navigationController popToRootViewControllerAnimated:YES];
//                                                    } else {
//                                                        [weakSelf showHint:@"结束会话失败"];
//                                                        DDLogError(@"end chat failed --- %@ userId --- %@ error:%@",[DXCSManager shareManager].loginUserName,_conversationModel.chatter.userId,error.description);
//                                                    }
//                                                }];
}

#pragma mark - private

- (void)loadEnquiryStatus
{
//    NSString *path = [NSString stringWithFormat:API_GET_ENQUIRYSTATUS,[[DXCSManager shareManager] loginUser].tenantId,self.conversationModel.serciceSessionId];
//    [[DXCSManager shareManager] asyncSendGet:path withParameters:nil completion:^(id responseObject, DXError *error) {
//        if (error == nil && responseObject != nil) {
//            NSDictionary *json = responseObject;
//            NSArray *data = [json objectForKey:@"data"];
//            if (data && [data isKindOfClass:[NSArray class]] && [data count] > 0) {
//                _enquiryStatus = [data objectAtIndex:0];
//            }
//        }
//    }];
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

-(void)addMessage:(MessageModel *)message
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

-(void)addMessageToTop:(MessageModel *)message
{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_messages addObject:message];
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                   NSMakeRange(0,[messages count])];
            [weakSelf.dataSource insertObjects:messages atIndexes:indexes];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

-(NSMutableArray *)formatMessage:(MessageModel *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)message.createInterval/1000];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
//        [ret addObject:[createDate minuteDescription]];
        self.chatTagDate = createDate;
    }
    
    if (message) {
        [ret addObject:message];
    }
    return ret;
}

- (void)sendTextMessage:(NSString *)text
{
    MessageBodyModel *body = [[MessageBodyModel alloc] initWithText:text];
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:self.lastMsgExt];
    
    [[HDNetworkManager shareInstance] asyncSendMessageWithMessageModel:msg completion:^(MessageModel *message, HDError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [self addMessage:message];
    }];
}


-(void)sendAudioMessage:(NSString *)recordPath aDuration:(NSInteger )duration
{
    MessageBodyModel *body = [[MessageBodyModel alloc] initWithAudioLocalPath:recordPath];
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:self.lastMsgExt];
    [[HDNetworkManager shareInstance] asyncSendMessageWithMessageModel:msg completion:^(MessageModel *message, HDError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [self addMessage:message];
    }];
}

- (void)sendImageMessage:(UIImage*)orgImage
{
    MessageBodyModel *body = [[MessageBodyModel alloc] initWithUIImage:orgImage];
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:self.lastMsgExt];
    [[HDNetworkManager shareInstance] asyncSendMessageWithMessageModel:msg completion:^(MessageModel *message, HDError *error) {
        [self addMessage:message];
    }];

}

- (void)loadHistory
{

    [self showHintNotHide:@"加载历史会话"];
    [_conversation loadHistoryCompletion:^(NSArray<MessageModel *> *messages, HDError *error) {
        [self hideHud];
        for (MessageModel *msg in messages) {
            [self addMessageToTop:msg];
        }
    }];

}

- (void)loadMessage
{
    
    [_conversation loadMessageCompletion:^(NSArray<MessageModel *> *messages, HDError *error) {
        for (MessageModel *msg in messages) {
            [self addMessage:msg];
        }
    }];
}


+ (BOOL)isExistFile:(MessageModel*)model
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
            if ([[dic objectForKey:@"serviceSessionId"] isEqualToString:self.conversationModel.serciceSessionId]) {
                [self backAction];
            }
        }
    }
}

- (void)notifyNumberChange:(NSNotification*)notification
{
//    NSString *number = [HomeViewController currentBadgeValue];
    [_backButton setTitle:[NSString stringWithFormat:@"(%@)",notification.object==nil?@(0):notification.object] forState:UIControlStateNormal];
}

- (void)newChatMesassage:(NSNotification*)notification
{
    NSArray *msgs = notification.object;
    for (NSDictionary *msg in msgs) {
        MessageModel *message = [[MessageModel alloc] initWithDictionary:msg];
        message.status = kefuMessageDeliveryState_Delivered;
        NSString *fromUser = [msg objectForKey:@"fromUser"];
        if (![message.sessionServiceId isEqualToString:_conversationModel.serciceSessionId]) {
            return;
        }
        if (fromUser) {
            message.isSender = YES;
            if ([fromUser valueForKey:@"userType"] && [[fromUser valueForKey:@"userType"] isEqualToString:@"Visitor"]) {
                message.isSender = NO;
                id body = [msg objectForKey:@"body"];
                if (body && [body objectForKey:@"ext"] && [[body objectForKey:@"ext"] isKindOfClass:[NSDictionary class]]) {
                    if (message.type != kefuMessageBodyType_ImageText) {
                        self.lastMsgExt = [body objectForKey:@"ext"];
                    }
                    message.body.msgExt = [body objectForKey:@"ext"];
                }
            }
            if (message.body) {
                message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
            }
            if (![_msgDic objectForKey:message.messageId]) {
                [_msgDic setObject:@"" forKey:message.messageId];
//                [self downloadMessageAttachments:message];
                [self addMessage:message];
            }
        }
        if (!(message.body.content.length == 0 && message.type == kefuMessageBodyType_Text)) {
//            [[KefuDBManager shareManager] insertMessage:message];
        }
    }
}

#pragma mark - private

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(KefuMessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (messageType == kefuMessageBodyType_Text) {
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
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.body.content;
    }
    _longPressIndexPath = nil;
}

- (void)dealloc {
    NSLog(@"%s dealloc",__func__);
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
