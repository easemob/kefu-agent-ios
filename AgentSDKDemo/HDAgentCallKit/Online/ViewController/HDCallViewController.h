//
//  HDCallViewController.h
//  HLtest
//
//  Created by houli on 2022/3/4.
//

#import <UIKit/UIKit.h>
#import "HDAnswerView.h"
#import "HDSuspendCustomView.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, HDNewCallAlertType) {
    HDNewCallAlertTypeVideo, //  视频界面
};
@interface HDCallViewController : UIViewController
typedef void (^HangUpCallback)(HDCallViewController *callVC, NSString *timeStr);
@property (nonatomic, copy) HangUpCallback hangUpCallback;
@property (nonatomic, assign) BOOL  isShow;//是否已经调用过show方法
@property (nonatomic, strong) HDAnswerView *hdAnswerView;
@property (nonatomic, assign) BOOL isVisitorSend;
@property (nonatomic, assign) SuspendType suspendType;

/** 单利创建 - Method
*/
 
+ (instancetype)sharedManager;
 
/** 单利销毁 - Method
*/
- (void)removeSharedManager;


/**
 *  视频通话界面
 */
+(id)alertCallWithView:(UIView *)view ;
/**
 *  界面展示
 */
- (void)showViewWithKeyCenter:(HDMessage *)message withType:(HDVideoCallType)type;
/**
 *  界面隐藏
 */
-(void)hideView;

/**
 *  界面移除
 */
- (void)removeView;

@end

NS_ASSUME_NONNULL_END
