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

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, kLeftMenu_Height)];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    _headImageView = [[EMHeaderImageView alloc] initWithFrame:CGRectMake(10, 20, 50, 50)];
    [self addSubview:_headImageView];
    
    _nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10, 30, 120, 40)];
    _nickLabel.text = user.nicename;
    _nickLabel.textColor = [UIColor whiteColor];
    _nickLabel.contentMode = NSTextAlignmentLeft;
    _nickLabel.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:_nickLabel];
    
    _onlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _onlineButton.frame = CGRectMake(KScreenWidth - kHomeViewLeft - 80 - 10, 30, 80, 40);
    if ([user.onLineState isEqualToString:USER_STATE_ONLINE]) {
        [_onlineButton setTitle:@"空闲" forState:UIControlStateNormal];
    } else if ([user.onLineState isEqualToString:USER_STATE_BUSY]) {
        [_onlineButton setTitle:@"忙碌" forState:UIControlStateNormal];
    } else if ([user.onLineState isEqualToString:USER_STATE_LEAVE]) {
        [_onlineButton setTitle:@"离开" forState:UIControlStateNormal];
    } else {
        [_onlineButton setTitle:@"隐身" forState:UIControlStateNormal];
    }
    [_onlineButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_onlineButton.width/2, 0, 0)];
    [_onlineButton setImage:[UIImage imageNamed:@"main_icon_open"] forState:UIControlStateNormal];
    [_onlineButton setImageEdgeInsets:UIEdgeInsetsMake(0, _onlineButton.width/2 + 10, 0, 0)];
    _onlineButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_onlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_onlineButton];
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

@end
