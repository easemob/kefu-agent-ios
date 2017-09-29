//
//  KFPromptView.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFPromptView.h"

@interface KFPromptView ()

@property(nonatomic,strong) UILabel *tipLabel;
@end

@implementation KFPromptView


+ (instancetype)shareKFPromptView {
    static dispatch_once_t oneceToken;
    static KFPromptView *promptView;
    dispatch_once(&oneceToken, ^{
        promptView = [[self alloc] init];
    });
    return promptView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.center = [UIApplication sharedApplication].keyWindow.center;
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.backgroundColor = [UIColor lightGrayColor];
        _tipLabel.layer.cornerRadius = 2;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.layer.masksToBounds = YES;
        _tipLabel.frame = CGRectMake(KScreenWidth/2-75, KScreenHeight/2-18, 150, 36);
        _tipLabel.alpha = 0.0;
        _tipLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _tipLabel;
}

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)showTipWithTitle:(NSString *)title {
    self.tipLabel.text = title;
    [[UIApplication sharedApplication].keyWindow addSubview:_tipLabel];
    [UIView animateWithDuration:0.5 animations:^{
        _tipLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self dissmiss];
    }];
}


- (void)dissmiss {
    [UIView animateWithDuration:0.5 animations:^{
        _tipLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        _tipLabel = nil;
    }];
}


@end
