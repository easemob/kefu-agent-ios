//
//  CallViewController.m
//  HLtest
//
//  Created by houli on 2022/3/4.
//

#import "HDVECViewController.h"
#import "HDVECControlBarView.h"
#import "HDVECMiddleVideoView.h"
#import "HDVECSmallWindowView.h"
#import "HDVECTitleView.h"
#import "Masonry.h"
#import "HDVECCallCollectionViewCellItem.h"
#import <ReplayKit/ReplayKit.h>
#import "HDVECAgoraCallManager.h"
#import "HDVECAgoraCallManagerDelegate.h"
#import "HDVECPopoverViewController.h"
#import "HDVECItemView.h"
#import "HDAppSkin.h"
#import "HDVECHiddenView.h"
#import "HDWhiteBoardView.h"
#import "HDUploadFileViewController.h"
#import "HDWhiteRoomManager.h"
#import "MBProgressHUD+Add.h"
#import "UIViewController+AlertController.h"
#import "UIImageView+EMWebCache.h"
#import "HDVECScreeShareManager.h"
#define kLocalUid 1111111 //设置真实的本地的uid
#define kLocalWhiteBoardUid 222222 //设置虚拟白板uid
#define kCamViewTag 100001

#define kPointHeight [UIScreen mainScreen].bounds.size.width *0.9


@interface HDVECViewController ()<HDVECAgoraCallManagerDelegate,HDCallManagerDelegate,HDOnlineWhiteboardManagerDelegate,UIPopoverPresentationControllerDelegate,HDVECSuspendCustomViewDelegate,HDClientDelegate>{
    
    UIView *_changeView;
    NSMutableArray * _videoItemViews;
    NSMutableArray * _videoViews;
    NSMutableArray * _tmpArray;
    
    
    NSMutableArray *_members; // 通话人小窗
    NSMutableArray *_midelleMembers; // 通话人中间窗口
    NSTimer *_timer;
    NSInteger _time;
    HDVECCallCollectionViewCellItem *_currentItem; //中间窗口的item 对象
    BOOL isCalling; //是否正在通话
    NSString * _thirdAgentNickName;
    NSString * _thirdAgentUid;
    
    NSString * _isFirstAdd; // 远端进来是不是第一次添加
    
    UIButton *_cameraBtn;
    UIButton *_shareBtn;     //屏幕共享的button
    UIButton *_whiteBoardBtn;     //白板的button
    BOOL _cameraState; //摄像头状态； yes 开启摄像头 no 关闭
    BOOL _shareState; //屏幕共享状态； yes 正在共享 no 没有共享
    
    NSMutableDictionary *  allMembersDic; // 全局数据存储
    
    MBProgressHUD *_hud;
    
    UIView * _closeBgview;
    CGFloat viewWidth;
    CGFloat viewHeight;
    
    BOOL _isVEC; //是否使用vec 流程界面
//    BOOL _isDeviceFront; //是否是前置摄像头
    

}
/*
 * 弹窗窗口
 */
@property (strong, nonatomic) UIWindow *alertWindow;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, strong) NSString *agentName;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarStr;
@property (nonatomic, strong) HDKeyCenter *keyCenter;

@property (nonatomic, strong) HDVECControlBarView *barView;
@property (nonatomic, strong) HDVECMiddleVideoView *midelleVideoView;
@property (nonatomic, strong) HDVECSmallWindowView *smallWindowView;
@property (nonatomic, strong) HDVECTitleView *hdTitleView;
@property (nonatomic, strong) HDVECItemView *itemView;
@property (nonatomic, strong) HDVECHiddenView *hidView;
@property (nonatomic, assign) BOOL  isLandscape;//当前屏幕 是横屏还是竖屏
@property (strong, nonatomic) HDVECPopoverViewController *buttonPopVC;
@property (nonatomic, strong) HDWhiteBoardView *whiteBoardView;
@property (nonatomic, assign) BOOL  isSmallWindow;//当前是不是 半屏模式
@property (nonatomic, strong) UIWindow *customWindow;
@property (nonatomic, strong) HDVECSuspendCustomView *hdSupendCustomView;

//vec 测试截图
@property (nonatomic, strong) UIButton *vec_screenBtn;
@property (nonatomic, strong) UIImageView *vec_screenImageView;


@end
static dispatch_once_t onceToken;
 
static HDVECViewController *_manger = nil;
@implementation HDVECViewController

#pragma mark- 单利
 
/** 单利创建
 */
+ (instancetype)sharedManager
{
    dispatch_once(&onceToken, ^{
        _manger = [[HDVECViewController alloc] init];
        _manger.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _manger.alertWindow.windowLevel = 0.0;
        _manger.alertWindow.backgroundColor = [UIColor clearColor];
        _manger.alertWindow.rootViewController = [UIViewController new];
        _manger.alertWindow.accessibilityViewIsModal = YES;
        [_manger.alertWindow makeKeyAndVisible];
        _manger.view.frame = [UIScreen mainScreen].bounds;
        [_manger.alertWindow  addSubview:_manger.view];
    });
    return _manger;
}
 
/** 单利销毁
*/
 
- (void)removeSharedManager
{
    /**只有置成0，GCD才会认为它从未执行过。它默认为0。
     这样才能保证下次再次调用sharedManager的时候，再次创建对象。*/
    onceToken= 0;
    [_manger removeAllSubviews];
    _manger.alertWindow = nil;
    _manger=nil;
    [self cancelWindow];
    [HDAppManager shareInstance].isAnswerView = NO;
}
- (void)removeAllSubviews {
    while (_manger.alertWindow.subviews.count) {
        UIView* child = _manger.alertWindow.subviews.lastObject;
        [child removeFromSuperview];
    }
}

+(id)alertWithView:(UIView *)view AlertType:(HDVECNewCallAlertType)type
{
    HDVECViewController *callVC = [[HDVECViewController alloc] init];
    return callVC;
}
+ (id)alertCallWithView:(UIView *)view{
   
    return [HDVECViewController alertWithView:view AlertType:HDVECNewCallAlertTypeVideo];
    
}
- (void)vec_showViewWithKeyCenter:(HDVECRingingCallModel *)model
{
    
    if (!isCalling) {
         
        [HDVECAgoraCallManager shareInstance].ringingCallModel = model;
        //初始化 坐席加入房间参数
        [[HDVECAgoraCallManager shareInstance] vec_createTicketDidReceiveAgoraInit];
        //坐席昵称
        self.nickname = model.agentUserNiceName;
        //访客昵称
        self.agentName = model.visitorUserName;
        //点击应答
        [self anwersBtnClicked:nil];
    }
}


- (void)hideView{
    if (self&&self.view) {
        self.view.hidden = YES;
    }
}
- (void)removeView{
   
    [self.view removeFromSuperview];
    self.view = nil;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[HDAppSkin mainSkin] contentColorBlockalpha:0.6];
    [self.view hideKeyBoard];
    _cameraState = YES;
    // 用于添加语音呼入的监听 onCallReceivedNickName:
    [HDClient.sharedClient.callManager addDelegate:self delegateQueue:nil];
    [HDClient.sharedClient.whiteboardManager addDelegate:self delegateQueue:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableDidSelected:) name:@"click" object:nil];
    self.isLandscape = NO;
    _videoViews = [NSMutableArray new];
    _videoItemViews = [NSMutableArray new];
    _members = [NSMutableArray new];
    _midelleMembers = [NSMutableArray new];
    allMembersDic = [NSMutableDictionary new];
    //注册屏幕共享通知
    [self registScreenShare];
}
//
-(void)clearViewData{
    [_videoViews removeAllObjects];
    [_videoItemViews removeAllObjects];
    [_members removeAllObjects];
    [_midelleMembers removeAllObjects];
    [allMembersDic removeAllObjects];
    [self.parentView removeFromSuperview];
    self.parentView = nil;
    self.barView = nil;
    self.midelleVideoView= nil;
    self.hdTitleView = nil;
    self.smallWindowView=nil;
    self.whiteBoardView =nil;
    self.view.backgroundColor = [[HDAppSkin mainSkin] contentColorBlockalpha:0.6];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view hideKeyBoard];
}

-(void)initData{
    HDVECControlBarModel * barModel = [HDVECControlBarModel new];
    barModel.itemType = HDControlBarItemTypeMute;
    barModel.name=@"";
    barModel.imageStr= kmaikefeng1 ;
    barModel.selImageStr= kjinmai;
    
    HDVECControlBarModel * barModel1 = [HDVECControlBarModel new];
    barModel1.itemType = HDControlBarItemTypeVideo;
    barModel1.name=@"";
    barModel1.imageStr= kshexiangtou1 ;
    barModel1.selImageStr=kguanbishexiangtou1;
    
    HDVECControlBarModel * barModel2 = [HDVECControlBarModel new];
    barModel2.itemType = HDControlBarItemTypeHangUp;
    barModel2.name=@"";
    barModel2.imageStr=kguaduan1;
    barModel2.selImageStr=kguaduan1;
    barModel2.isHangUp = YES;
    
    HDVECControlBarModel * barModel3 = [HDVECControlBarModel new];
    barModel3.itemType = HDControlBarItemTypeShare;
    barModel3.name=@"";
    barModel3.imageStr=kpingmugongxiang2;
    barModel3.selImageStr=kpingmugongxiang2;
    
    HDVECControlBarModel * barModel4 = [HDVECControlBarModel new];
    barModel4.itemType = HDControlBarItemTypeFlat;
    barModel4.name=@"";
    barModel4.imageStr=kbaiban;
    barModel4.selImageStr=kbaiban;
    
    NSMutableArray * selImageArr = [NSMutableArray arrayWithObjects:barModel,barModel1,barModel2, nil];
    
    HDGrayModel * grayModelWhiteBoard =  [[HDCallManager shareInstance] getGrayName:@"whiteBoard"];
    HDGrayModel * grayModelShare =  [[HDCallManager shareInstance] getGrayName:@"shareDesktop"];
    if (grayModelShare.enable) {
        
        if (@available(iOS 12.0, *)) {
        
            [selImageArr addObject:barModel3];
            
        }
        
        
    }
    if (grayModelWhiteBoard.enable) {
        [selImageArr addObject:barModel4];
    }

   [self.barView hd_buttonFromArrBarModels:selImageArr view:self.barView withButtonType:HDControlBarButtonStyleVideo] ;
    
    [self initSmallWindowData];
}
- (void)initSmallWindowData{
    
    //初始化本地view
    [self addLocalSessionWithUid:kLocalUid];
    
    [self.smallWindowView setItemData:_members];
    
}
/// 接收视频通话后 设置本地view
- (void)setAcceptCallView{
    [HDVECAgoraCallManager shareInstance].roomDelegate = self;
    [self setAgoraVideo];
//    _isDeviceFront = YES;
}

- (void)setAgoraVideo{
    // 设置音视频 options
    HDVECAgoraCallOptions *options = [[HDVECAgoraCallOptions alloc] init];
    [[HDVECAgoraCallManager shareInstance] setCallOptions:options];
    //add local render view
    [self addLocalSessionWithUid:kLocalUid];//本地用户的id demo 切换的时候 有根据uid 判断 传入的时候尽量避免跟我们远端用户穿过来的相同
    [UIApplication sharedApplication].idleTimerDisabled = YES;

}
///  添加本地视频流
/// @param localUid   本地用户id
- (void)addLocalSessionWithUid:(NSInteger )localUid{
//    // 设置第一个item的头像，昵称都为自己。HDCallViewCollectionViewCellItem 界面展示类
    HDVECCallCollectionViewCellItem *item = [[HDVECCallCollectionViewCellItem alloc] init];
    item.isSelected = YES; // 默认自己会被选中
    item.isMute = !_cameraState; //这个地方需要注意 默认 是需要选中 红色 所以这个地方跟默认取个反 
    item.nickName = self.nickname;
    item.uid = localUid;
    UIView * localView = [[UIView alloc] init];
    item.camView = localView;
    [[HDVECAgoraCallManager shareInstance] setupLocalVideoView:item.camView];
    //添加数据源
    [_members addObject:item];
    
    //默认进来 中间窗口显示 坐席头像
    [self.itemView setItemString:self.agentName];
    
}
// 根据HDCallMember 创建cellItem
- (HDVECCallCollectionViewCellItem *)createCallerWithMember2:(HDVECAgoraCallMember *)aMember withView:(UIView *)view {
    NSLog(@"join 成员加入回调- 根据HDCallMember 创建cellItem--- %@ ",aMember.memberName);
    HDVECCallCollectionViewCellItem *item = [[HDVECCallCollectionViewCellItem alloc] init];
    item.nickName = aMember.agentNickName;
    item.uid = [aMember.memberName integerValue];
    item.camView =view;
//    item.camView = retomView;
    //远端第一次进来 添加中间窗口初始化view
    if (_videoViews.count == 0) {
        [_videoViews addObject:item];
    }
    //设置远端试图
    [[HDVECAgoraCallManager shareInstance] setupRemoteVideoView:item.camView withRemoteUid:item.uid];
    return item;
}
// 坐席主动 挂断 结束回调
- (void)onCallEndReason:(int)reason desc:(NSString *)desc withRecordData:(id)result{
    [self.hdTitleView stopTimer];
    isCalling = NO;
    [[HDWhiteRoomManager shareInstance] hd_OnLogout];
    dispatch_async(dispatch_get_main_queue(), ^{
//        UI更新代码
        if (self.vechangUpCallback) {
            self.vechangUpCallback(self, self.hdTitleView.timeLabel.text);
        }
    });
   
}
- (void)onCallReceivedInvitation:(NSString *)thirdAgentNickName withUid:(NSString *)uid{
    
    _thirdAgentNickName = thirdAgentNickName;
    _thirdAgentUid = uid;
    
    [self updateThirdAgent];
}
- (void)updateThirdAgent{
   
    if (_thirdAgentNickName.length > 0) {
    [self.smallWindowView.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           NSLog(@"%@----%@",self.smallWindowView.items[idx],[NSThread currentThread]);
        HDVECCallCollectionViewCellItem *item = obj;
        if (item.uid == [_thirdAgentUid integerValue]) {
            item.nickName = _thirdAgentNickName;
            [self.smallWindowView setAudioMuted:item];
        }
    }];

//    [self.collectionView reloadData];
    }
}

//-(void)addSubView{
//    //顶部 title
//    [self.view addSubview:self.hdTitleView];
//    //中间小窗
//    [self.view addSubview:self.smallWindowView];
//    //中间打窗口
//    [self.view addSubview:self.midelleVideoView];
//    //底部view
//    [self.view addSubview:self.barView];
//
//    //添加昵称信息
//    [self.view addSubview:self.itemView];
//    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.barView.mas_top).offset(-5);
//        make.leading.offset(0);
//        make.trailing.offset(0);
//        make.height.offset(44);
//
//    }];
//
//}
-(void)addSubView{
    [self.view addSubview: self.parentView];
    [self.parentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.offset(0);
        make.bottom.offset(0);
        make.leading.offset(0);
        make.trailing.offset(0);
        
    }];
    //顶部 title
    [self.parentView addSubview:self.hdTitleView];
    //中间小窗
    [self.parentView addSubview:self.smallWindowView];
    //中间打窗口
    [self.parentView addSubview:self.midelleVideoView];
    //底部view
    [self.parentView addSubview:self.barView];
    
    //添加昵称信息
    [self.parentView addSubview:self.itemView];
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.barView.mas_top).offset(-5);
        make.leading.offset(5);
        make.trailing.offset(-5);
        make.height.offset(44);
        
    }];
    
}
#pragma mark - 屏幕翻转就会调用
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        //计算旋转之后的宽度并赋值
        CGSize screen = [UIScreen mainScreen].bounds.size;
        //动画播放完成之后
        if(screen.width > screen.height){
            NSLog(@"横屏");
            [self updateCustomViewFrame:screen withScreen:YES];
        }else{
            NSLog(@"竖屏");
            [self updateCustomViewFrame:screen withScreen:NO];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        NSLog(@"动画播放完之后处理");
    }];
}

-(void)updateCustomViewFrame:(CGSize)size withScreen:(BOOL)landscape{
    self.isLandscape = landscape;
    self.smallWindowView.isLandscape = landscape;
    if (landscape) {
        [self updateLandscapeLayout];
    }else{
        [self updatePorttaitLayout];
    }
}

/// 横屏布局
-(void)updateLandscapeLayout{
    
    //顶部 小窗口
    [self.smallWindowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hdTitleView.mas_bottom).offset(0);
        make.width.offset(90);
        make.trailing.offset(-10);
        make.bottom.mas_equalTo(self.barView.mas_top).offset(0);
        
    }];
    //中间 视频窗口
    [self.midelleVideoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.leading.offset(0);
        make.trailing.offset(0);
        make.bottom.offset(0);
    }];
    [self.view sendSubviewToBack:self.midelleVideoView];
    
  
    //底部 窗口
    [self.barView refreshView:self.barView withScreen:self.isLandscape];
    
}
/// 竖屏布局
-(void)updatePorttaitLayout{
    
    //顶部功能
    [self.hdTitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.leading.offset(0);
        make.trailing.offset(0);
        make.height.offset(44 + kApplicationStatusBarHeight);
    }];
  
    //底部功能按钮
    
    [self.barView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = self.view.safeAreaInsets;
            make.bottom.mas_equalTo(-insets.bottom).offset(-5);
        } else {
            // Fallback on earlier versions
            make.bottom.offset(-5);
        }
        make.leading.offset(20);
        make.trailing.offset(-20);
        make.height.offset(64);
    }];
    [self.barView layoutIfNeeded];
    
    //顶部 小窗口
    [self.smallWindowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hdTitleView.mas_bottom).offset(20);
        make.leading.offset(15);
        make.trailing.offset(0);
        make.height.offset(90);
        
    }];
    //中间 视频窗口
    [self updateBgMilldelVideoView:self.midelleVideoView whiteBoard:NO];
    //底部 窗口
    [self.barView refreshView:self.barView withScreen:self.isLandscape];
}


/// 点击 cell。更改小窗试图
/// @param item  cell 里边的model
/// @param idx  当前点击cell 的index
- (void)changeCallViewItem:(HDVECCallCollectionViewCellItem *)item withIndex:(NSInteger)idx{
    
    
    if (_shareState) {
        //当前正在共享
        [MBProgressHUD  dismissInfo:NSLocalizedString(@"当前正在共享中", "当前正在共享中") withWindow:self.alertWindow];
        return;
    }
    
    if (_videoViews.count >0) {
        //更新小窗口
        [self updateSmallVideoView:item withIndex:idx];
        //更新中间视频大窗口
        [self updateBigVideoView];
        
    }else{
        
        [MBProgressHUD  dismissInfo:NSLocalizedString(@"访客加入进来才可切换窗口哦!", "访客加入进来才可切换窗口哦!") withWindow:self.alertWindow];
        
    }
}
/// 更新小视频窗口变成大窗口。把小窗口的 item 信息 给大窗口用。然后在把大窗口的item 信息给小窗切换
-(void)updateSmallVideoView:(HDVECCallCollectionViewCellItem *)item withIndex:(NSInteger )idx{
   
    //小窗昵称变成 大窗昵称
    [self changeNickNameItem:item];
    
    [_videoItemViews removeAllObjects];
    //这个数组里边添加的是小窗口需要放到中间视频窗口的view 在传给cell 前先保存之前的view
    [_videoItemViews addObject:item];
    
    //cell 小窗口切换_videoViews 存放大窗口 信息
    HDVECCallCollectionViewCellItem * bigItem =[_videoViews firstObject];
//    UIView * tmpVideoView = smallItem.camView;
//    smallItem.camView = tmpVideoView;
    if (bigItem.isWhiteboard) {
        bigItem.camView.userInteractionEnabled = NO;
       
       
    }
//    [self.hdTitleView  modifyTextColor: [UIColor blackColor]];
//    [self.hdTitleView  modifyIconBackColor: [UIColor blackColor]];
    [self.smallWindowView setSelectCallItemChangeVideoView:bigItem withIndex:idx];

}

/// 更新大视频窗口变成小窗口）
-(void)updateBigVideoView{
    
    [_videoViews removeAllObjects];
    HDVECCallCollectionViewCellItem * smallItem = [_videoItemViews firstObject];
    UIView * videoView = smallItem.camView;
    if (smallItem.isWhiteboard) {
        videoView.userInteractionEnabled = YES;
        [self.hdTitleView  modifyTextColor: [UIColor blackColor]];
        [self.hdTitleView  modifyIconBackColor: [UIColor blackColor]];
    }
   
    
    self.midelleVideoView = (HDVECMiddleVideoView *)videoView;
    [self.parentView addSubview:videoView];
    //中间 视频窗口
    [self updateBgMilldelVideoView:videoView whiteBoard:smallItem.isWhiteboard];
    
    [_videoViews addObject:smallItem];

    //大窗昵称变成 小窗昵称
    [self changeNickNameItem:smallItem];
    
}

/// 更新大视频窗口变成小窗口）
-(void)updateBigVideoView:(HDVECCallCollectionViewCellItem *)item{
    
    if (self.parentView ==nil) {
        
        return;
    }
    [_videoViews removeAllObjects];
    UIView * videoView = item.camView;
    //中间 视频窗口

    [self updateBgMilldelVideoView:videoView whiteBoard:NO];
    [_videoViews addObject:item];

    //大窗昵称变成 小窗昵称
    [self changeNickNameItem:item];
    
}

- (void)updateBgMilldelVideoView:(UIView *)view whiteBoard:(BOOL)isjoinWhiteBoare{
    
    [view removeFromSuperview];
    
    [self.parentView addSubview:view];
    
    if (isjoinWhiteBoare) {
        //开启白板 更新页面布局
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.smallWindowView.mas_bottom).offset(44);
            make.leading.offset(0);
            make.trailing.offset(0);
            make.height.offset(kPointHeight );
        }];
        [view layoutIfNeeded];
       
    }else{

        [self.parentView sendSubviewToBack:view];
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.leading.offset(0);
                make.trailing.offset(0);
                make.bottom.offset(0);
        
        }];
        
    }
    
}


- (void)_sendMessage:(HDMessage *)aMessage
{
    
//    __weak typeof(self) weakself = self;
    
    [[HDClient sharedClient].chatManager sendMessage:aMessage
                                            progress:nil
                                          completion:^(HDMessage *message, HDError *error)
     {
        if (!error) {
        
        }
        else {
        
        }
    }];
    
}

///  控制器中大小窗昵称切换
/// @param item  获取昵称的对象
-(void)changeNickNameItem:(HDVECCallCollectionViewCellItem *)item{
    
    //大窗昵称变成 小窗昵称
    [self.itemView setItemString:item.nickName];
    
    self.itemView.muteBtn.selected = item.isMute;
    
    // 中间窗口
    item.camView.frame = self.parentView.frame;
    
    [self setMidelleMutedItem:item];
   
    
}

- (HDVECHiddenView *)hidView{
    
    if (_hidView) {
        _hidView = [[HDVECHiddenView alloc] init];
        _hidView.backgroundColor = [UIColor redColor];
    }
    return _hidView;
}


- (HDVECItemView *)itemView{
    if (!_itemView) {
        _itemView = [[HDVECItemView alloc]init];
//        _itemView.backgroundColor = [UIColor redColor];
     }
     return _itemView;
}

- (HDVECTitleView *)hdTitleView {
    if (!_hdTitleView) {
        _hdTitleView = [[HDVECTitleView alloc]init];
//        _hdTitleView.backgroundColor = [UIColor redColor];
        kWeakSelf
        _hdTitleView.clickHideBlock = ^(UIButton * _Nonnull btn) {
             
            if (btn.selected) {
                [weakSelf __enablePictureInPicture];
            }else{
                [weakSelf __cancelPictureInPicture];
            }
            
            
        };
        _hdTitleView.clickZoomBtnBlock = ^(UIButton * _Nonnull btn) {
            [weakSelf __enablePictureInPictureZoom];
           
        };
       
    }
    return _hdTitleView;
}
- (HDVECControlBarView *)barView {
    if (!_barView) {
        _barView = [[HDVECControlBarView alloc]init];
//        _barView.backgroundColor = [UIColor redColor];
        _barView.layer.cornerRadius = 10;
        _barView.layer.masksToBounds = YES;
        __weak __typeof__(self) weakSelf = self;
        _barView.clickControlBarItemBlock = ^(HDVECControlBarModel * _Nonnull barModel, UIButton * _Nonnull btn) {
            
            switch (barModel.itemType) {
                case HDControlBarItemTypeMute:
                    [weakSelf muteBtnClicked:btn];
                    break;
                case HDControlBarItemTypeVideo:
                    [weakSelf videoBtnClicked:btn];
                    break;
                case HDControlBarItemTypeHangUp:
                    [weakSelf offBtnClicked:btn];
                    break;
                case HDControlBarItemTypeShare:
                    [weakSelf shareDesktopBtnClicked:btn];
                    break;
                case HDControlBarItemTypeFlat:
                    [weakSelf onClickedFalt:btn];
                    break;
                    
                default:
                    break;
            }
            
            
        };
       
    }
    return _barView;
}
- (HDVECMiddleVideoView *)midelleVideoView {
    if (!_midelleVideoView) {
        _midelleVideoView = [[HDVECMiddleVideoView alloc]init];
    }
    return _midelleVideoView;
}
- (HDVECSmallWindowView *)smallWindowView {
    if (!_smallWindowView) {
        _smallWindowView = [[HDVECSmallWindowView alloc]init];
        __weak __typeof__(self) weakSelf = self;
        _smallWindowView.clickCellItemBlock = ^(HDVECCallCollectionViewCellItem * _Nonnull item, NSIndexPath * _Nonnull indexpath) {
            //切换逻辑
            [weakSelf changeCallViewItem:item withIndex:indexpath.item];
        };
    }
    return _smallWindowView;
}



#pragma mark - event
/// 应答事件
/// @param sender  button
- (void)anwersBtnClicked:(UIButton *)sender{
    self.view.backgroundColor = [[HDAppSkin mainSkin] contentColorWhitealpha:1];
    //应答的时候 在创建view
    //添加 页面布局
    [self addSubView];
    //默认进来调用竖屏
    [self updatePorttaitLayout];
    [self initData];
    [self setAcceptCallView];
    [self.hdTitleView startTimer];
    isCalling = YES;
    [[HDVECAgoraCallManager shareInstance] vec_acceptCallWithNickname:self.agentName
                                                        completion:^(id obj, HDError *error)
     {
        NSLog(@"===anwersBtnClicked=Occur error%d",error.code);
        if (error == nil){
            
            NSLog(@"===anwersBtnClicked=isCalling%d",error.code);
            
            dispatch_async(dispatch_get_main_queue(), ^{
               // UI更新代码
                [self.view addSubview:self.vec_screenBtn];
                [self.view addSubview:self.vec_screenImageView];
                
            });
        }else{
            NSLog(@"===anwersBtnClicked=dispatch_async%d",error.code);
            // 加入失败 或者视频网络断开
            dispatch_async(dispatch_get_main_queue(), ^{
               // UI更新代码
                if (self.vechangUpCallback) {
                    self.vechangUpCallback(self,self.hdTitleView.timeLabel.text);
                }
          
            NSLog(@"VC=Occur error%d",error.code);
            });
        }
       
     }];
}
/// 主动挂断
/// @param sender button
- (void)offBtnClicked:(UIButton *)sender{
    isCalling = NO;
    
    [[HDVECAgoraCallManager shareInstance] vec_endCall];
    //拒接事件 拒接关闭当前页面
    //挂断和拒接 都走这个
    [[HDWhiteRoomManager shareInstance] hd_OnLogout];
    
    [self.hdTitleView stopTimer];
    
    if (self.vechangUpCallback) {
        self.vechangUpCallback(self, self.hdTitleView.timeLabel.text);
    }
}

- (UIView *)parentView{
    
    if (!_parentView) {
        _parentView = [[UIView alloc] init];
    }
    
    return _parentView;
    
}

// 切换摄像头事件
- (void)camBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
    [[HDVECAgoraCallManager shareInstance] switchCamera];
//    _isDeviceFront = !_isDeviceFront;
    
}

// 静音事件
- (void)muteBtnClicked:(UIButton *)btn {
//    btn.selected = !btn.selected;
    if (btn.selected) {
        [[HDVECAgoraCallManager shareInstance] pauseVoice];
        [self updateAudioMuted:YES byUid:kLocalUid withVideoMuted:NO];
    } else {
        [[HDVECAgoraCallManager shareInstance] resumeVoice];
        
        [self updateAudioMuted:NO byUid:kLocalUid withVideoMuted:NO];
    }
    
    NSLog(@"点击了静音事件");
}

// 停止发送视频流事件
- (void)videoBtnClicked:(UIButton *)btn {
    _cameraBtn = btn;
    //默认进来判断获取摄像头状态
    //1、如果是关闭  点击直接打开摄像头
    //2、如果是开启的 点击按钮 谈窗
//        1、点击关闭摄像头  调用关闭摄像头方法 并且 更改当前btn 图片状态
//        2、点击切换摄像头  调用切换摄像头方法
    if (_cameraState) {
        //开启
          btn.selected = !btn.selected;
          [self popoverVCWithBtn:btn];
        
    }else{
        //当前摄像头关闭 需要打开
        [[HDVECAgoraCallManager shareInstance] enableLocalVideo:YES];
//        [[HDAgoraCallManager shareInstance] resumeVideo];
        _cameraState = YES;
        [self updateAudioMuted:NO byUid:kLocalUid withVideoMuted:NO];

    }
    
}
- (void)popoverVCWithBtn:(UIButton *)btn{
    NSLog(@"点击了视频事件");
    self.buttonPopVC = [[HDVECPopoverViewController alloc] init];
    self.buttonPopVC.modalPresentationStyle = UIModalPresentationPopover;
    self.buttonPopVC.popoverPresentationController.sourceView = btn;  //rect参数是以view的左上角为坐标原点（0，0）
    self.buttonPopVC.popoverPresentationController.sourceRect = btn.bounds; //指定箭头所指区域的矩形框范围（位置和尺寸），以view的左上角为坐标原点
    self.buttonPopVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp; //箭头方向
    self.buttonPopVC.popoverPresentationController.delegate = self;
    [self presentViewController:self.buttonPopVC animated:YES completion:nil];
}

///处理popover上的talbe的cell点击
- (void)tableDidSelected:(NSNotification *)notification {
    NSIndexPath *indexpath = (NSIndexPath *)notification.object;
    switch (indexpath.row) {
        case 0:
            //关闭摄像头
            [self closeCamera];
            break;
        case 1:
            //切换摄像头
            NSLog(@"====点击了切换摄像头");
            [[HDVECAgoraCallManager shareInstance] switchCamera];
            break;
    
    }
    if (self.buttonPopVC) {
        [self.buttonPopVC dismissViewControllerAnimated:YES completion:nil];    //我暂时使用这个方法让popover消失，但我觉得应该有更好的方法，因为这个方法并不会调用popover消失的时候会执行的回调。
        self.buttonPopVC = nil;
        
    }else{
      
    }
}
- (void)closeCamera{
    NSLog(@"====点击了关闭摄像头");
    _cameraState = NO;
//    _cameraBtn.selected =NO;
    //更新对应状态 设置button 照片
    _cameraBtn.selected =!_cameraBtn.selected ;
//    [[HDAgoraCallManager shareInstance] pauseVideo];
    [[HDVECAgoraCallManager shareInstance] enableLocalVideo:NO];
    // 获取
   
    [self updateAudioMuted:NO byUid:kLocalUid withVideoMuted:YES];
    
    

}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return NO;   //点击蒙版popover不消失， 默认yes
}
// 扬声器事件
- (void)speakerBtnClicked:(UIButton *)btn {
    btn.selected = !btn.selected;
//    [[HDAgoraCallManager shareInstance] setEnableSpeakerphone:btn.selected];
    NSLog(@"点击了扬声器事件");
}



#pragma mark - Call

// 成员加入回调
- (void)onMemberJoin:(HDVECAgoraCallMember *)member {
    NSLog(@"join 成员加入回调---- %@ ",member.memberName);
    // 有 member 加入，添加到datasource中。
    if (isCalling) { // 只有在已经通话中的情况下，才回去在ui加入，否则都在接听时加入。
        NSLog(@"join 成员加入回调- isCalling--- %@ ",member.memberName);
        @synchronized(_midelleMembers){
            BOOL isNeedAdd = YES;
            for (HDVECCallCollectionViewCellItem *item in _midelleMembers) {
                NSLog(@"join Member  member---- %@ ",member.memberName);
                if (item.uid  == [member.memberName integerValue] ) {
                    isNeedAdd = NO;
                    break;
                }
            }
            NSLog(@"join 成员加入回调- @synchronized for循环结束--- %@ ",member.memberName);
            if (isNeedAdd) {
                NSLog(@"join Member  isNeedAdd---- %@ ",member.memberName);
                if (_midelleMembers.count > 0) {
                    NSLog(@"join Member  _midelleMembers---- %@ ",member.memberName);
                    UIView * localView = [[UIView alloc] init];
                    HDVECCallCollectionViewCellItem * thirdItem = [self createCallerWithMember2:member withView:localView];
                    [self.smallWindowView  setThirdUserdidJoined:thirdItem];
                   
                }else{
                    NSLog(@"join Member  isNeedAdd---- %@ ",member.memberName);
                    HDVECCallCollectionViewCellItem * thirdItem = [self createCallerWithMember2:member withView:self.midelleVideoView];
                    [_midelleMembers addObject: thirdItem];
                }
            }
        };
        
        NSLog(@"join 成员加入回调- @synchronized 加入成员结束--- %@ ",member.memberName);
        [self updateThirdAgent];
     //刷新 collectionView
        [self.smallWindowView reloadData];
      
    }
}


/// 删除小窗
/// @param item
- (void)deleteSmallWindow:(NSString *)uid{
    
}
/// 删除中间
/// @param item
- (void)deleteMiddelWindow:(NSString *)uid{
    
}

// 成员离开回调
- (void)onMemberExit:(HDVECAgoraCallMember *)member {
    NSLog(@"onMemberExit Member  member---- %@ ",member.memberName);
    //先判断房间里边有没有人 如果么有人  删除界面
    if ([HDVECAgoraCallManager shareInstance].hasJoinedMembers.count ==0) {
        //退出 界面
        [self  onCallEndReason:1 desc:@"房间里没有人挂断会话" withRecordData:nil];
        return;
    }
    //先去小窗 查找 如果在小窗 有删除 刷新即可
    HDVECCallCollectionViewCellItem *deleteItem;
    
    for (HDVECCallCollectionViewCellItem *item in self.smallWindowView.items) {
        if (item.uid == [member.memberName integerValue]) {
            deleteItem = item;
            break;
        }
    }
    if (deleteItem) {
        
        [self.smallWindowView removeCurrentCellItem:deleteItem];
        [self.smallWindowView reloadData];
       
    }else{
        //说明小窗里边没有
        //如果小窗没有 那说明是 在中间窗口 那就是删除中间 小窗最后一位回到中间
        for (HDVECCallCollectionViewCellItem *item in _videoViews) {
            if (item.uid == [member.memberName integerValue]) {
                deleteItem = item;
                break;
            }
        }
        if (deleteItem) {
            [_midelleMembers removeObject:deleteItem];
            //把 小窗口 最后一个元素 拿到中间
            HDVECCallCollectionViewCellItem * samllItem =  [self.smallWindowView.items lastObject];
            
            [self updateBigVideoView:samllItem];
        
            [self.smallWindowView removeCurrentCellItem:samllItem];
            [self.smallWindowView reloadData];
        }
        
    }
    
}

/// 远端用户音频静音通知
/// @param muted  是否静音
/// @param uid  静音的用户 uid
- (void)onCalldidAudioMuted:(BOOL)muted byUid:(NSUInteger)uid{
    
    [self updateAudioMuted:muted byUid:uid withVideoMuted:NO];
    
}
- (void)onCalldidVideoMuted:(BOOL)muted byUid:(NSUInteger)uid{
    
    [self updateAudioMuted:NO byUid:uid withVideoMuted:muted];
    
}


- (void)updateAudioMuted:(BOOL)muted byUid:(NSUInteger)uid withVideoMuted:(BOOL)videoMuted{
    
    // 根据uid 找到用户 然后刷新一下界面
    BOOL  __block isSmallVindow = NO;
    [self.smallWindowView.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HDVECCallCollectionViewCellItem *item = obj;
        NSLog(@"%ld----%@",(long)item.uid,[NSThread currentThread]);
        if (item.uid == uid) {
            isSmallVindow = YES;
            NSLog(@"==uid===%lu",(unsigned long)uid);
            item.isMute = muted;
            item.isVideoMute = videoMuted;
            [self.smallWindowView setAudioMuted:item];
            *stop = YES;
        }
    }];
    
    if (!isSmallVindow) {
        //说明需要更新 中间窗口的下边的麦克风
        self.itemView.muteBtn.selected = muted;
        
        [_videoViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HDVECCallCollectionViewCellItem *item = obj;
            NSLog(@"%ld----%@",(long)item.uid,[NSThread currentThread]);
            if (item.uid == uid) {
                item.isVideoMute = videoMuted;
                item.isMute = muted;
                [self.itemView setItemString:item.nickName];
                [self  setMidelleMutedItem:item];
                *stop = YES;
            }
        }];
    }
}
- (void)setMidelleMutedItem:(HDVECCallCollectionViewCellItem *)item{
    
    if (item.isVideoMute) {
        //修改一下背景
        [item.closeCamView removeFromSuperview];
        item.closeCamView = nil;
        item.closeCamView = [[UIView alloc] initWithFrame:item.camView.frame];
        item.closeCamView.backgroundColor =  [[HDAppSkin mainSkin] contentColorGray];
    
        //添加 笑脸图片
        UIImageView * bgImgView= [[UIImageView alloc]init];
        [item.closeCamView addSubview:bgImgView];
        
        [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(item.closeCamView);
            make.centerX.mas_equalTo(item.closeCamView);
            make.width.height.offset(64);
            
        }];
        [bgImgView layoutIfNeeded];
        UIImage * img = [UIImage imageWithIcon:kXiaolian inFont:kfontName size:bgImgView.size.width color:[[HDAppSkin mainSkin] contentColorGray1] ];
        bgImgView.image = img;
        
        [item.camView addSubview:item.closeCamView];
        [self.hdTitleView  modifyTextColor: [UIColor blackColor]];
        [self.hdTitleView  modifyIconBackColor: [UIColor blackColor]];
    }else{
        if (item.isWhiteboard) {
            [self.hdTitleView  modifyTextColor: [UIColor blackColor]];
            [self.hdTitleView  modifyIconBackColor: [UIColor blackColor]];
        }else{
        [self.hdTitleView  modifyTextColor: [UIColor whiteColor]];
        [self.hdTitleView  modifyIconBackColor: [UIColor whiteColor]];
        }
        [item.closeCamView removeFromSuperview];

    }
    
}

#pragma mark -  互动白板 相关

//接收cmd 消息过来
- (void)onRoomDataReceivedParameter:(NSDictionary *)roomData{
    [[HDWhiteRoomManager shareInstance] hd_setValueFrom:roomData];
    //互动白板加入成功以后 屏幕共享 不能使用 不能创建白板房间
    if (_videoViews.count == 0) {
        return;
    }
    if (_shareState) {
        //当前正在共享
        return;
    }
    _hud = [MBProgressHUD showMessag:NSLocalizedString(@"加入房间中..", @"加入房间中..") toView:nil];
    [self updateBgMilldelVideoView:self.whiteBoardView whiteBoard:YES];

    [_hud hideAnimated:YES];
}


// 互动白板
- (void)onClickedFalt:(UIButton *)sender
{
    if (_shareState) {
        //当前正在共享
        //当前正在白板房间
        _whiteBoardBtn.selected = !_shareState;
        [MBProgressHUD  dismissInfo:NSLocalizedString(@"video_call_whiteBoard_not_shareScreen", "当前正在屏幕共享中不能进行白板")  withWindow:self.alertWindow];
        return;
    }
    _whiteBoardBtn = sender;
    if ([HDWhiteRoomManager shareInstance].roomState) {
        
        return;
    }
    // 创建白板产生
    [[HDWhiteRoomManager shareInstance] hd_joinRoom];
    
}
- (void)onFastboardDidJoinRoomFail{
    
    [_hud hideAnimated:YES];
    NSLog(@"===========加入失败");
    
    [self.whiteBoardView removeFromSuperview];
}
- (void)onFastboardDidJoinRoomSuccess{
    [_hud hideAnimated:YES];
    self.whiteBoardView.hidden = NO;
    //只有加入成功才会替换
    HDVECCallCollectionViewCellItem  * midelleViewItem =  [_videoViews firstObject];
    [self.smallWindowView setThirdUserdidJoined:midelleViewItem];
    [self.smallWindowView reloadData];
    
    HDVECCallCollectionViewCellItem *item = [[HDVECCallCollectionViewCellItem alloc] init];
    item.uid = kLocalWhiteBoardUid;
    item.realUid = kLocalUid;
    [HDWhiteRoomManager shareInstance].uid = [NSString stringWithFormat:@"%ld",(long)item.realUid];
    item.isWhiteboard = YES;
    item.nickName = @"白板";
    item.camView = self.whiteBoardView;
    
    //先取出中间试图的model 放到 小窗口  然后把白板的试图放到中间窗口
    [_videoViews replaceObjectAtIndex:0 withObject:item];
    [self changeNickNameItem:item];
    _whiteBoardBtn.selected = [HDWhiteRoomManager shareInstance].roomState;
    [self.parentView bringSubviewToFront:[_videoViews firstObject]];
    
    [self.hdTitleView  modifyTextColor: [UIColor blackColor]];
    [self.hdTitleView  modifyIconBackColor: [UIColor blackColor]];
    
    
}

-(HDWhiteBoardView *)whiteBoardView{
    
    if (!_whiteBoardView) {
        
        _whiteBoardView = [[HDWhiteBoardView alloc] init];
        __weak __typeof(self) weakSelf = self;
        _whiteBoardView.hidden = YES;
        _whiteBoardView.clickWhiteBoardViewBlock = ^(HDClickButtonType type, UIButton * _Nonnull btn) {
            
            [weakSelf clickWhiteBoardView:type withBtn:btn];
            
        };
        _whiteBoardView.fastboardDidJoinRoomSuccessBlock = ^{
            [weakSelf onFastboardDidJoinRoomSuccess];
        };
        _whiteBoardView.fastboardDidJoinRoomFailBlock = ^{
            [weakSelf onFastboardDidJoinRoomFail];
        };
    }
    
    return _whiteBoardView;
    
}

- (void)clickWhiteBoardView:(HDClickButtonType )type withBtn:(UIButton *)btn{
    
    switch (type) {
        case HDClickButtonTypeScale:
            [self onScaleBtn:btn];
            break;
        case HDClickButtonTypeFile:
            
            [self uploadFile];
            
            break;
        case HDClickButtonTypeLogout:
            //退出确认提示
            [self disconnectRoom];
           
            break;
        default:
            break;
    }
    
    
}
-(void)onScaleBtn:(UIButton *)sender{
    //全屏显示
    HDVECCallCollectionViewCellItem  * midelleViewItem =  [_videoViews firstObject];
    HDWhiteBoardView * whiteView = (HDWhiteBoardView *) midelleViewItem.camView;
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        
        NSLog(@"sender.isSelected");
        if (self.isLandscape) {
            [whiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.leading.offset(0);
                make.trailing.offset(0);
                make.bottom.offset(0);

            }];
            [self.parentView sendSubviewToBack:whiteView];
        }else{

            [whiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(kApplicationStatusBarHeight);
                make.leading.offset(0);
                make.trailing.offset(0);
                make.bottom.offset(0);
            }];
            [whiteView layoutIfNeeded];
            [self.parentView bringSubviewToFront:whiteView];
        }
    }else{
        NSLog(@"点击了互动白板事件");
        if (self.isLandscape) {
            [whiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(0);
                make.leading.offset(0);
                make.trailing.offset(0);
                make.bottom.offset(0);

            }];
            [self.parentView sendSubviewToBack:whiteView];
        }else{

            [whiteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.smallWindowView.mas_bottom).offset(44);
                make.leading.offset(0);
                make.trailing.offset(0);
                make.height.offset(kPointHeight);
            }];
            [whiteView layoutIfNeeded];
        }
    }
    
}
- (void)uploadFile{
    [HDUploadFileViewController sharedManager];
}
- (void)disconnectRoomAlert{
    
    [self showAlertWithTitle:NSLocalizedString(@"uploading...", "Upload attachment")
                actionTitles:@[NSLocalizedString(@"uploading...", "Upload attachment")]
                 cancelTitle:NSLocalizedString(@"uploading...", "Upload attachment")
                    callBack:^(NSInteger index) {
        
        [self disconnectRoom];
        
    }];
}
- (void)disconnectRoom{
   
    if (self.isSmallWindow) {
        
        [self __cancelPictureInPicture];
    }
    for (HDVECCallCollectionViewCellItem * tmpItem in self.smallWindowView.items) {
        
        NSLog(@"======%@",tmpItem.nickName);
    }
    [[HDWhiteRoomManager shareInstance] hd_OnLogout];
    HDVECCallCollectionViewCellItem  * midelleViewItem =  [_videoViews firstObject];
    HDWhiteBoardView * whiteView = (HDWhiteBoardView *) midelleViewItem.camView;
    
    [whiteView removeFromSuperview];
    [self.whiteBoardView removeFromSuperview];
    self.whiteBoardView=nil;
    //把 小窗口 最后一个元素 拿到中间
    HDVECCallCollectionViewCellItem * samllItem =  [self.smallWindowView.items lastObject];
    
    [self updateBigVideoView:samllItem];

    [self.smallWindowView removeCurrentCellItem:samllItem];
    [self.smallWindowView reloadData];
    
    //修改顶部 标题字体颜色
    [self.hdTitleView modifyTextColor:[UIColor whiteColor]];
    [self.hdTitleView  modifyIconBackColor: [UIColor whiteColor]];
    _whiteBoardBtn.selected = [HDWhiteRoomManager shareInstance].roomState;
    
}
#pragma mark ---------------------屏幕共享 相关 start----------------------
/// 注册屏幕共享通知
- (void)registScreenShare{
    // 注册屏幕分享的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScreenShare:) name:HDVEC_SCREENSHARE_STATRT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScreenShare:) name:HDVEC_SCREENSHARE_STOP object:nil];
}
// 屏幕共享事件
- (void)shareDesktopBtnClicked:(UIButton *)btn {
    _shareBtn = btn;
    _shareBtn.selected = _shareState;
    if ([HDWhiteRoomManager shareInstance].roomState == YES) {
        //当前正在白板房间
        [MBProgressHUD  dismissInfo:NSLocalizedString(@"video_call_shareScreen", "当前正在白板中不能进行屏幕共享")  withWindow:self.alertWindow];
        return;
    }

    // 创建 屏幕分享
    [[HDVECScreeShareManager shareInstance] vec_initBroadPickerView];
    NSLog(@"点击了屏幕共享事件");
}

/// 开启屏幕分享 修改状态
/// @param noti
- (void)startScreenShare:(NSNotification *) noti{
    _shareState= YES;
    _shareBtn.selected = _shareState;
    
}
/// 关闭屏幕分享 修改状态
/// @param noti
- (void)stopScreenShare:(NSNotification *) noti{
    _shareState= NO;
    //更改按钮的状态
    _shareBtn.selected = _shareState;
    
  
}
#pragma mark ---------------------屏幕共享 相关 end----------------------
- (void)dealloc{
    
    // 移除 通知
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:HDVEC_SCREENSHARE_STATRT object:nil];
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:HDVEC_SCREENSHARE_STOP object:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     if ([keyPath isEqualToString:@"text"]) {
        NSString *string = change[NSKeyValueChangeNewKey];
        if (self.hdSupendCustomView) {
            [self.hdSupendCustomView  updateTimeText:string];
        }
    }
}

#pragma mark - Picture in picture  相关

- (void)__enablePictureInPicture{

    [self.view hideKeyBoard];
    self.isSmallWindow = YES;
    self.alertWindow.frame =  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
//    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height/2);
    
//    self.alertWindow.layer.borderWidth = 1;
//    self.alertWindow.layer.borderColor = [UIColor blackColor].CGColor;
    self.alertWindow.layer.shadowOpacity = 0.5;
    self.alertWindow.layer.shadowRadius = 15;
    

    if ([HDWhiteRoomManager shareInstance].roomState) {
        // 先去 小窗拿 如果没有在去中间拿
        if (_videoViews.count > 0) {
            HDVECCallCollectionViewCellItem * tmpItem = [_videoViews firstObject];
//            [self.view  sendSubviewToBack:tmpItem.camView];
            [self updateBgMilldelVideoView:tmpItem.camView whiteBoard:NO];

            self.smallWindowView.hidden = YES;
            self.barView.hidden = YES;
        }

        [self.whiteBoardView hd_ModifyStackViewLayout:self.hdTitleView withScle:YES];
        [self.whiteBoardView hdmas_remakeConstraints:^(MASConstraintMaker * _Nonnull make) {

            make.top.offset(self.hdTitleView.size.height);
            make.leading.offset(0);
            make.trailing.offset(0);
            make.bottom.offset(0);

        }];

    }else{

        self.barView.hidden = YES;


    }
    
    if (_videoViews.count > 0) {
        HDVECCallCollectionViewCellItem * tmpItem = [_videoViews firstObject];

        if (tmpItem.isVideoMute) {
            tmpItem.closeCamView.frame = self.alertWindow.frame;
        }
      
    }
    
    
    [self.itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(0);
        make.leading.offset(5);
        make.trailing.offset(-5);
        make.height.offset(44);

    }];

}
- (void)__cancelPictureInPicture{
   
    [self.view hideKeyBoard];
    self.isSmallWindow = NO;
    self.alertWindow.frame = [UIScreen mainScreen].bounds;
//    self.alertWindow.layer.borderWidth = 0;
//    self.alertWindow.layer.borderColor = [UIColor blackColor].CGColor;
    if ([HDWhiteRoomManager shareInstance].roomState) {
        // 先去 小窗拿 如果没有在去中间拿
        if (_videoViews.count > 0) {
            HDVECCallCollectionViewCellItem * tmpItem = [_videoViews firstObject];
            [self updateBgMilldelVideoView:tmpItem.camView whiteBoard:YES];

            self.smallWindowView.hidden = NO;
            self.barView.hidden = NO;
        }
        [self.whiteBoardView hd_ModifyStackViewLayout:self.hdTitleView withScle:NO];


    }else{
        self.smallWindowView.hidden = NO;
        self.barView.hidden = NO;


    }
    
    if (_videoViews.count > 0) {
        HDVECCallCollectionViewCellItem * tmpItem = [_videoViews firstObject];
        if (tmpItem.isVideoMute) {
            tmpItem.closeCamView.frame = self.alertWindow.frame;
        }
      
    }
    
    [self.itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.barView.mas_top).offset(-5);
        make.leading.offset(5);
        make.trailing.offset(-5);
        make.height.offset(44);

    }];
}
#pragma mark - Picture in picture 中 隐藏效果
- (void)createBaseUI{
    if (_suspendType==VEC_BUTTON) {
        viewWidth=80;
        viewHeight=80;
    }else if (_suspendType==VEC_IMAGEVIEW){
        viewWidth=100;
        viewHeight=100;
    }else if (_suspendType==VEC_GIF){
        viewWidth=100;
        viewHeight=100;
        
    }else if (_suspendType==VEC_MUSIC){
        viewWidth=150;
        viewHeight=100;
    }else if (_suspendType==VEC_VIDEO){
        viewWidth=200;
        viewHeight=150;
    }else if (_suspendType==VEC_SCROLLVIEW){
        viewWidth=200;
        viewHeight=200;
    }else if (_suspendType==VEC_OTHERVIEW){
        viewWidth=88;
        viewHeight=88;
    }
    NSString *type=[NSString stringWithFormat:@"%ld",(long)_suspendType];
    _hdSupendCustomView=[self createCustomViewWithType:type];
    _customWindow=[self createCustomWindow];
    
    [_customWindow addSubview:_hdSupendCustomView];
    [_customWindow makeKeyAndVisible];
    
}
- (HDVECSuspendCustomView *)createCustomViewWithType:(NSString *)type{
    if (!_hdSupendCustomView) {
        _hdSupendCustomView=[[HDVECSuspendCustomView alloc]init];
        _hdSupendCustomView.viewWidth=viewWidth;
        _hdSupendCustomView.viewHeight=viewHeight;
        [_hdSupendCustomView initWithSuspendType:type];
        _hdSupendCustomView.frame=CGRectMake(0, 0, viewWidth, viewHeight);
        _hdSupendCustomView.suspendDelegate=self;
        _hdSupendCustomView.rootView=self.view;
    }

    return _hdSupendCustomView;
}
- (UIWindow *)createCustomWindow{
     if (!_customWindow) {
        _customWindow=[[UIWindow alloc]init];
        _customWindow.frame=CGRectMake(WINDOWS.width-viewWidth,WINDOWS.height/4, viewWidth, viewHeight);
        _customWindow.windowLevel=UIWindowLevelAlert+2;
        _customWindow.backgroundColor=[UIColor clearColor];
        
    }
    return _customWindow;
}
//悬浮视图消失
- (void)cancelWindow{
    
    [_customWindow resignFirstResponder];
    _customWindow=nil;

}
#pragma mark --SuspendCustomViewDelegate

- (void)suspendCustomViewClicked:(id)sender{
    self.alertWindow.hidden = NO;
    self.view.hidden = NO;
    _hdSupendCustomView.hidden = !self.view.hidden;
    [self.hdTitleView.timeLabel removeObserver:self forKeyPath:@"text"];
}
- (void)dragToTheLeft{
    NSLog(@"左划到左边框了");

}
- (void)dragToTheRight{
    NSLog(@"右划到右边框了");

}
- (void)dragToTheTop{
    NSLog(@"上滑到顶部了");

}
- (void)dragToTheBottom{
    NSLog(@"下滑到底部了");
}

- (void)__enablePictureInPictureZoom{

    self.alertWindow.hidden = YES;
    self.view.hidden = YES;

    self.suspendType = VEC_OTHERVIEW;
    [self createBaseUI];
    
    _hdSupendCustomView.hidden = !self.view.hidden;

    [self.hdTitleView.timeLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
  
}
#pragma mark - ----------------VEC截图测试 相关
-(UIButton *)vec_screenBtn{
    
    if (!_vec_screenBtn) {
        _vec_screenBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _vec_screenBtn.frame = CGRectMake(20, self.view.frame.size.height/3, 88, 44);
        [_vec_screenBtn setBackgroundColor:[UIColor whiteColor]];
        [_vec_screenBtn setTitle:@"截访客屏幕" forState:UIControlStateNormal];
        [_vec_screenBtn addTarget:self action:@selector(doScreen:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _vec_screenBtn;
    
}
-(UIImageView *)vec_screenImageView{
    
    if (!_vec_screenImageView) {
        _vec_screenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height/2, 220, 220)];
        
    }
    
    return _vec_screenImageView;
    
}
-(void)doScreen:(UIButton *)sender{

    [[HDVECAgoraCallManager shareInstance] vec_getVisitorScreenshotCompletion:^(NSString * _Nonnull url, HDError * _Nonnull error) {
    
        // 获取到url 显示到 界面上
        if (url.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
            [self.vec_screenImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil ];
        
        });
        
        }
    }];
}
- (void)userAccountNeedRelogin:(HDAutoLogoutReason)reason{
    
    [self offBtnClicked:nil];
    
}
@end
