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

@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SRRefreshDelegate,EMCDDeviceManagerDelegate,UIActionSheetDelegate,HDChatManagerDelegate,HDClientDelegate>
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

- (void)startNoti {
    [[HDClient shareClient].chatManager removeDelegate:self];
     [[HDClient shareClient].chatManager addDelegate:self];
    [[HDClient shareClient] removeDelegate:self];
    [[HDClient shareClient] addDelegate:self delegateQueue:nil];
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
        [self.view addSubview:self.chatToolBar];
        [self.view addSubview:self.moreView];
        [self.view addSubview:self.folderButton];
    }
    _conversation = [[HDConversation alloc] initWithSessionId:_conversationModel.serciceSessionId chatGroupId:_conversationModel.chatGroupId];
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.tableView addGestureRecognizer:tap];
    
    [self loadMessage];
}

#pragma mark - HDClientDelegate
- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {
    if ([_conversationModel.serciceSessionId isEqualToString:serviceSessionId]) {
        [self showHint:@"会话自动关闭"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)conversationClosedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    if ([_conversationModel.serciceSessionId isEqualToString:serviceSessionId]) {
        [self showHint:@"会话被管理员关闭"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}



#pragma mark - HDChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages {
    for (MessageModel *msg in aMessages) {
        if (![_conversationModel.serciceSessionId isEqualToString:msg.sessionServiceId]) {
            return;
        }
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


- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
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
    [self keyBoardHidden:nil];
}

- (void)chatResendButtonPressed:(MessageModel *)model
{
    
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

#pragma mark - private

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
        self.chatTagDate = createDate;
    }
    
    if (message) {
        [ret addObject:message];
    }
    return ret;
}


- (NSDictionary *)messageExt {
    NSDictionary *ext = @{
                          @"price":@"rmb:888",
                          @"imgUrl":@"http://www.easemob.com/test.jpg",
                          @"title":@"标题",
                          @"detail":@"商品描述"
                          };
    return ext;
}

- (void)sendTextMessage:(NSString *)text
{
    MessageBodyModel *body = [[MessageBodyModel alloc] initWithText:text];
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:[self messageExt]];
    
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
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:[self messageExt]];
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
    MessageModel *msg = [[MessageModel alloc] initWithServiceSessionId:_conversationModel.serciceSessionId userId:_conversationModel.chatter.userId messageBody:body ext:[self messageExt]];
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


- (void)notifyNumberChange:(NSNotification*)notification
{
//    NSString *number = [HomeViewController currentBadgeValue];
    [_backButton setTitle:[NSString stringWithFormat:@"(%@)",notification.object==nil?@(0):notification.object] forState:UIControlStateNormal];
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


- (void)dealloc {
    [[HDClient shareClient] removeDelegate:self];
    [[HDClient shareClient].chatManager removeDelegate:self];
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
