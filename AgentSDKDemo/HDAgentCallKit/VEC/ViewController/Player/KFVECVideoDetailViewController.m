//
//  KFVideoDetailViewController.m
//  AgentSDKDemo
//
//  Created by houli on 2022/2/23.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFVECVideoDetailViewController.h"
#import "HDVECVideoDetailModel.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#if __has_include(<KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>)
#import <KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>
#endif
@interface KFVECVideoDetailViewController ()<KJPlayerDelegate,KJPlayerBaseViewDelegate>
{
    
    NSArray *_allVideoDetails;
    
}
@property(nonatomic,strong)UIImageView *imageView;
@property (nonatomic, strong) UIButton *downBtn;
@property (nonatomic, strong) UIButton *upBtn;
@property (nonatomic, strong) AVPlayerViewController *pVC;

@end

@implementation KFVECVideoDetailViewController
- (void)dealloc{
    // 只要控制器执行此方法，代表VC以及其控件全部已安全从内存中撤出。
    // ARC除去了手动管理内存，但不代表能控制循环引用，虽然去除了内存销毁概念，但引入了新的概念--对象被持有。
    // 框架在使用后能完全从内存中销毁才是最好的优化
    // 不明白ARC和内存泄漏的请自行谷歌，此示例已加入内存检测功能，如果有内存泄漏会alent进行提示
    NSLog(@"\n控制器%@已销毁",self);
}
//- (void)backItemClick{
//    [self.player kj_stop];
//    [self.navigationController popViewControllerAnimated:YES];
//}
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.view.backgroundColor = PLAYER_UIColorFromHEXA(0xf5f5f5, 1);
//
//    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
//    backview.image = [UIImage imageNamed:@"Nini"];
//    self.basePlayerView = backview;
//    [self.view addSubview:backview];
//    backview.delegate = self;
//
//    backview.gestureType = KJPlayerGestureTypeAll;
//    backview.autoRotate = NO;
//
//    KJAVPlayer *player = [[KJAVPlayer alloc]init];
//    self.player = player;
//    player.delegate = self;
//#if __has_include(<KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>)
//    player.roregroundResume = YES;
//#endif
//    player.placeholder = backview.image;
//    player.playerView = backview;
//    [backview.loadingLayer kj_startAnimation];
//
//
//    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    self.progressView = progressView;
//    progressView.progressTintColor = [UIColor.redColor colorWithAlphaComponent:0.8];
//    [progressView setProgress:0.0 animated:NO];
//    [self.view addSubview:progressView];
//    self.progressView.hidden = YES;
//    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(backview.mas_bottom).offset(-10);
//        make.leading.offset(20);
//        make.trailing.offset(-20);
//        make.height.offset(5);
//    }];
//
////    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(7, 0, self.view.bounds.size.width-14, 30)];
//    UISlider *slider = [[UISlider alloc] init];
//    self.slider = slider;
//
//    slider.backgroundColor = UIColor.clearColor;
//    slider.center = _progressView.center;
//    slider.minimumValue = 0.0;
////    [slider setMaximumValueImage:[UIImage imageNamed:@"smart@2x.png"]];
////    [slider setMinimumValueImage:[UIImage imageNamed:@"smart@2x.png"]];
//    [slider setThumbImage:[UIImage imageNamed:@"list_status_radio_droplist_4@2x.png"] forState:UIControlStateNormal];
//
//       // 滑条的图片，图片一定要设置拉伸区域
////       [slider setMaximumTrackImage:[[UIImage imageNamed:@"smart@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 4, 4)] forState:UIControlStateNormal];
////       [slider setMinimumTrackImage:[[UIImage imageNamed:@"smart@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 4, 4)] forState:UIControlStateNormal];
//
//    [self.view addSubview:slider];
//    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
//    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(backview.mas_bottom).offset(-10);
//        make.leading.offset(20);
//        make.trailing.offset(-20);
//        make.height.offset(6);
//    }];
//
//
//    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, self.view.bounds.size.height-69-PLAYER_BOTTOM_SPACE_HEIGHT, self.view.bounds.size.width-10, 20)];
//    self.label = label2;
//    label2.textAlignment = 0;
//    label2.font = [UIFont systemFontOfSize:14];
//    label2.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
//    [self.view addSubview:label2];
//    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(backview.mas_bottom).offset(-25);
//        make.leading.offset(20);
////        make.height.offset(5);
//    }];
//
//
//    UILabel *label3 = [[UILabel alloc]init];
//    self.label3 = label3;
////    label3.backgroundColor = [UIColor whiteColor];
//    label3.textAlignment = 2;
//    label3.font = [UIFont systemFontOfSize:14];
//    label3.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.7];
//    [self.view addSubview:label3];
//    [self.label3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(backview.mas_bottom).offset(-25);
////        make.leading.offset(20);
//        make.trailing.offset(-20);
////        make.height.offset(5);
//    }];
//
//    {
//        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
////        button.frame = CGRectMake(30, self.view.frame.size.height/2-25, 100, 50);
////        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
//        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
//        [button setTitle:@"上一条" forState:(UIControlStateNormal)];
//        self.upBtn = button;
//        [self.view addSubview:button];
//        [button mas_makeConstraints:^(MASConstraintMaker *make) {
//
//                   make.top.mas_equalTo(self.basePlayerView.mas_bottom).offset(20);
//                   make.leading.offset(44);
//                   make.width.offset(100);
//                   make.height.offset(50);
//               }];
//        [button addTarget:self action:@selector(upButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    }{
//        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
////        button.frame = CGRectMake(self.view.frame.size.width-30-100, self.view.frame.size.height/2-25, 100, 50);
////        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
//        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
//        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
//        [button setTitle:@"下一条" forState:(UIControlStateNormal)];
//        self.downBtn = button;
//        [self.view addSubview:button];
//        [button mas_makeConstraints:^(MASConstraintMaker *make) {
//
//                   make.top.mas_equalTo(self.basePlayerView.mas_bottom).offset(20);
//                   make.trailing.offset(-44);
//                   make.width.offset(100);
//                   make.height.offset(50);
//               }];
//        [button addTarget:self action:@selector(dowonButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
//    }
//
//
////    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2020-09-27/542926a8c2a99808fc981d46c1dc6aef.mp4"];
//
//    self.player.videoURL = [NSURL URLWithString: self.currentModel.playbackUrl];
//
//    [self getSessioningAllRecordVideos];
//
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = PLAYER_UIColorFromHEXA(0xf5f5f5, 1);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
  
    self.pVC = [AVPlayerViewController new];
    
   self.pVC.player = [AVPlayer playerWithURL:[NSURL URLWithString: self.currentModel.playbackUrl]];
   
   self.pVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2 );
      
   [self.view addSubview: self.pVC.view];
   
   [ self.pVC.player play];

    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        button.frame = CGRectMake(30, self.view.frame.size.height/2-25, 100, 50);
//        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"上一条" forState:(UIControlStateNormal)];
        self.upBtn = button;
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {

                   make.top.mas_equalTo(self.pVC.view.mas_bottom).offset(20);
                   make.leading.offset(44);
                   make.width.offset(100);
                   make.height.offset(50);
               }];
        [button addTarget:self action:@selector(upButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
//        button.frame = CGRectMake(self.view.frame.size.width-30-100, self.view.frame.size.height/2-25, 100, 50);
//        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
        [button setTitle:@"下一条" forState:(UIControlStateNormal)];
        self.downBtn = button;
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {

                   make.top.mas_equalTo(self.pVC.view.mas_bottom).offset(20);
                   make.trailing.offset(-44);
                   make.width.offset(100);
                   make.height.offset(50);
               }];
        [button addTarget:self action:@selector(dowonButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }


//    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2020-09-27/542926a8c2a99808fc981d46c1dc6aef.mp4"];

//    self.player.videoURL = [NSURL URLWithString: self.currentModel.playbackUrl];

    [self getSessioningAllRecordVideos];

}


- (void)initArraySort{
    self.currentModel = [self getCallidModel:self.callId];
    //根据 元素取到下标
    NSInteger idx = [self.recordVideos indexOfObject:self.currentModel];
    self.currentVideoIdx = idx;
    
}
//获取会话当中的全部视频记录
- (void)getSessioningAllRecordVideos{
    
    [[HDOnlineManager sharedInstance] getAllVideoDetailsSession:self.conversationModel.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        
        if (error == nil) {
            
            NSArray*  tmp = [[HDOnlineManager sharedInstance] getVideoPlayBackVideoDetailsAll];
           _allVideoDetails = [NSArray yy_modelArrayWithClass:[KFVideoDetailModel class] json:tmp];
            [_allVideoDetails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                KFVideoDetailModel * model = obj;
                
                if ([model.callId isEqualToString:self.currentModel.callId]) {
                    // 获取到当前的以后 在取出 数组里边的下一个 放到当前播放
                    NSInteger lastIdx = _allVideoDetails.count - 1;
                   
                    self.currentVideoIdx = idx;
                    *stop= YES;
                }
            }];
            [self btnStateChange];
        }
    }];
}

- (HDVECVideoDetailModel *)getCallidModel:(NSString *)callid{

    NSMutableArray * tmp = [NSMutableArray new];
    [self.recordVideos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HDVECVideoDetailModel * model = obj;
        if ([model.callId isEqualToString:callid]) {
            
            [tmp addObject:model];
        }
    }];
    
    if ( 2 > tmp.count > 0) {
        // 只有一个 视频记录 返回 当前model 即可
        
        return [tmp firstObject];
        
    }else if(tmp.count > 1){
        // 如果有两 或者多个 说明 一个录制视频 被 声网截取成两个 需要先展示 第一个 根据时间排序 然后取第一个返回
        
        NSArray * detailArray = [self sortVideoDetails:tmp];
        return [detailArray firstObject];
    }else{
        
        return nil;
    }
}
- (NSArray *)sortVideoDetails:(NSArray *)modelArray{
    
    //降序 要是升序ascending传yes
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"recordStart" ascending:YES];
    NSArray* sortPackageResListArr = [modelArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSLog(@"%@",sortPackageResListArr);

    return  sortPackageResListArr;
}
- (void)btnStateChange{
    
    NSInteger idx = _allVideoDetails.count - 1;

    if (self.currentVideoIdx <= 0) {
        //不可触发
        self.upBtn.userInteractionEnabled=NO;//交互关闭
        self.upBtn.alpha=0.4;//透明度
    
    }else{
        self.upBtn.userInteractionEnabled=YES;//交互开启
        self.upBtn.alpha=1;//透明度
    }
    
    if (self.currentVideoIdx >= idx) {
        //不可触发
        self.downBtn.userInteractionEnabled=NO;//交互关闭
        self.downBtn.alpha=0.4;//透明度

    }else{
        self.downBtn.userInteractionEnabled=YES;//交互开启
        self.downBtn.alpha=1;//透明度
    }
    
}

- (void)upButtonAction:(UIButton*)sender{
    
    if (_allVideoDetails.count > 0) {
    --self.currentVideoIdx;
    [self changeVideoUrl];
    NSLog(@"kf-upButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
    }else{
        
        [[HDOnlineManager sharedInstance] getAllVideoDetailsSession:self.conversationModel.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
            
            if (error == nil) {
                
                NSArray*  tmp = [[HDOnlineManager sharedInstance] getVideoPlayBackVideoDetailsAll];
               _allVideoDetails = [NSArray yy_modelArrayWithClass:[KFVideoDetailModel class] json:tmp];
              
                [_allVideoDetails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    KFVideoDetailModel * model = obj;
                    
                    if ([model.callId isEqualToString:self.currentModel.callId]) {
                        // 获取到当前的以后 在取出 数组里边的下一个 放到当前播放
                        NSInteger lastIdx = _allVideoDetails.count - 1;
                       
                        if (lastIdx != idx) {
                            self.currentVideoIdx = idx - 1;
                        }else{
                            self.currentVideoIdx = idx;
                        }
                        *stop= YES;
                    }
                }];
                [self changeVideoUrl];
                NSLog(@"kf-upButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
            }
        }];
    }
}

//点击下一条
- (void)dowonButtonAction:(UIButton*)sender{
    // 判断当前有没有第二条 记录 如果有展示 第二条 如果没有 取出全部里边的视频记录 显示
    if (_allVideoDetails.count > 0) {
    ++self.currentVideoIdx;
    [self changeVideoUrl];
    NSLog(@"kf-upButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
    }else{
    [[HDOnlineManager sharedInstance] getAllVideoDetailsSession:self.conversationModel.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        
        if (error == nil) {
            
            NSArray*  tmp = [[HDOnlineManager sharedInstance] getVideoPlayBackVideoDetailsAll];
           _allVideoDetails = [NSArray yy_modelArrayWithClass:[KFVideoDetailModel class] json:tmp];
          
            [_allVideoDetails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                KFVideoDetailModel * model = obj;
                
                if ([model.callId isEqualToString:self.currentModel.callId]) {
                    // 获取到当前的以后 在取出 数组里边的下一个 放到当前播放
                    NSInteger lastIdx = _allVideoDetails.count - 1;
                   
                    if (lastIdx != idx) {
                        self.currentVideoIdx = idx +1;
//                        [self changeVideoUrl];
                    }else{
                        self.currentVideoIdx = idx;
                    }
                    
                    *stop= YES;
                }
            }];
            
            [self changeVideoUrl];
            NSLog(@"kf-dowonButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
        }
    }];
    }
 
}

/// 获取数组里边的url
- (void)changeVideoUrl{
    NSInteger idx = _allVideoDetails.count - 1;
    [self btnStateChange];
    if (self.currentVideoIdx > idx || self.currentVideoIdx < 0) {
        
        return;
    }
    
  
    self.currentModel = [_allVideoDetails objectAtIndex:self.currentVideoIdx];
    NSString * videoUrl = self.currentModel.playbackUrl;
    NSLog(@"kf-changeVideoUrl=%@ ",[self.currentModel yy_modelToJSONString]);
//    self.player.videoURL  =  [NSURL URLWithString:videoUrl];
    NSURL *videoURL = [NSURL URLWithString:videoUrl];
    self.pVC.player = [AVPlayer playerWithURL:videoURL];
    
    [ self.pVC.player play];
}



#pragma mark - KJPlayerDelegate
///* 当前播放器状态 */
//- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
//    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
//        [self.basePlayerView.loadingLayer kj_startAnimation];
//    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
//        [self.basePlayerView.loadingLayer kj_stopAnimation];
//    }else if (state == KJPlayerStatePlayFinished) {
////        [player kj_replay];
//    }
//}
///* 播放进度 */
//- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
//    self.slider.value = time;
//    self.label.text = kPlayerConvertTime(time);
//}
///* 缓存进度 */
//- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
//    [self.progressView setProgress:progress animated:YES];
//}
///* 播放错误 */
//- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
//
//}
/////进度条的拖拽事件 监听UISlider拖动状态
//- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
//    UITouch *touchEvent = [[event allTouches]anyObject];
//    switch(touchEvent.phase) {
//        case UITouchPhaseBegan:
//            [self.player kj_pause];
//            break;
//        case UITouchPhaseMoved:
//            break;
//        case UITouchPhaseEnded:{
//            CGFloat second = slider.value;
//            [slider setValue:second animated:YES];
//            [self.player kj_appointTime:second];
//        } break;
//        default:break;
//    }
//}
//
///// 视频总时长
///// @param player 播放器内核
///// @param time 总时间
//- (void)kj_player:(__kindof KJBasePlayer *)player videoTime:(NSTimeInterval)time{
//    NSLog(@"🎷🎷🎷 视频总时长 time = %.2f",time);
//    self.slider.maximumValue = time;
//    self.label3.text = kPlayerConvertTime(time);
//}
//
///// 获取视频尺寸大小
///// @param player 播放器内核
///// @param size 视频尺寸
//- (void)kj_player:(__kindof KJBasePlayer *)player videoSize:(CGSize)size{
//    NSLog(@"🎷🎷🎷 视频大小尺寸 width = %.2f, height = %.2f",size.width,size.height);
//}
//#pragma mark - KJPlayerBaseViewDelegate
//
///// 单双击手势反馈
///// @param view 播放器控件载体
///// @param tap 是否为单击
///* 单双击手势反馈 */
//- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap{
//    if (tap) {
//        if ([self.player isPlaying]) {
//            [self.player kj_pause];
//            [self.basePlayerView.loadingLayer kj_startAnimation];
//        } else {
//            [self.player kj_resume];
//            [self.basePlayerView.loadingLayer kj_stopAnimation];
//        }
//    } else {
//
//    }
//}
//
//
///// 长按手势反馈
///// @param view 播放器控件载体
///// @param longPress 长按手势
//- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view longPress:(UILongPressGestureRecognizer *)longPress{
//    switch (longPress.state) {
//        case UIGestureRecognizerStateBegan:{
//            self.player.speed = 2.;
//            [self.basePlayerView.hintTextLayer kj_displayHintText:@"长按快进播放中..."
//                                                             time:0
//                                                         position:KJPlayerHintPositionTop];
//        } break;
//        case UIGestureRecognizerStateChanged:{
//
//        } break;
//        case UIGestureRecognizerStateEnded:{
//            self.player.speed = 1.0;
//            [self.basePlayerView.hintTextLayer kj_hideHintText];
//        } break;
//        default:break;
//    }
//}
//
///// 进度手势反馈
//- (KJPlayerTimeUnion)kj_basePlayerView:(KJBasePlayerView *)view progress:(float)progress end:(BOOL)end{
//    if (end) {
//        NSTimeInterval time = self.player.currentTime + progress * self.player.totalTime;
//        [self.player kj_appointTime:time];
//    }
//    KJPlayerTimeUnion timeUnion;
//    timeUnion.currentTime = self.player.currentTime;
//    timeUnion.totalTime = self.player.totalTime;
//    return timeUnion;
//}
//
///// 音量手势反馈
///// @param view 播放器控件载体
///// @param value 音量范围，-1 到 1
///// @return 是否替换自带UI
//- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view volumeValue:(float)value{
//    self.player.volume = value;
//    return NO;
//}
//
///// 亮度手势反馈
///// @param view 播放器控件载体
///// @param value 亮度范围，0 到 1
///// @return 是否替换自带UI
//- (BOOL)kj_basePlayerView:(__kindof KJBasePlayerView *)view brightnessValue:(float)value{
//    return NO;
//}
//
///// 按钮事件响应
///// @param view 播放器控件载体
///// @param buttonType 按钮类型，KJPlayerButtonType类型
///// @param button 当前响应按钮
//- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view
//               buttonType:(NSUInteger)buttonType
//             playerButton:(__kindof KJPlayerButton *)button{
//
//}
//
///// 是否锁屏
///// @param view 播放器控件载体
///// @param locked 是否锁屏
//- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view locked:(BOOL)locked{
//
//}
//
///// 返回按钮响应
///// @param view 播放器控件载体
///// @param clickBack 点击返回
//- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view clickBack:(BOOL)clickBack{
//
//}
//
///// 当前屏幕状态发生改变
///// @param view 播放器控件载体
///// @param screenState 当前屏幕状态
//- (void)kj_basePlayerView:(__kindof KJBasePlayerView *)view screenState:(KJPlayerVideoScreenState)screenState{
//
//}

@end
