//
//  CustomerChatViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "CustomerChatViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "DXMessageManager.h"
#import "DXMessageToolBar.h"
#import "DXTagView.h"
#import "QuickReplyViewController.h"
#import "ClientInforViewController.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "MessageReadManager.h"
#import "NSDate+Formatter.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "SRRefreshView.h"
#import "ChatSendHelper.h"
#import "UIAlertView+AlertBlock.h"
#import "TTOpenInAppActivity.h"

@interface CustomerChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SRRefreshDelegate,UIActionSheetDelegate,HDChatManagerDelegate>
{
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    
    NSTimeInterval startSessionTimestamp;
    
    BOOL hasMore;
}
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者

@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) NSMutableDictionary *msgDic;

@end

@implementation CustomerChatViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageQueue = dispatch_queue_create("kefu.easemob.com.customer", NULL);
        _messages = [NSMutableArray arrayWithCapacity:0];
        hasMore = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.tableView.backgroundColor = RGBACOLOR(244, 244, 242, 1);
    
    [self setupBarButtonItem];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.chatToolBar];

    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    [self loadUnreadMessage];
    
    [self setNotice];
}

- (void)setNotice {
    [[HDClient sharedClient].chatManager removeDelegate:self];
    [[HDClient sharedClient].chatManager addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[HDClient sharedClient].chatManager removeDelegate:self];
}

- (void)setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

#pragma mark - getter
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
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight]) type:ChatMoreTypeClientChat];
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
    
    return nil;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 16;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(HDMessage *)obj];
    }
}

#pragma mark - DXMessageToolBarDelegate
- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
        [self keyBoardHidden];
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
    } else if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
        [self keyBoardHidden];
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
    [self.navigationController pushViewController:quickView animated:YES];
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    HDMessage *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        //        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    } else if ([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        __block  HDMessage *messageModel = resendCell.messageModel;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [self chatResendButtonPressed:messageModel];
    } else if ([eventName isEqualToString:kRouterEventFileBubbleTapEventName]) {
        [self chatFileCellBubblePressed:model];
    }
}

- (void)chatFileCellBubblePressed:(HDMessage *)model
{
    if (model.localPath.length == 0) {
        [self showHint:@"正在下载文件,请稍后点击"];
        [self downloadMessageAttachments:model];
        return;
    }
    
    NSURL *URL = [NSURL fileURLWithPath:model.localPath];
    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:self.tableView.frame];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[openInAppActivity]];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        // Store reference to superview (UIActionSheet) to allow dismissal
        openInAppActivity.superViewController = activityViewController;
        // Show UIActivityViewController
        [self presentViewController:activityViewController animated:YES completion:NULL];
    } else {
        // Create pop up
        UIPopoverController *activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        // Store reference to superview (UIPopoverController) to allow dismissal
        openInAppActivity.superViewController = activityPopoverController;
        // Show UIActivityViewController in popup
        [activityPopoverController presentPopoverFromRect:self.tableView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(HDMessage *)model
{
    if (model.type != HDMessageBodyTypeImage) {
        return;
    }
    HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
    UIImage *image =  [[EMSDImageCache sharedImageCache] imageFromDiskCacheForKey:body.remotePath];
    if (image) {
        [self.messageReadManager showBrowserWithImages:@[image]];
    }
}

- (void)chatResendButtonPressed:(HDMessage *)model
{
    __block HDMessage *message = model;
    if (model.type == HDMessageBodyTypeText) {
//        __weak HDMessage *weakMessage = message;
        if (message.nBody) {
            ((HDTextMessageBody *)model.nBody).text = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:((HDTextMessageBody *)model.nBody).text];
        }
        
        
    } else if (model.type == HDMessageBodyTypeImage) {
        HDImageMessageBody *body = (HDImageMessageBody *)model.nBody;
        NSData *imageData = body.imageData;
        if (imageData == nil) {
            return;
        }
    }
    [[HDClient sharedClient].chatManager customerSendMessage:message completion:^(id responseObject, HDError *error) {
        message = responseObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - action

- (void)backAction
{
    [[KFManager sharedInstance].conversation refreshData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    NSLog(@"%s dealloc",__func__);
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    }];
    [self sendImageMessage:orgImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
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

-(void)addMessage:(HDMessage *)message
{
    [_messages addObject:message];
    __weak CustomerChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

-(void)addMessageToTop:(HDMessage *)message
{
    [_messages addObject:message];
    __weak CustomerChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
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

#pragma mark - 发送消息
- (void)sendTextMessage:(NSString *)text
{
   __block HDMessage *message = [ChatSendHelper customerTextMessageFormatWithText:text to:_userModel.userId];
    //new sendMessage
    [[HDClient sharedClient].chatManager customerSendMessage:message completion:^(id responseObject, HDError *error) {
        message = responseObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    HDTextMessageBody *body = (HDTextMessageBody *)message.nBody;
    if (body) {
        body.text = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:body.text];
    }
    [self addMessage:message];
}

- (void)sendImageMessage:(UIImage*)orgImage
{
    NSData *data = UIImageJPEGRepresentation(orgImage, 0.5);
    __block  HDMessage *message = [ChatSendHelper customerImageMessageFormatWithImageData:data to:_userModel.userId];
    [[HDClient sharedClient].chatManager customerSendMessage:message completion:^(id responseObject, HDError *error) {
        message = responseObject;
        HDImageMessageBody *body = (HDImageMessageBody *)message.nBody;
        NSString *key = body.remotePath;
        UIImage *image = [UIImage imageWithData:body.imageData];
        [[EMSDImageCache sharedImageCache] storeImage:image forKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [self addMessage:message];
}

- (NSString *)dateFormate:(NSTimeInterval)createDateTime {
    NSDate *date = [NSDate date];
    if (createDateTime != 0) {
        date = [NSDate dateWithTimeIntervalSince1970:createDateTime];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *rstDate = [formatter stringFromDate:date];
    return rstDate;
}
#pragma mark - 加载消息
//加载未读消息
- (void)loadUnreadMessage {
    if (!_msgDic) {
        _msgDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    
    [[HDClient sharedClient].chatManager asyncGetAgentUnreadMessagesWithRemoteAgentUserId:_userModel.userId parameters:parameters completion:^(NSArray <HDMessage *> *messages, HDError *error) {
        [self hideHud];
        if (!error) {
            for (HDMessage *message in messages) {
                if (message.body) {
                    message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
                }
                if (![weakSelf.msgDic objectForKey:message.messageId]) {
                    [weakSelf.msgDic setObject:@"" forKey:message.messageId];
                    [weakSelf downloadMessageAttachments:message];
                    [weakSelf addMessage:message];
                }
            }
            HDMessage *lastMessage = [messages lastObject];
            if (lastMessage) {
                [[HDClient sharedClient].chatManager asyncMarkMessagesAsReadWithRemoteAgentUserId:_userModel.userId lastCreateDateTime:lastMessage.localTime completion:^(id responseObject, HDError *error) {
                    if (error == nil) {
                        NSLog(@"mark success");
                    }
                }];
            }
        } else {
            if (![[HDClient sharedClient] isConnected]) {
//                DDLogError(@"customer chat view message load failed:stop try load %@",error.description);
                return;
            }
            //如果消息获取失败,重新获取一次
//            DDLogError(@"customer chat view message load failed:try load %@",error.description);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf loadUnreadMessage];
            });
        }
        
    }];
}

#pragma mark  slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadHistory];
    [_slimeView endRefresh];
}

//拉取历史消息【已读】
- (void)loadHistory
{
    if (!hasMore) {
        [MBProgressHUD show:@"没有更多历史记录" view:self.view];
        return;
    }
    if (self.dataSource.count == 0) {
        [self loadHistoryMessageWithTime:0];
    } else {
        HDMessage *model ;
        for (int i = (int)self.dataSource.count-1; i>=0; i--) {
            if ([self.dataSource[i] isKindOfClass:[HDMessage class]]) {
                model = self.dataSource[i];
            }
        }
        [self loadHistoryMessageWithTime:(model.localTime-1)/1000];
    }
}

- (void)loadHistoryMessageWithTime:(NSTimeInterval)timeInterval
{
    if (!_msgDic) {
        _msgDic = [NSMutableDictionary dictionary];
    }
    [self showHintNotHide:@"加载中..."];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    [parameters setObject:[self dateFormate:timeInterval] forKey:@"beginDateTime"];
    [parameters setValue:@(hPageLimit) forKey:@"size"];
    WEAK_SELF
    [[HDClient sharedClient].chatManager aysncGetAgentMessagesWithRemoteUserId:_userModel.userId parameters:parameters completion:^(NSArray<HDMessage *> *messages, HDError *error) {
        if (error == nil) {
            [weakSelf hideHud];
            for (HDMessage *message in messages) {
                if (message.body) {
                    message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
                }
                if (![weakSelf.msgDic objectForKey:message.messageId]) {
                    [weakSelf.msgDic setObject:@"" forKey:message.messageId];
                    [weakSelf downloadMessageAttachments:message];
                    [weakSelf addMessageToTop:message];
                }
            }
            if (messages.count < hPageLimit) {
                hasMore = NO;
            } else {
                hasMore = YES;
            }
        } else {
            if([[HDClient sharedClient] isConnected]){
//                DDLogError(@"customer chat view message load failed:stop try load %@",error.description);
                return;
            }
            //如果消息获取失败,重新获取一次
//            DDLogError(@"customer chat view message load failed:try load %@",error.description);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf loadHistoryMessageWithTime:_model.createDateTime];
            });
        }
       
        
    }];

}

//下载文件
- (void)downloadMessageAttachments:(HDMessage *)model
{
    if (model.type == HDMessageBodyTypeFile) {
        HDFileMessageBody *body = (HDFileMessageBody *)model.nBody;
        if (model.nBody) {
            [[KFHttpManager sharedInstance] asyncDownLoadFileWithFilePath:body.remotePath completion:^(id responseObject, NSError *error) {
                if (!error) {
                    model.localPath = [[KFFileCache sharedInstance] fileFullPathWithUrlStr:body.remotePath];
                     [self.tableView reloadData];
                }
            }];
        }
    }
}


- (void)messagesDidReceive:(NSArray<HDMessage *> *)aMessages {
    for (HDMessage *message in aMessages) {
        if (![message.fromUser.userId isEqualToString:_userModel.userId]) {
            return;
        }
        if (message.type == HDMessageBodyTypeText) {
            ((HDTextMessageBody *)message.nBody).text =  [ConvertToCommonEmoticonsHelper convertToSystemEmoticons: ((HDTextMessageBody *)message.nBody).text];
        }
        if (![_msgDic objectForKey:message.messageId]) {
            [_msgDic setObject:@"" forKey:message.messageId];
            [self addMessage:message];
            [[HDClient sharedClient].chatManager asyncMarkMessagesAsReadWithRemoteAgentUserId:_userModel.userId lastCreateDateTime:message.localTime completion:^(id responseObject, HDError *error) {
                NSLog(@"标记为已读%@%@",responseObject,error.errorDescription);
            }];
        }
    }
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
