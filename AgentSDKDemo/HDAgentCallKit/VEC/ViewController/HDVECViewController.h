//
//  HDCallViewController.h
//  HLtest
//
//  Created by houli on 2022/3/4.
//

#import <UIKit/UIKit.h>
#import "HDVECSuspendCustomView.h"
#import "HDVECRingingCallModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, HDVECNewCallAlertType) {
    HDVECNewCallAlertTypeVideo, //  视频界面
};
@interface HDVECViewController : UIViewController
typedef void (^VECHangUpCallback)(HDVECViewController *callVC, NSString *timeStr);
@property (nonatomic, copy) VECHangUpCallback vechangUpCallback;
@property (nonatomic, assign) HDVECSuspendType suspendType;

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
- (void)vec_showViewWithKeyCenter:(HDVECRingingCallModel *)model;
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
