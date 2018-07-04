//
//  KFSwitchTypeButton.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/21.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFSwitchTypeButton.h"

@interface KFSwitchTypeButton() {
    BOOL _isAdminType;
    NSString *_selectedText;
    NSString *_nomalText;
    UIImage *_selectedImage;
    UIImage *_nomalImage;
}

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@end;

@implementation KFSwitchTypeButton

- (instancetype)initWithNomalImage:(UIImage *)aNomalImage
                         nomalText:(NSString *)aNomalText
                     selectedImage:(UIImage *)aSelectImage
                      selectedText:(NSString *)aSelectText {
    if (self = [super init]) {
        _nomalText = aNomalText;
        _nomalImage = aNomalImage;
        _selectedText = aSelectText;
        _selectedImage = aSelectImage;
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
        [self addSubview:self.tipView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.height = 30;
    self.imageView.width = 30;
    self.imageView.left = 20;
    self.imageView.top = (self.height - self.imageView.height) / 2;
    
    self.textLabel.left = self.imageView.left + self.imageView.width + 10;
    self.textLabel.top = (self.height - self.textLabel.height) / 2;
    
    self.tipView.top = (self.height - self.tipView.height) / 2;
    self.tipView.left = self.width - self.tipView.width - 100;
}

- (void)setIsAdminType:(BOOL)isAdminType {
    if (isAdminType) {
        self.textLabel.text = _selectedText;
        self.imageView.image = _selectedImage;
    }else {
        self.textLabel.text = _nomalText;
        self.imageView.image = _nomalImage;
    }
    
    _isAdminType = isAdminType;
    
    [self.textLabel sizeToFit];
    [self.imageView sizeToFit];
    
    [self setNeedsDisplay];
}

- (void)showUnreadTip:(BOOL)isShow {
    if (isShow && !_isAdminType) {
        [self.tipView setHidden:NO];
    }else {
        [self.tipView setHidden:YES];
    }
}


#pragma mark - getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.autoresizingMask = UIViewAutoresizingNone;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageView;
}

- (UIView *)tipView{
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _tipView.layer.masksToBounds = YES;
        _tipView.layer.cornerRadius = 7;
        _tipView.backgroundColor = UIColor.redColor;
    }
    
    return _tipView;
}


- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:17];
    }
    
    return _textLabel;
}

@end
