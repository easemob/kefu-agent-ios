//
//  EMHeaderImageView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMHeaderImageView.h"

#import "UIImageView+EMWebCache.h"
@interface EMHeaderImageView ()

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *statusImageView;
@property(nonatomic,strong) UIImageView *monitorView;
@property(nonatomic,strong) UserModel *user;

@end

@implementation EMHeaderImageView

- (instancetype)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 40, 40)];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [kNotiCenter addObserver:self selector:@selector(setMonitorTip:) name:KFMonitorNoti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avatarChanged) name:@"AvatarChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusChanged) name:@"StatusChanged" object:nil];
        [self addSubview:self.headerImageView];
        [self addSubview:self.statusImageView];
        [self addSubview:self.monitorView];
        self.monitorView.hidden = ![KFManager sharedInstance].needShowMonitorTip;
    }
    return self;
}


- (UIImageView*)headerImageView
{
    if (_headerImageView == nil) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[HDClient sharedClient].currentAgentUser.avatar] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
    }
    return _headerImageView;
}

- (void)setMonitorTip:(NSNotification *)noti {
    BOOL hidden = [noti.object boolValue];
    self.monitorView.hidden = hidden;
}

- (UIImageView *)monitorView {
    if (_monitorView == nil) {
        _monitorView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - self.width/5, 0, self.width/4, self.height/4)];
        _monitorView.image = [UIImage imageNamed:@"MonitorAlarm"];
        _monitorView.hidden = YES;
    }
    return _monitorView;
}


- (UIImageView*)statusImageView
{
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - self.width/5, CGRectGetMaxY(_headerImageView.frame) - self.width/5, self.width/4, self.height/4)];
        _statusImageView.clipsToBounds = YES;
        _statusImageView.layer.cornerRadius = _statusImageView.width/2;
        UserModel *user = [self user];
        if ([user.onLineState isEqualToString:USER_STATE_HIDDEN]) {
            _statusImageView.image = [UIImage imageNamed:@"state_yellow"];
        } else if ([user.onLineState isEqualToString:USER_STATE_BUSY]){
            _statusImageView.image = [UIImage imageNamed:@"state_red"];
        } else if ([user.onLineState isEqualToString:USER_STATE_LEAVE]){
            _statusImageView.image = [UIImage imageNamed:@"state_blue"];
        } else if ([user.onLineState isEqualToString:USER_STATE_ONLINE]){
            _statusImageView.image = [UIImage imageNamed:@"state_green"];
        }
    }
    return _statusImageView;
}
#pragma mark - kvo

- (void)avatarChanged {
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[HDClient sharedClient].currentAgentUser.avatar] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
}

- (void)statusChanged {
    UserModel *user = [self user];
    if ([user.onLineState isEqualToString:USER_STATE_HIDDEN]) {
        _statusImageView.image = [UIImage imageNamed:@"state_yellow"];
    } else if ([user.onLineState isEqualToString:USER_STATE_BUSY]){
        _statusImageView.image = [UIImage imageNamed:@"state_red"];
    } else if ([user.onLineState isEqualToString:USER_STATE_LEAVE]){
        _statusImageView.image = [UIImage imageNamed:@"state_blue"];
    } else if ([user.onLineState isEqualToString:USER_STATE_ONLINE]){
        _statusImageView.image = [UIImage imageNamed:@"state_green"];
    }
}

- (UserModel *)user {
    return [HDClient sharedClient].currentAgentUser;
}


- (void)dealloc
{
}

@end
