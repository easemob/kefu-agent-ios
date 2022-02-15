//
//  AgoraViewController.m
//  CustomerSystem-ios
//
//  Created by houli on 2022/1/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "HDAgoraCallViewController.h"
#import "HDCallViewCollectionViewCell.h"
#import "HDAgoraCallOptions.h"
#import "HDAgoraCallMember.h"
#import <ReplayKit/ReplayKit.h>
#import "HDAgoraCallManager.h"
#define kCamViewTag 100001
#define kScreenShareExtensionBundleId @"com.easemob.enterprise.demo.customer.shareWindow"
#define kNotificationShareWindow kScreenShareExtensionBundleId
@interface HDAgoraCallViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,HDAgoraCallManagerDelegate>
{
    NSMutableArray *_members; // 通话人
    NSTimer *_timer;
    NSInteger _time;
    NSTimer *_waitTimer;
    NSInteger _num;
    HDCallViewCollectionViewCellItem *_currentItem;
    NSUInteger _localUid;
    
}
@property (nonatomic, strong) NSString *agentName;
@property (nonatomic, strong) NSString *avatarStr;
@property (nonatomic, strong) NSString *nickname;
@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *callingView; // 通话中展示的view
@property (weak, nonatomic) IBOutlet UIView *callinView;  // 呼入时展示的view

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;  // 正在通话中...(人数)
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;  // 时间 00:00:00

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView; // 显示头像

@property (weak, nonatomic) IBOutlet UIButton *camBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareDeskTopBtn;
@property (weak, nonatomic) IBOutlet UIButton *screenBtn;
@property (weak, nonatomic) IBOutlet UIButton *hiddenBtn;
@property (weak, nonatomic) IBOutlet UIButton *offBtn;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (nonatomic, strong) RPSystemBroadcastPickerView *broadPickerView API_AVAILABLE(ios(12.0));
@property (nonatomic, assign) HDCallAlertType type;



@property (nonatomic, strong) UIView *localView;
@end

@implementation HDAgoraCallViewController

+ (HDAgoraCallViewController *)hasReceivedCallWithAgentName:(NSString *)aAgentName
                                             avatarStr:(NSString *)aAvatarStr
                                              nickName:(NSString *)aNickname
                                        hangUpCallBack:(HangAgroaUpCallback)callback{
    HDAgoraCallViewController *callVC = [[HDAgoraCallViewController alloc]
                                    initWithNibName:@"HDAgoraCallViewController"
                                    bundle:nil];
    callVC.agentName = aAgentName;
    callVC.avatarStr = aAvatarStr;
    callVC.nickname = aNickname;
    callVC.hangUpCallback = callback;
    return callVC;
}

+ (HDAgoraCallViewController *)hasReceivedCallWithAgentName:(NSString *)aAgentName
                                             avatarStr:(NSString *)aAvatarStr
                                              nickName:(NSString *)aNickname {
    HDAgoraCallViewController *callVC = [[HDAgoraCallViewController alloc]
                                    initWithNibName:@"HDAgoraCallViewController"
                                    bundle:nil];
    callVC.agentName = aAgentName;
    callVC.avatarStr = aAvatarStr;
    callVC.nickname = aNickname;
         
    return callVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _localUid= 12344;
    // 监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleStatusBarOrientationChange)
                                                name:UIApplicationDidChangeStatusBarOrientationNotification
                                              object:nil];

    // 初始化数据源
    _members = [NSMutableArray array];
    [self setAgoraVideo];
    // 设置 ui
    [self.collectionView reloadData];
    
    [self updateInfoLabel]; // 尝试更新“正在通话中...(n)”中的n。
    [self initBroadPickerView];
    [self  addNotifications];
    [self setupCollectionView];
    // 设置选中 collectionView 第一项
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    [self startTimer];
    
    //加入房间等待访客进入
    [[HDAgoraCallManager shareInstance] hd_joinCallWithNickname:@"123" completion:^(id obj, HDError *  error) {
        if (error == nil) {
        
            //加入成功  发消息 给 访客 进行视频邀请
            
        }
        
    }];
    
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [[HDAgoraCallManager shareInstance] endCall];
    [[HDAgoraCallManager shareInstance] destroy];
}

- (void)setAgoraVideo{
    // 设置音视频 options
    HDAgoraCallOptions *options = [[HDAgoraCallOptions alloc] init];
    options.videoOff = NO; // 这个值要和按钮状态统一。
    options.mute = NO; // 这个值要和按钮状态统一。
    options.shareUid = 1234; //屏幕分享uid 不设置 走默认
    options.uid = _localUid; // 不设置 走随机 uid 最好设置用户自己登陆后的uid
    NSDictionary * dic = @{ @"call_agoraToken":@"call_agoraToken",@"call_agoraChannel":@"call_agoraChannel",@"call_agoraAppid":@"call_agoraAppid"};
//    options.extension =dic;
    [[HDAgoraCallManager shareInstance] setCallOptions:options];
    //add local render view
    [self  addLocalSessionWithUid:options.uid];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 添加监听
    [[HDAgoraCallManager shareInstance] addDelegate:self delegateQueue:nil];
}


///  添加本地视频流
/// @param localUid   本地用户id
- (void)addLocalSessionWithUid:(NSInteger )localUid{
//    // 设置第一个item的头像，昵称都为自己。HDCallViewCollectionViewCellItem 界面展示类
    HDCallViewCollectionViewCellItem *item = [[HDCallViewCollectionViewCellItem alloc] initWithAvatarURI:@"url" defaultImage:[UIImage imageNamed:self.avatarStr] nickname:self.nickname];
    item.isSelected = YES; // 默认自己会被选中
    item.uid = localUid;
    UIView * localView = [[UIView alloc] init];
    item.camView = localView;
    //设置本地试图
    [[HDAgoraCallManager shareInstance] setupLocalVideoView:item.camView];
    //添加数据源
    [_members addObject:item];
}
- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *cellNib = [UINib nibWithNibName:@"HDCallViewCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cellid"];
}
// 监听屏幕方向变化
- (void)handleStatusBarOrientationChange {

}
// 根据HDCallMember 创建cellItem
- (HDCallViewCollectionViewCellItem *)createCallerWithMember2:(HDAgoraCallMember *)aMember {
    UIView * remoteView = [[UIView alloc] init];
    HDCallViewCollectionViewCellItem *item = [[HDCallViewCollectionViewCellItem alloc] initWithAvatarURI:aMember.extension[@"avatarUrl"] defaultImage:[UIImage imageNamed:@"default_customer_avatar"] nickname:aMember.extension[@"nickname"]];
    item.uid = [aMember.memberName integerValue];
    item.camView = remoteView;
    //设置远端试图
    [[HDAgoraCallManager shareInstance]  setupRemoteVideoView:item.camView withRemoteUid:item.uid];
    return item;
}
// 更新详情显示
- (void)updateInfoLabel {
    
    if (_members.count >= 2) {
        if (_waitTimer) {
            [_waitTimer invalidate];
            _waitTimer = nil;
        }
        self.infoLabel.text = [NSString stringWithFormat:@"正在通话中...(%d)",(int)_members.count];
    }else{
        //判断 访客有没有加入
        if (_num > 2) {
            _num = 0;
        }
        NSArray *array = @[@".",@"..",@"..."];
        self.infoLabel.text = [NSString stringWithFormat:@"等待访客加入中%@",array[_num]];
        _num++;
    }
}
#pragma mark - 初始化

+(id)alertWithView:(UIView *)view AlertType:(HDCallAlertType)type;
{
    HDAgoraCallViewController *alertVC = [[HDAgoraCallViewController alloc]
                                       initWithNibName:@"HDAgoraCallViewController"
                                       bundle:nil];
    alertVC.type = type;
    alertVC.view = view;
    return alertVC;
}
+ (id)alertLoginWithView:(UIView *)view{
    
    return [HDAgoraCallViewController alertWithView:view AlertType:HDCallAlertTypeVideo];
    
}
- (void)showView{
    if (self.view.hidden) {
        NSLog(@"view 是隐藏状态");
        self.view.hidden = NO;
    }else{
        NSLog(@"view 是其他状态");
        UIWindow *window = [UIApplication sharedApplication].keyWindow ;
        self.view.frame = [UIScreen mainScreen].bounds;
        [window  addSubview:self.view];
    }
}
- (void)hideView{
    self.view.hidden = YES;
}

/// 初始化屏幕分享view
- (void)initBroadPickerView{
    if (@available(iOS 12.0, *)) {
        _broadPickerView = [[RPSystemBroadcastPickerView alloc] init];
        _broadPickerView.preferredExtension = kScreenShareExtensionBundleId;
    } else {
        // Fallback on earlier versions
    }
}

// 切换摄像头事件
- (IBAction)camBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    [[HDAgoraCallManager shareInstance]  switchCamera];
}

// 静音事件
- (IBAction)muteBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [[HDAgoraCallManager shareInstance]  pauseVoice];
    } else {
        [[HDAgoraCallManager shareInstance]  resumeVoice];
    }
}

// 停止发送视频流事件
- (IBAction)videoBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    UIView *selfView = [_members.firstObject camView];
    if (btn.selected) {
        [[HDAgoraCallManager shareInstance]  pauseVideo];
    } else {
        [[HDAgoraCallManager shareInstance]  resumeVideo];
    }
    selfView.hidden = btn.selected;
}

// 扬声器事件
- (IBAction)speakerBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    [[HDAgoraCallManager shareInstance]  setEnableSpeakerphone:btn.selected];
}

// 屏幕共享事件
- (IBAction)shareDesktopBtnClicked:(UIButton *)btn {
    for (UIView *view in _broadPickerView.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            //调起录像方法，UIControlEventTouchUpInside的方法看其他文章用的是UIControlEventTouchDown，
            //我使用时用UIControlEventTouchUpInside用好使，看个人情况决定
            [(UIButton*)view sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}
- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    UIView * view = [self.view viewWithTag:kCamViewTag];
    CGRect frame = self.videoView.frame;
    view.frame = self.screenBtn.selected ? UIScreen.mainScreen.bounds : frame;
}
// 切换屏幕尺寸事件
- (IBAction)screenBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    UIView * view = [self.view viewWithTag:kCamViewTag];
    CGRect frame = self.videoView.frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    view.frame = self.screenBtn.selected ? UIScreen.mainScreen.bounds : frame;
    [UIView commitAnimations];
}

// 隐藏按钮事件
- (IBAction)hiddenBtnClicked:(UIButton *)btn
{
    
    [self hideView];
}

// 挂断事件
- (IBAction)offBtnClicked:(id)sender
{
    //挂断和拒接 都走这个
    [[HDAgoraCallManager shareInstance]  endCall];
    [self stopTimer];
    if (self.hangUpCallback) {
        self.hangUpCallback(self, self.timeLabel.text);
    }
}
// 应答事件
- (IBAction)anwersBtnClicked:(id)sender {
    [self.callinView setHidden:YES];
    [self.infoLabel setHidden:NO];
    [self.callingView setHidden:NO];
    
    [self setupCollectionView];
    [self updateInfoLabel];
    // 设置选中 collectionView 第一项
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    
    [self.timeLabel setHidden:NO];
    [self startTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
    });
    if (self.hangUpCallback) {
        self.hangUpCallback(self, self.timeLabel.text);
    }

}


// 开始计时
- (void)startTimer {
    _time = 0;
    _num = 0;
    _timer = [NSTimer timerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateTime)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    
    _waitTimer = [NSTimer timerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updateInfoLabel)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_waitTimer forMode:NSRunLoopCommonModes];
    
}

- (void)updateTime {
    _time++;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",_time / 3600, (_time % 3600) / 60, _time % 60];
    
}

// 停止计时
- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HDCallViewCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.item = _members[indexPath.section];
    
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _members.count ? _members.count : 0 ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[self.view viewWithTag:kCamViewTag] removeFromSuperview];
    HDCallViewCollectionViewCellItem *item = [_members objectAtIndex:indexPath.section];
    _currentItem = item;
    UIView *view = item.camView;
    view.tag = kCamViewTag;
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
    
    
    HDCallViewCollectionViewCell *cell = (HDCallViewCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.smallView addSubview:view];
    [cell selected];
}

#pragma mark - Call
// 成员加入回调
- (void)onMemberJoin:(HDAgoraCallMember *)member {
    // 有 member 加入，添加到datasource中。
        @synchronized(_members){
            BOOL isNeedAdd = YES;
            for (HDCallViewCollectionViewCellItem *item in _members) {
                if (item.uid  == [member.memberName integerValue] ) {
                    isNeedAdd = NO;
                    break;
                }
            }
            if (isNeedAdd) {
                [_members addObject: [self createCallerWithMember2:member]];
            }
        };
        [self.collectionView reloadData];
        [self updateInfoLabel];
}

// 成员离开回调
- (void)onMemberExit:(HDAgoraCallMember *)member {
    // 有 member 离开，清理datasource
    // 如果移除的是当前显示的客服
    if (_currentItem.uid == [member.memberName integerValue]) {
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    }
    HDCallViewCollectionViewCellItem *deleteItem;
    for (HDCallViewCollectionViewCellItem *item in _members) {
        if (item.uid == [member.memberName integerValue]) {
            deleteItem = item;
            break;
        }
    }
    if (deleteItem) {
        [_members removeObject:deleteItem];
        [[HDAgoraCallManager shareInstance]  setupRemoteVideoView:deleteItem.camView withRemoteUid:deleteItem.uid];
        [self.collectionView reloadData];
        [self updateInfoLabel];
    }
}
// 坐席主动 挂断 结束回调
- (void)onCallEndReason:(int)reason desc:(NSString *)desc {
    [self stopTimer];
    if (self.hangUpCallback) {
        self.hangUpCallback(self, self.timeLabel.text);
    }
}

#pragma mark - HDAgoraCallManagerDelegate
/// 加入声网 返回的错误码 判断 加入失败 依据
- (void)hd_rtcEngine:(HDAgoraCallManager *)agoraCallManager didOccurError:(HDError *)error{
    
    NSLog(@"Occur error%d",error.code);
}

#pragma mark - 进程间通信-CFNotificationCenterGetDarwinNotifyCenter 使用之前，需要为container app与extension app设置 App Group，这样才能接收到彼此发送的进程间通知。
void NotificationCallback(CFNotificationCenterRef center,
                                   void * observer,
                                   CFStringRef name,
                                   void const * object,
                                   CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    NSObject *sender = (__bridge NSObject *)observer;
    //NSDictionary *info = (__bridge NSDictionary *)userInfo;
//    NSDictionary *info = CFBridgingRelease(userInfo);
    NSDictionary *notiUserInfo = @{@"identifier":identifier};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShareWindow
                                                        object:sender
                                                      userInfo:notiUserInfo];
}
- (void)addNotifications {
    [self registerNotificationsWithIdentifier:@"broadcastStartedWithSetupInfo"];
    [self registerNotificationsWithIdentifier:@"broadcastPaused"];
    [self registerNotificationsWithIdentifier:@"broadcastResumed"];
    [self registerNotificationsWithIdentifier:@"broadcastFinished"];
    [self registerNotificationsWithIdentifier:@"processSampleBuffer"];
    //这里同时注册了分发消息的通知，在宿主App中使用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationAction:) name:kNotificationShareWindow object:nil];
}

- (void)registerNotificationsWithIdentifier:(nullable NSString *)identifier{
    CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
    CFStringRef str = (__bridge CFStringRef)identifier;
   
    CFNotificationCenterAddObserver(center,
                                    (__bridge const void *)(self),
                                    NotificationCallback,
                                    str,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}
- (void)NotificationAction:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    NSString *identifier = userInfo[@"identifier"];
    
    if ([identifier isEqualToString:@"broadcastStartedWithSetupInfo"]) {
        
        self.shareDeskTopBtn.selected =YES;
        
        NSLog(@"broadcastStartedWithSetupInfo");
    }
    if ([identifier isEqualToString:@"broadcastPaused"]) {
        NSLog(@"broadcastPaused");
    }
    if ([identifier isEqualToString:@"broadcastResumed"]) {
        NSLog(@"broadcastResumed");
    }
    if ([identifier isEqualToString:@"broadcastFinished"]) {
        
        //更改按钮的状态
        self.shareDeskTopBtn.selected =NO;
        
        NSLog(@"broadcastFinished");
    }
    if ([identifier isEqualToString:@"processSampleBuffer"]) {
        NSLog(@"processSampleBuffer");
    }
}

@end
