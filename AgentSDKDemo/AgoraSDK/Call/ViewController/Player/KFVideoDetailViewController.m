//
//  KFVideoDetailViewController.m
//  AgentSDKDemo
//
//  Created by houli on 2022/2/23.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFVideoDetailViewController.h"
#import "KFVideoDetailModel.h"
@interface KFVideoDetailViewController ()<KJPlayerDelegate>
@property(nonatomic,strong)UIImageView *imageView;
@property (nonatomic, strong) UIButton *downBtn;
@property (nonatomic, strong) UIButton *upBtn;
@property (nonatomic, strong) KFVideoDetailModel *currentModel;


@end

@implementation KFVideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(30, self.view.frame.size.height/2-25, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"上一条" forState:(UIControlStateNormal)];
        self.upBtn = button;
        [self.view addSubview:button];
        [button addTarget:self action:@selector(upButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(self.view.frame.size.width-30-100, self.view.frame.size.height/2-25, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
        [button setTitle:@"下一条" forState:(UIControlStateNormal)];
        self.downBtn = button;
        [self.view addSubview:button];
        [button addTarget:self action:@selector(dowonButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    self.basePlayerView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.width*9/16);
    self.player.delegate = self;
    // 调整数组的顺序
//    [self initArraySort];
//    [self btnStateChange];
//    [self changeVideoUrl];
    
    self.player.videoURL = [NSURL URLWithString:@"https://mp4.vjshi.com/2020-09-27/542926a8c2a99808fc981d46c1dc6aef.mp4"];
}
- (void)initArraySort{
    self.currentModel = [self getCallidModel:self.callId];
    //根据 元素取到下标
    NSInteger idx = [self.recordVideos indexOfObject:self.currentModel];
    self.currentVideoIdx = idx;
    
}
- (KFVideoDetailModel *)getCallidModel:(NSString *)callid{

    NSMutableArray * tmp = [NSMutableArray new];
    [self.recordVideos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KFVideoDetailModel * model = obj;
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
    
    NSInteger idx = self.recordVideos.count - 1;

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
    --self.currentVideoIdx;
    [self changeVideoUrl];
    NSLog(@"kf-upButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
}
- (void)dowonButtonAction:(UIButton*)sender{
    ++self.currentVideoIdx;
    [self changeVideoUrl];
    NSLog(@"kf-dowonButtonAction=%@ ",[self.currentModel yy_modelToJSONString]);
}

/// 获取数组里边的url
- (void)changeVideoUrl{
    NSInteger idx = self.recordVideos.count - 1;
    [self btnStateChange];
    if (self.currentVideoIdx > idx || self.currentVideoIdx < 0) {
        return;
    }
    
    self.currentModel = [self.recordVideos objectAtIndex:self.currentVideoIdx];
    NSString * videoUrl = self.currentModel.playbackUrl;
    NSLog(@"kf-changeVideoUrl=%@ ",[self.currentModel yy_modelToJSONString]);
    self.player.videoURL  =  [NSURL URLWithString:videoUrl];
    
}

#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [self.basePlayerView.loadingLayer kj_startAnimation];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [self.basePlayerView.loadingLayer kj_stopAnimation];
    }else if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
    self.slider.value = time;
    self.label.text = kPlayerConvertTime(time);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    [self.progressView setProgress:progress animated:YES];
}
/* 播放错误 */
- (void)kj_player:(KJBasePlayer*)player playFailed:(NSError*)failed{
    
}
@end
