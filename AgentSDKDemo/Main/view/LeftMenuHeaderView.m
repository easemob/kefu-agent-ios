//
//  LeftMenuHeaderView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "LeftMenuHeaderView.h"

#import "UIImageView+EMWebCache.h"

#define kLeftMenu_Height 70.f

@interface LeftMenuHeaderView ()
{
    
}

@end

@implementation LeftMenuHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    _headImageView = [[EMHeaderImageView alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    [_headImageView updateHeadImage];
    [self addSubview:_headImageView];
//    _nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 20, 30, 95, 40)];
    _nickLabel = [[UILabel alloc] init];
    _nickLabel.text = user.nicename;
    _nickLabel.textColor = [UIColor whiteColor];
    _nickLabel.textAlignment = NSTextAlignmentLeft;
    _nickLabel.font = [UIFont boldSystemFontOfSize:18];
//    _nickLabel.backgroundColor = [UIColor grayColor];
    [self addSubview:_nickLabel];
    
    _onlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_onlineButton setBackgroundColor:[UIColor cyanColor]];
    _onlineButton.frame = CGRectMake(KScreenWidth - kHomeViewLeft - 55, 30, 55, 40);
    if ([user.onLineState isEqualToString:USER_STATE_ONLINE]) {
        [_onlineButton setTitle:@"空闲" forState:UIControlStateNormal];
    } else if ([user.onLineState isEqualToString:USER_STATE_BUSY]) {
        [_onlineButton setTitle:@"忙碌" forState:UIControlStateNormal];
    } else if ([user.onLineState isEqualToString:USER_STATE_LEAVE]) {
        [_onlineButton setTitle:@"离开" forState:UIControlStateNormal];
    } else {
        [_onlineButton setTitle:@"隐身" forState:UIControlStateNormal];
    }
    [_onlineButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_onlineButton.width/1.2, 0, 0)];
    [_onlineButton setImage:[UIImage imageNamed:@"main_icon_open"] forState:UIControlStateNormal];
    [_onlineButton setImageEdgeInsets:UIEdgeInsetsMake(0, _onlineButton.width/1.8 + 10, 0, 0)];
    _onlineButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_onlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_onlineButton];
    
    
    // vec 相关 坐席状态
    _vecButton= [UIButton buttonWithType:UIButtonTypeCustom];
    _vecButton.frame = CGRectMake(KScreenWidth - kHomeViewLeft - 55 - _onlineButton.size.width, 30, 55, 40);
//    _vecButton.backgroundColor = [UIColor yellowColor];
    [self vec_updateAgentUserState];
    
    [_vecButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_vecButton.width/1.2, 0, 0)];
    [_vecButton setImage:[UIImage imageNamed:@"main_icon_open"] forState:UIControlStateNormal];
    [_vecButton setImageEdgeInsets:UIEdgeInsetsMake(0, _vecButton.width/1.5 , 0,0 )];
    _vecButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_vecButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _vecButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_vecButton];
    
    _vecImageView = [[UIImageView alloc] init];
    
    _vecImageView.frame = CGRectMake(KScreenWidth - kHomeViewLeft - 22 - _onlineButton.size.width - _vecButton.size.width, 40, 22, 22);
//    UIImage * img = [UIImage imageWithIcon:kdianhuatianchong inFont:kfontName size:22 color:[[HDAppSkin mainSkin] contentColorWhitealpha:1] ];
    
    UIImage * img = [UIImage imageNamed:@"main_tab_icon_histroy_vec"];
    _vecImageView.image = img;
    [self addSubview:_vecImageView];
    
//    _nickLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 20, 30,KScreenWidth - kHomeViewLeft - _vecButton.size.width - _onlineButton.size.width - _vecImageView.size.width-64 , 40);

    
    if ([HDClient sharedClient].currentAgentUser.vecIndependentVideoEnable) {

        [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.leading.mas_equalTo(_headImageView.mas_trailing).offset(20);
            make.trailing.mas_equalTo(_vecImageView.mas_leading).offset(0);
            make.top.offset(30);
            make.bottom.offset(0);

        }];
    }else{

        [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.leading.mas_equalTo(_headImageView.mas_trailing).offset(20);
            make.trailing.mas_equalTo(_onlineButton.mas_leading).offset(0);
            make.top.offset(30);
            make.bottom.offset(0);

        }];


    }

    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:USER_NICENAME]) {
        _nickLabel.text = [HDClient sharedClient].currentAgentUser.nicename;
    }
}

- (void)dealloc
{

}
- (void)vec_updateAgentUserState{
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_ONLINE]) {
        [_vecButton setTitle:@"空闲" forState:UIControlStateNormal];
    } else if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_BUSY]) {
        [_vecButton setTitle:@"忙碌" forState:UIControlStateNormal];
    } else if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_REST]) {
        [_vecButton setTitle:@"小休" forState:UIControlStateNormal];
    }else if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_OFFLINE]) {
        [_vecButton setTitle:@"离开" forState:UIControlStateNormal];
    }else if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_RINGING]) {
        [_vecButton setTitle:@"振铃中" forState:UIControlStateNormal];
    }else if ([user.vecOnLineState isEqualToString:VEC_USER_STATE_PROCESSING]) {
        [_vecButton setTitle:@"通话中" forState:UIControlStateNormal];
    }else {
       
    }
}
@end
