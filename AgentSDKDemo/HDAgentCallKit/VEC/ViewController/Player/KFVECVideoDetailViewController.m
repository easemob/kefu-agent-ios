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
}

@end
