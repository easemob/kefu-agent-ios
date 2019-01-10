//
//  ClientInforHeaderView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "ClientInforHeaderView.h"

#define kClientInforHeaderViewHeight 120.f

@interface ClientInforHeaderView ()

@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UILabel *nicknameLabel;
@property (strong, nonatomic) UIImageView *originTypeImage;

@end

@implementation ClientInforHeaderView


- (instancetype)initWithniceName:(NSString *)nickName tagImage:(UIImage *)tagImage {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, kClientInforHeaderViewHeight)];
    if (self) {
        self.backgroundColor = kNavBarBgColor;
        [self addSubview:self.headerImageView];
        [self setWithniceName:nickName tagImage:tagImage];
    }
    return self;
}


- (UIImageView*)originTypeImage
{
    if (_originTypeImage == nil) {
        _originTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nicknameLabel.frame), self.nicknameLabel.center.y - 10, 20, 20)];
        _originTypeImage.layer.cornerRadius = _originTypeImage.width/2;
        _originTypeImage.layer.masksToBounds = YES;
        [self addSubview:_originTypeImage];
    }
    return _originTypeImage;
}

- (UIImageView*)headerImageView
{
    if (_headerImageView == nil) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((KScreenWidth-48)/2, 0, 48, 48)];
        _headerImageView.userInteractionEnabled = YES;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.image = [UIImage imageNamed:@"default_agent_avatar"];
        [self addSubview:_headerImageView];
    }
    return _headerImageView;
}

- (UILabel*)nicknameLabel
{
    if (_nicknameLabel == nil) {
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth-200)/2, CGRectGetMaxY(_headerImageView.frame), 200, 40.f)];
        _nicknameLabel.font = [UIFont boldSystemFontOfSize:18];
        _nicknameLabel.textColor = [UIColor whiteColor];
        _nicknameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nicknameLabel];
    }
    return _nicknameLabel;
}

- (void)setWithniceName:(NSString *)nickName tagImage:(UIImage *)tagImage {
    self.nicknameLabel.text = nickName;
    CGSize textBlockMinSize = {CGFLOAT_MAX, self.nicknameLabel.height};
    CGSize retSize;
    retSize = [nickName boundingRectWithSize:textBlockMinSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}
                                     context:nil].size;
    self.nicknameLabel.width = retSize.width;
    self.nicknameLabel.left = (KScreenWidth - retSize.width)/2;
    self.originTypeImage.image = tagImage;
    self.originTypeImage.left = CGRectGetMaxX(self.nicknameLabel.frame) + 5.f;
}
@end
