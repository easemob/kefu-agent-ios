//
//  KFAnswerView.m
//  AgentSDKDemo
//
//  Created by houli on 2022/6/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFAnswerView.h"
#import "Masonry.h"
#import "UIView+GestureRecognizer.h"

@interface KFAnswerView()
{
    HDMessage * _message;
    KFRingingCallModel * _ringingCallModel;
}
@end

@implementation KFAnswerView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        //创建ui
//        self.backgroundColor = [[HDAppSkin mainSkin] contentColorBlockalpha:0.8];
        [self _creatUI];
    }
    return self;
}
- (void)_creatUI{
    
    [self addSubview:self.bgView];
    [self.bgView addSubview: self.bgImageView];
    [self.bgView sendSubviewToBack:self.bgImageView];
    
    //小窗按钮
    [self.bgView addSubview: self.zoomBtn];
    //访客头像
    [self.bgView addSubview:self.icon];
    //昵称
    [self.bgView addSubview:self.nickNameLabel];
    //标题
    [self.bgView addSubview:self.titleLabel];
    //接听
    [self.bgView addSubview: self.onBtn];
    [self.bgView addSubview: self.onLabel];
    //拒绝
//    [self.bgView addSubview:self.offBtn];
//    [self.bgView addSubview:self.offLabel];
 
    
    [self hd_fullViewLayout];
  
   
}
- (void)setMesage:(HDMessage *)message withRingCall:(KFRingingCallModel *)ringingCallModel{
    

    _message = message;
    _ringingCallModel = ringingCallModel;
    
    // 获取 username。如果 username 没有 显示 nicename
    
    self.nickNameLabel.text = message.fromUser.nicename;
    
    if (message.type == HDMessageBodyTypeText) {
        HDTextMessageBody *bd = (HDTextMessageBody *)message.nBody;
        
        self.titleLabel.text = bd.text;
    }
//    "type": "rtcmedia\/video",
    

   
    
    
}
- (void)playSoundCustom{
    
    // 来电铃声
    // 收到消息时，播放音频
        [[EMCDDeviceManager sharedInstance] playNewMessageSoundCustom];
    // 收到消息时，震动
        [[EMCDDeviceManager sharedInstance] playVibration];
    
}
- (void)stopSoundCustom{
    
    [[EMCDDeviceManager sharedInstance] stopSystemSoundID];
    
    
}

// 全屏布局
- (void)hd_fullViewLayout{
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
       
        make.top.offset(0);
        make.leading.offset(0);
        make.bottom.offset(0);
        make.trailing.offset(0);
    }];
    [self.zoomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(44);
        make.leading.offset(20);
        make.width.offset(32);
        make.height.offset(32);
    }];
    
    //访客头像
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY).multipliedBy(0.6);
        make.width.height.offset(128);
    }];
    [self.icon layoutIfNeeded];
    self.icon.layer.cornerRadius = 128/2;
    //昵称
    [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.icon.mas_centerX).offset(0);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(22);
        make.leading.offset(20);
        make.trailing.offset(-20);
    }];
    
    //标题
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.nickNameLabel.mas_centerX).offset(0);
        make.top.mas_equalTo(self.nickNameLabel.mas_bottom).offset(22);
        make.leading.offset(20);
        make.trailing.offset(-20);
    }];
    
    
    //接听
    [self.onBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-120);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.width.height.offset(72);
    }];
    [self.onLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.onBtn.mas_centerX).offset(0);
        make.top.mas_equalTo(self.onBtn.mas_bottom).offset(10);
       
    }];
    
    //拒绝
//    [self.offBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.offset(-120);
//        make.width.height.offset(72);
//        make.trailing.offset(-60);
//    }];
//    [self.offLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.offBtn.mas_centerX).offset(0);
//        make.top.mas_equalTo(self.offBtn.mas_bottom).offset(10);
//
//    }];
    
}

- (void)hd_alertView:(NSString *)info{
    
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:info preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
            [self stopSoundCustom];
            [self removeFromSuperview];
    
        }];
    
        [alertController addAction:okAction];
    
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)hd_smallViewLayout{
    
    [self.zoomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.bottom.offset(0);
        make.leading.offset(0);
        make.trailing.offset(0);
    }];
    
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.leading.offset(20);
        make.width.height.offset(84/1.2);
    }];
    [self.icon layoutIfNeeded];
    self.icon.layer.cornerRadius = 84/1.2/2;
    //接听
    [self.onBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY).offset(0);
        make.trailing.offset(-20);
        make.width.height.offset(84/1.6);
    }];
    //拒绝
//    [self.offBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.onBtn.mas_centerY).offset(0);
//        make.trailing.mas_equalTo(self.onBtn.mas_leading).offset(-10);
//        make.width.height.offset(84/1.6);
//    }];

    //昵称
    [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10);
        make.trailing.mas_equalTo(self.onBtn.mas_leading).offset(-10);
        make.leading.mas_equalTo(self.icon.mas_trailing).offset(-10);
    }];

    //标题
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-10);
        make.trailing.mas_equalTo(self.onBtn.mas_leading).offset(-10);
        make.leading.mas_equalTo(self.icon.mas_trailing).offset(-10);
    }];
    
    
}

- (UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = NSLocalizedString(@"video.answer.title", @"视频通话");;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
//        _titleLabel.font =  [[HDAppSkin mainSkin] systemFont19pt];
        _nickNameLabel.numberOfLines = 2;
        _nickNameLabel.lineBreakMode =NSLineBreakByTruncatingTail;
        _nickNameLabel.font =  [[HDAppSkin mainSkin] systemFont17pt];
    }
    
    return _titleLabel;
}

- (UILabel *)nickNameLabel{
    
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = NSLocalizedString(@"访客昵称访客昵称", @"");;
        _nickNameLabel.textColor = [UIColor whiteColor];
//        _nickNameLabel.backgroundColor = [ UIColor redColor];
        _nickNameLabel.textAlignment=NSTextAlignmentCenter;
        _nickNameLabel.numberOfLines = 2;
        _nickNameLabel.lineBreakMode =NSLineBreakByTruncatingTail;
        _nickNameLabel.adjustsFontSizeToFitWidth = YES;
        _nickNameLabel.font =  [[HDAppSkin mainSkin] systemFont17pt];
    }
    return _nickNameLabel;
}

- (UIImageView *)icon{
    
    if (!_icon) {
        _icon=[[UIImageView alloc] init];
        _icon.layer.masksToBounds = YES;
        _icon.image = [UIImage imageNamed:@"icon_180@2x.png"];
        
    }
    return _icon;
}

- (UIImageView *)bgImageView{
    
    if (!_bgImageView) {
        _bgImageView=[[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor blackColor];
    }
    return _bgImageView;
}

- (UIView *)bgView{
    
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        
    }
    return _bgView;
    
}

- (UIButton *)onBtn{
    if (!_onBtn) {
        _onBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_onBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        //为button赋值
        [_onBtn setImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
    }
    return _onBtn;
}
- (UILabel *)onLabel{
    if (!_onLabel) {
        _onLabel = [[UILabel alloc]init];
        _onLabel.textAlignment = NSTextAlignmentLeft;
        _onLabel.textColor = [UIColor whiteColor];
        _onLabel.text = @"接听";
    }
    return _onLabel;
}
- (UILabel *)offLabel{
    if (!_offLabel) {
        _offLabel = [[UILabel alloc]init];
        _offLabel.textAlignment = NSTextAlignmentLeft;
        _offLabel.textColor = [UIColor whiteColor];
        _offLabel.text = @"拒绝";
    }
    return _offLabel;
}

- (UIButton *)zoomBtn{
   
    if (!_zoomBtn) {
        _zoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomBtn addTarget:self action:@selector(zoomClick:) forControlEvents:UIControlEventTouchUpInside];
        //为button赋值
       
        UIImage * img = [UIImage imageWithIcon:kzoom  inFont:kfontName size:44 color:[UIColor whiteColor]];
        [_zoomBtn setImage:img forState:UIControlStateNormal];
    }
    return _zoomBtn;
    
}
- (UIView *)zoomView{
   
    if (!_zoomView) {
        _zoomView = [[UIView alloc] init];

    }
    return _zoomView;
    
}

- (UIButton *)offBtn{
    if (!_offBtn) {
        _offBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_offBtn addTarget:self action:@selector(offClick:) forControlEvents:UIControlEventTouchUpInside];
        //为button赋值
        [_offBtn setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    }
    return _offBtn;
}


- (void)onClick:(UIButton *)sender{
    
    if (self.clickOnBlock) {
        self.clickOnBlock(sender);
    }
    
    [self stopSoundCustom];
    //初始化灰度管理
    [[HDCallManager shareInstance] initGray];
    
    // 调用通行证接口
    [[HLCallManager  sharedInstance] getAgoraTicketWithCallId:_ringingCallModel.callId withSessionId: _message.sessionId completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        
        if (error ==nil) {
        
            NSLog(@"====%@",responseObject);
            [[NSNotificationCenter defaultCenter] postNotificationName:HDCALL_liveStreamInvitation_CreateAgoraRoom object:_message];

        }else{
            
            // 调用通行证失败 关闭界面
            [self  hd_alertView:error.errorDescription];
            
            
        }
        
        
        
    }];
    
    
}
- (void)offClick:(UIButton *)sender{
    //停止铃声 关闭界面  发送 cmd 通知
    [self stopSoundCustom];
    [self removeFromSuperview];
    
}
- (void)zoomClick:(UIButton *)sender{
    
    // 点击这个修改 接通方式
    
    self.frame = CGRectMake(0, 22, [UIScreen mainScreen].bounds.size.width, 84);
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.bgView.hidden = YES;
    
    // 添加小窗 接听view
    [self addSubview:self.zoomView];
    [self.zoomView addSubview:self.icon];
    [self.zoomView addSubview:self.onBtn];
    [self.zoomView addSubview:self.offBtn];
    [self.zoomView addSubview:self.nickNameLabel];
    [self.zoomView addSubview:self.titleLabel];
    
    [self hd_smallViewLayout];

    __weak __typeof(self)weakSelf = self;
    [self.zoomView setTapActionWithBlock:^{
       
        NSLog(@"=======");
     
        //调用 全屏布局    self.zoomView.hidden = YES;
        weakSelf.bgView.hidden = NO;
        [weakSelf.zoomView removeFromSuperview];
        weakSelf.zoomView = nil;
        weakSelf.frame = [UIScreen mainScreen].bounds;
        [weakSelf _creatUI];
        [weakSelf hd_fullViewLayout];
     
    }];
    
    
    
}

@end
