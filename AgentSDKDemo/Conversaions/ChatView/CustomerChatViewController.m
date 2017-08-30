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

#import "DXMessageToolBar.h"


#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"

#import "MessageReadManager.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "MediaFileModel.h"
#import "SRRefreshView.h"
#import "UIAlertView+AlertBlock.h"
#import "TTOpenInAppActivity.h"

@interface CustomerChatViewController ()<UITableViewDelegate,UITableViewDataSource,DXMessageToolBarDelegate,DXChatBarMoreViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SRRefreshDelegate,UIActionSheetDelegate>
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
        hasMore = YES;
        _page = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
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
    
    [self loadMessage];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
        //        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        //        lpgr.minimumPressDuration = .5;
        //        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight]) type:ChatMoreTypeClientChat];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
//        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 105) typw:ChatMoreTypeClientChat];
//        _chatToolBar.moreView.backgroundColor = RGBACOLOR(240, 242, 247, 1);
//        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
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
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
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


#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        //        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    } else if ([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
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

- (void)chatFileCellBubblePressed:(MessageModel *)model
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
- (void)chatImageCellBubblePressed:(MessageModel *)model
{
    if (model.image) {
        [self.messageReadManager showBrowserWithImages:@[model.image]];
    }
}

- (void)chatResendButtonPressed:(MessageModel *)model
{
    model.status = kefuMessageDeliveryState_Delivering;
    if (model.type == kefuMessageBodyType_Text) {
        __weak MessageModel *weakMessage = model;
        if (model.body) {
            model.body.content = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:model.body.content];
        }
//        [[DXCSManager shareManager] asyncFetchSendMessageWithRemoteAgentId:_userModel.userId otherParameters:[model.body selfDicDesc] completion:^(id responseObject, DXError *error) {
//            if (!error) {
//                if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                    MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                    model.status = kefuMessageDeliveryState_Delivered;
//                    [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                }
//                weakMessage.status = kefuMessageDeliveryState_Delivered;
//            } else {
//                weakMessage.status = kefuMessageDeliveryState_Pending;
//                [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//            });
//        }];
    } else if (model.type == kefuMessageBodyType_Image) {
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:model.body.thumbPath];
        if (imageData) {
            __weak MessageModel *weakMessage = model;
//            [[DXCSManager shareManager] asyncFetchUploadWithFile:imageData Completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    MediaFileModel *media = [[MediaFileModel alloc] initWithDictionary:responseObject];
//                    NSDictionary *parameters = [ChatSendHelper uploadImage:media];
//                    [[DXCSManager shareManager] asyncFetchSendMessageWithRemoteAgentId:_userModel.userId otherParameters:parameters completion:^(id responseObject, DXError *error) {
//                        if (!error) {
//                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                                MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                                model.status = kefuMessageDeliveryState_Delivered;
//                                [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:weakMessage.body.thumbPath];
//                            }
//                            weakMessage.status = kefuMessageDeliveryState_Delivered;
//                        } else {
//                            weakMessage.status = kefuMessageDeliveryState_Pending
//                            ;
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
        }
    }
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)addMessage:(MessageModel *)message
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

-(void)addMessageToTop:(MessageModel *)message
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
//    MessageModel *message = [ChatSendHelper sendTextToCustomerMessageWithString:text toUser:_userModel.userId serciceSessionId:_userModel.userId];
//    __weak MessageModel *weakMessage = message;
//    [[DXCSManager shareManager] asyncFetchSendMessageWithRemoteAgentId:_userModel.userId otherParameters:[message.body selfDicDesc] completion:^(id responseObject, DXError *error) {
//        if (!error) {
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                model.status = kefuMessageDeliveryState_Delivered;
//                [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//            }
//            weakMessage.status = kefuMessageDeliveryState_Delivered;
//        } else {
//            weakMessage.status = kefuMessageDeliveryState_Pending;
//            [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    }];
//    if (message.body) {
//        message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
//    }
//    [self addMessage:message];
}

- (void)sendImageMessage:(UIImage*)orgImage
{
//    MessageModel *message = [ChatSendHelper sendImageToCustomerMessageWithImage:orgImage toUser:_userModel.userId serciceSessionId:_userModel.userId];
//    NSData *data = UIImageJPEGRepresentation(orgImage, 0.5);
//    __weak MessageModel *weakMessage = message;
//    [[DXCSManager shareManager] asyncFetchUploadWithFile:data Completion:^(id responseObject, DXError *error) {
//        if (!error) {
//            MediaFileModel *media = [[MediaFileModel alloc] initWithDictionary:responseObject];
//            NSDictionary *parameters = [ChatSendHelper uploadImage:media];
//            [[DXCSManager shareManager] asyncFetchSendMessageWithRemoteAgentId:_userModel.userId otherParameters:parameters completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                        MessageModel *model = [[MessageModel alloc] initWithDictionary:responseObject];
//                        model.status = kefuMessageDeliveryState_Delivered;
//                        [[KefuDBManager shareManager] updateMesage:model withMessageId:weakMessage.messageId];
//                    }
//                    weakMessage.status = kefuMessageDeliveryState_Delivered;
//                } else {
//                    weakMessage.status = kefuMessageDeliveryState_Pending;
//                    [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            }];
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableView reloadData];
//            });
//            weakMessage.status = kefuMessageDeliveryState_Pending;
//            [[KefuDBManager shareManager] updateMesage:weakMessage withMessageId:weakMessage.messageId];
//        }
//    }];
//    [self addMessage:message];
}

- (void)loadHistory
{
    /*
    [[DXCSManager shareManager] asyncFetchRemoteAgentUsersHistoryWithRemoteAgentUserId:_userModel.userId isHistory:YES otherParameters:nil Completion:^(id responseObject, DXError *error) {
        if (!error) {
            if (responseObject) {
                NSArray *items = [responseObject objectForKey:@"messages"];
                int count = 0;
                for (int i = (int)[items count] - ((int)_page - 1)*PAGE_LIMIT - 1; i >=(int)[items count] - (int)_page*PAGE_LIMIT; i --) {
                    if (i < [items count] && i > 0) {
                        NSDictionary *msg = [items objectAtIndex:i];
                        MessageModel *message = [[MessageModel alloc] initWithDictionary:msg];
                        message.status = eMessageDeliveryState_Delivered;
                        NSString *fromUser = [msg objectForKey:@"fromUser"];
                        if (fromUser) {
                            if ([[fromUser valueForKey:@"userId"] isEqualToString:[DXCSManager shareManager].loginUser.userId]) {
                                message.isSender = YES;
                            } else if ([[fromUser valueForKey:@"userId"] isEqualToString:@"_2"]) {
                                message.isSender = YES;
                            }
                        }
                        if (message.body) {
                            message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
                        }
                        if (![_msgDic objectForKey:message.messageId]) {
                            [_msgDic setObject:message.messageId forKey:@""];
                            [self downloadMessageAttachments:message];
                            [self addMessageToTop:message];
                        }
                        count ++;
                    }
                }
                if (count < PAGE_LIMIT) {
                    hasMore = NO;
                } else {
                    hasMore = YES;
                }
                _page++;
            }
        } else {
            
        }
    }];*/
//    if (!hasMore) {
//        [MBProgressHUD show:@"没有更多历史记录" view:self.view];
//        return;
//    }
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters setObject:@(_model.createDateTime) forKey:@"startSessionTimestamp"];
//    [self showHintNotHide:@"加载中..."];
//    WEAK_SELF
//    [[DXCSManager shareManager] asyncFetchRemoteAgentUsersHistoryWithRemoteAgentUserId:_userModel.userId isHistory:YES otherParameters:parameters Completion:^(id responseObject, DXError *error) {
//        [weakSelf hideHud];
//        if (!weakSelf) {
//            return;
//        }
//        if (!error) {
//            if (responseObject) {
//                NSArray *items = [responseObject objectForKey:@"items"];
//                int count = 0;
//                int curCount = (int)[self.dataSource count];
//                for (NSDictionary *msg in items) {
//                    MessageModel *message = [[MessageModel alloc] initWithDictionary:msg];
//                    message.status = kefuMessageDeliveryState_Delivered;
//                    NSString *fromUser = [msg objectForKey:@"fromUser"];
//                    if (fromUser) {
//                        if ([[fromUser valueForKey:@"userId"] isEqualToString:[DXCSManager shareManager].loginUser.userId]) {
//                            message.isSender = YES;
//                        } else if ([[fromUser valueForKey:@"userId"] isEqualToString:@"_2"]) {
//                            message.isSender = YES;
//                        }
//                    }
//                    if (message.body) {
//                        message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
//                    }
//                    if (![_msgDic objectForKey:message.messageId]) {
//                        [_msgDic setObject:@"" forKey:message.messageId];
//                        [weakSelf downloadMessageAttachments:message];
//                        [weakSelf addMessageToTop:message];
//                    }
//                    count ++;
//                }
//                if (curCount == [self.dataSource count]) {
//                    hasMore = NO;
//                } else {
//                    if (count < PAGE_LIMIT) {
//                        hasMore = NO;
//                        _page++;
//                    } else {
//                        hasMore = YES;
//                    }
//                }
//            }
//        }
//    }];
}

- (void)loadMessage
{
    if (!_msgDic) {
        _msgDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(_model.createDateTime) forKey:@"startSessionTimestamp"];
    [self showHintNotHide:@"加载中..."];
//    WEAK_SELF
//    [[DXCSManager shareManager] asyncFetchRemoteAgentUsersHistoryWithRemoteAgentUserId:_userModel.userId isHistory:NO otherParameters:parameters Completion:^(id responseObject, DXError *error) {
//        [weakSelf hideHud];
//        if (!weakSelf) {
//            return;
//        }
//        if (!error) {
//            if (responseObject) {
//                NSArray *items = [responseObject objectForKey:@"messages"];
//                int count = 0;
//                NSInteger lastSeqId = 0;
//                for (int i = (int)[items count] - 1; i >= 0; i--) {
//                    if (![[items objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
//                        continue;
//                    }
//                    NSDictionary *msg = [items objectAtIndex:i];
//                    MessageModel *message = [[MessageModel alloc] initWithDictionary:msg];
//                    message.status = kefuMessageDeliveryState_Delivered;
//                    NSString *fromUser = [msg objectForKey:@"fromUser"];
//                    if (fromUser) {
//                        if ([[fromUser valueForKey:@"userId"] isEqualToString:[DXCSManager shareManager].loginUser.userId]) {
//                            message.isSender = YES;
//                        } else if ([[fromUser valueForKey:@"userId"] isEqualToString:@"_2"]) {
//                            message.isSender = YES;
//                        }
//                    }
//                    if (message.body) {
//                        message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
//                    }
//                    if (![weakSelf.msgDic objectForKey:message.messageId]) {
//                        [weakSelf.msgDic setObject:@"" forKey:message.messageId];
//                        [weakSelf downloadMessageAttachments:message];
//                        [weakSelf addMessage:message];
//                    }
//                    lastSeqId = message.chatGroupSeqId;
//                    count ++;
//                }
//                if (count < PAGE_LIMIT) {
//                    hasMore = NO;
//                } else {
//                    hasMore = YES;
//                    _page++;
//                }
//                //标记已读
////                NSString *lastSeqId = [responseObject objectForKey:@"lastSeqId"];
//                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//                [parameters setObject:@(lastSeqId) forKey:@"lastSeqId"];
//                [[DXCSManager shareManager] asyncFetchMarkReadTagWithRemoteAgentUserId:_userModel.userId otherParameters:parameters completion:^(id responseObject, DXError *error) {
//                }];
//            }
//        } else {
//            if ([[DXMessageManager shareManager] currentState]) {
//                DDLogError(@"customer chat view message load failed:stop try load %@",error.description);
//                return;
//            }
//            //如果消息获取失败,重新获取一次
//            DDLogError(@"customer chat view message load failed:try load %@",error.description);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf loadMessage];
//            });
//        }
//    }];
}

- (void)downloadMessageAttachments:(MessageModel *)model
{
    WEAK_SELF
    if (model.type == kefuMessageBodyType_Image) {
        if (model.body) {
//            [[DXCSManager shareManager] asyncFetchDownLoadWithImageFilePath:model.body.originalPath Completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    model.image = responseObject;
//                    [weakSelf.tableView reloadData];
//                } else {
//                    
//                }
//            }];
        }
    } else if (model.type == kefuMessageBodyType_File) {
        if (model.body) {
//            [[DXCSManager shareManager] asyncFetchDownLoadWithFilePath:model.body.originalPath Completion:^(id responseObject, DXError *error) {
//                if (!error) {
//                    NSString *libDir = NSHomeDirectory();
//                    libDir = [libDir stringByAppendingPathComponent:@"Library"];
//                    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
//                    NSData *data = [NSData dataWithContentsOfURL:responseObject];
//                    NSString *path = [NSString stringWithFormat:@"%@/%@",dbDirectoryPath,model.body.fileName];
//                    [data writeToFile:path atomically:YES];
//                    
//                    model.localPath = path;
//                    [self.tableView reloadData];
//                } else {
//                    
//                }
//            }];
        }
    }

}

- (void)newChatMesassage:(NSNotification*)notification
{
    NSArray *msgs = notification.object;
    for (NSDictionary *msg in msgs) {
        MessageModel *message = [[MessageModel alloc] initWithDictionary:msg];
        message.status = kefuMessageDeliveryState_Delivered;
        NSString *fromUser = [msg objectForKey:@"fromUser"];
        if (fromUser) {
            if (![[fromUser valueForKey:@"userId"] isEqualToString:_userModel.userId]) {
                return;
            }
            if ([[fromUser valueForKey:@"userId"] isEqualToString:[HDClient sharedClient].currentAgentUser.userId]) {
                message.isSender = YES;
            } else {
                message.isSender = NO;
            }
            
            if (message.body) {
                message.body.content = [ConvertToCommonEmoticonsHelper convertToSystemEmoticons:message.body.content];
            }
            if (![_msgDic objectForKey:message.messageId]) {
                [_msgDic setObject:@"" forKey:message.messageId];
                [self downloadMessageAttachments:message];
                [self addMessage:message];
            }
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
