//
//  KFAnswerView.h
//  AgentSDKDemo
//
//  Created by houli on 2022/6/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFManager.h"
#import "HDVECAgoraCallManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^VECClickVideoOnBlock)(UIButton *btn);
typedef void(^VECClickVideoOffBlock)(UIButton *btn);
typedef void(^VECClickVideoZoomBlock)(UIButton *btn);
@interface KFVECAnswerView : UIView
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *onBtn;
@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UIButton *offBtn;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, strong) UIButton *zoomBtn;
@property (nonatomic, strong) UIView *zoomView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, copy) VECClickVideoOnBlock vecclickOnBlock;
@property (nonatomic, copy) VECClickVideoOffBlock vecclickOffBlock;
@property (nonatomic, copy) VECClickVideoZoomBlock vecclickVideoZoomBlock;
- (void)playSoundCustom;
- (void)stopSoundCustom;

- (void)setMesage:(HDMessage *)message withRingCall:(KFRingingCallModel *)ringingCallModel;
@end

NS_ASSUME_NONNULL_END
