//
//  KFLeftItemCell.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/20.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFLeftItemCell.h"
#import "UIView+RNAdditions.h"

@interface KFLeftItemCell()
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *unreadLabel;
@end

@implementation KFLeftItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.tipImageView];
        [self addSubview:self.unreadLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.model.isShowTipImage) {
        self.tipImageView.top = 17;
        self.tipImageView.right = self.frame.size.width - 100;
        [self.tipImageView setHidden:NO];
    }else {
        [self.tipImageView setHidden:YES];
    }

    if (self.model.unreadCount != 0) {
        if (self.model.unreadCount > 100) {
            self.unreadLabel.text = @"99+";
            self.unreadLabel.font = [UIFont systemFontOfSize:11];
        }else {
            self.unreadLabel.text = [NSString stringWithFormat:@"%d",self.model.unreadCount];
            self.unreadLabel.font = [UIFont systemFontOfSize:12];
        }
        
        [self.unreadLabel setHidden:NO];
        [self.unreadLabel sizeToFit];
        self.unreadLabel.top = 17;
        self.unreadLabel.right = self.frame.size.width - 100;
    }else {
        [self.unreadLabel setHidden:YES];
    }
}

- (UILabel *)unreadLabel {
    if (!_unreadLabel) {
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _unreadLabel.textColor = UIColor.whiteColor;
        _unreadLabel.backgroundColor = UIColor.redColor;
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.layer.masksToBounds = YES;
        _unreadLabel.layer.cornerRadius = 12;
    }
    
    return _unreadLabel;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 15, 15)];
        _tipImageView.image = [UIImage imageNamed:@"MonitorAlarm"];
    }
    
    return _tipImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(KFLeftViewItem *)model {
    self.textLabel.text = model.name;
    self.imageView.image = model.image;
}

@end
