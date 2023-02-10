//
//  HDAnswerView.h
//  HLtest
//
//  Created by houli on 2022/3/15.
//

#import <UIKit/UIKit.h>
/*
 *
 */
typedef NS_ENUM (NSInteger, HDVECVideoCallType) {
    HDVECVideoCallDirectionSend    = 0,    /**  发送视频邀请   */
    HDVECVideoCallDirectionReceive,           /**接受视频邀请  */
};

NS_ASSUME_NONNULL_BEGIN
typedef void(^VECClickOnBlock)(UIButton *btn);
typedef void(^VECClickOffBlock)(UIButton *btn);
typedef void(^VECClickHangUpBlock)(UIButton *btn);
@interface HDVECAnswerView : UIView
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIButton *onBtn;
@property (nonatomic, strong) UIButton *offBtn;
@property (nonatomic, strong) UIButton *hangUpBtn;
@property (nonatomic, strong) UILabel *answerLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, copy) VECClickOnBlock vecclickOnBlock;
@property (nonatomic, copy) VECClickOffBlock vecclickOffBlock;
@property (nonatomic, copy) VECClickHangUpBlock vecclickHangUpBlock;
@property (nonatomic, assign) HDVECVideoCallType callType;


@end

NS_ASSUME_NONNULL_END
