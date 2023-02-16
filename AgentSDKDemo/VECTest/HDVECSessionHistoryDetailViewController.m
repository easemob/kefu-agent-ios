//
//  HDVECSessionHistoryDetailViewController.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import "HDVECSessionHistoryDetailViewController.h"
#import "HDVECAgoraCallManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#if __has_include(<KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>)
#import <KJPlayer/KJBasePlayer+KJBackgroundMonitoring.h>
#endif
@interface HDVECSessionHistoryDetailViewController ()
@property(nonatomic,strong)UIImageView *imageView;
@property (nonatomic, strong) UIButton *downBtn;
@property (nonatomic, strong) UIButton *upBtn;
@property (nonatomic, strong) AVPlayerViewController *pVC;
@end

@implementation HDVECSessionHistoryDetailViewController

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
   self.pVC.view.frame = CGRectMake(0, -64, self.view.bounds.size.width, self.view.bounds.size.height/1.5 );
   [self.view addSubview: self.pVC.view];
   [self getSessioningAllRecordVideos];
    
//    [self.view addSubview:self.headView];

}

//获取视频详情
- (void)getSessioningAllRecordVideos{
        
    [[HDVECAgoraCallManager shareInstance] vec_getCallVideoDetailWithRtcSessionId:self.rtcSessionId Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
    
        
        if (error == nil) {
            
            if (responseObject&& [responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dic = responseObject;
                
                if ([[dic allKeys] containsObject:@"entities"]) {
                    
                    NSArray * array =  [dic objectForKey:@"entities"];
                    
                
                    NSDictionary * entities = [array firstObject];
                    
                    if ([[entities allKeys] containsObject:@"recordDetails"]) {
                        
                        NSArray * recordDetails =  [entities objectForKey:@"recordDetails"];
                        
                        if ([recordDetails isKindOfClass:[NSNull class]]) {
                            
                            return;
                        }
                        NSDictionary * recordDetailDic= [recordDetails firstObject];
                        if ([recordDetailDic isKindOfClass:[NSNull class]]) {
                            
                            return;
                        }
                        if ([[recordDetailDic allKeys] containsObject:@"playbackUrl"]) {
                            
                            NSString * playbackUrl = [recordDetailDic objectForKey:@"playbackUrl"];
                            
                            if (playbackUrl&& ![playbackUrl isKindOfClass:[NSNull class]]) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   // UI更新代码
                                    [self vec_play:playbackUrl];
                                });
                            }else{
                                // 弹窗
                                [MBProgressHUD  dismissInfo:@"视频录制接口返回url 为空 " withWindow:self.window];
                                
                                
                            }
                        }
                    }
                }
            }
        }
        NSLog(@"=======%@",responseObject);
    }];
        
}
- (void)vec_play:(NSString *)url{
    
    self.pVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:url]];
    [ self.pVC.player play];
    
}


-(UIView *)headView{
    
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _headView.backgroundColor = [UIColor grayColor];
        
        UILabel * label = [[UILabel alloc] init];
        label.text = @"视频回放";
        label.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.offset(24);
            make.leading.offset(32);
            make.trailing.offset(0);
            make.bottom.offset(0);
        }];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_headView addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(24);
            make.leading.offset(20);
            make.width.height.offset(32);
            
        }];
        [closeBtn addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    return _headView;
}
-(void)doClose:(UIButton *)sender{

   
    [self.view removeAllSubviews];
    
    self.view = nil;
    

}
@end
