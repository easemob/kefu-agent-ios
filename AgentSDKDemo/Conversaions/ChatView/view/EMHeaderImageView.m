//
//  EMHeaderImageView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMHeaderImageView.h"

#import "UIImageView+WebCache.h"

@interface EMHeaderImageView ()

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *statusImageView;

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
        [[HDNetworkManager shareInstance].currentUser addObserver:self forKeyPath:USER_STATE options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [[HDNetworkManager shareInstance].currentUser addObserver:self forKeyPath:USER_AVATAR options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        [self addSubview:self.headerImageView];
        [self addSubview:self.statusImageView];
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
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http:%@",[[HDNetworkManager shareInstance].currentUser.avatar encodeToPercentEscapeString]]] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
    }
    return _headerImageView;
}

- (UIImageView*)statusImageView
{
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame) - self.width/5, CGRectGetMaxY(_headerImageView.frame) - self.width/5, self.width/4, self.height/4)];
        _statusImageView.clipsToBounds = YES;
        _statusImageView.layer.cornerRadius = _statusImageView.width/2;
        if ([[HDNetworkManager shareInstance].currentUser.onLineState isEqualToString:USER_STATE_OFFLINE]) {
            _statusImageView.backgroundColor = RGBACOLOR(238, 190, 77, 1);
        } else if ([[HDNetworkManager shareInstance].currentUser.onLineState isEqualToString:USER_STATE_BUSY]){
            _statusImageView.backgroundColor = RGBACOLOR(255, 48, 0, 1);
        } else if ([[HDNetworkManager shareInstance].currentUser.onLineState isEqualToString:USER_STATE_LEAVE]){
            _statusImageView.backgroundColor = RGBACOLOR(27, 168, 237, 1);
        } else if ([[HDNetworkManager shareInstance].currentUser.onLineState isEqualToString:USER_STATE_ONLINE]){
            _statusImageView.backgroundColor = RGBACOLOR(90, 232, 37, 1);
        }
    }
    return _statusImageView;
}
#pragma mark - kvo

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    if([keyPath isEqualToString:USER_STATE]) {
//        if ([[DXCSManager shareManager].loginUser.onLineState isEqualToString:USER_STATE_OFFLINE]) {
//            _statusImageView.backgroundColor = RGBACOLOR(238, 190, 77, 1);
//        } else if ([[DXCSManager shareManager].loginUser.onLineState isEqualToString:USER_STATE_BUSY]){
//            _statusImageView.backgroundColor = RGBACOLOR(255, 48, 0, 1);
//        } else if ([[DXCSManager shareManager].loginUser.onLineState isEqualToString:USER_STATE_LEAVE]){
//            _statusImageView.backgroundColor = RGBACOLOR(27, 168, 237, 1);
//        } else if ([[DXCSManager shareManager].loginUser.onLineState isEqualToString:USER_STATE_ONLINE]){
//            _statusImageView.backgroundColor = RGBACOLOR(90, 232, 37, 1);
//        }
//
//    } else if ([keyPath isEqualToString:USER_AVATAR]) {
//        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http:%@",[[DXCSManager shareManager].loginUser.avatar encodeToPercentEscapeString]]] placeholderImage:[UIImage imageNamed:@"default_agent_avatar"]];
//    }
}

- (void)dealloc
{
    [[HDNetworkManager shareInstance].currentUser removeObserver:self forKeyPath:USER_STATE];
    [[HDNetworkManager shareInstance].currentUser removeObserver:self forKeyPath:USER_AVATAR];
}

@end
