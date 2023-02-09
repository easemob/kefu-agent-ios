//
//  HDSuspendCustomView.h
//  CustomerSystem-ios
//
//  Created by houli on 2022/5/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define WINDOWS [UIScreen mainScreen].bounds.size
typedef NS_ENUM(NSInteger, HDVECSuspendType){
    BUTTON    =0,//按钮
    IMAGEVIEW =1,//图片
    GIF       =2,//gif图
    MUSIC     =3,//音乐界面
    VIDEO     =4,//视频界面
    SCROLLVIEW =5,//滚动多图
    OTHERVIEW =6//自定义view
};
@protocol HDVECSuspendCustomViewDelegate <NSObject>
@optional
- (void)suspendCustomViewClicked:(id)sender;
- (void)dragToTheLeft;
- (void)dragToTheRight;
- (void)dragToTheTop;
- (void)dragToTheBottom;


@end
@interface HDVECSuspendView : UIView
@end
@interface HDVECSuspendImageView : UIImageView
@end
@interface HDVECSuspendButton : UIButton
@end
@interface HDVECSuspendScrollView : UIScrollView
@end
@interface HDVECSuspendCustomView : UIView
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, weak) id<HDVECSuspendCustomViewDelegate> suspendDelegate;
@property (nonatomic, strong) UIButton *customButton;
@property (nonatomic, strong) UIImageView *customImgV;
@property (nonatomic, strong) UIWebView *customGif;
@property (nonatomic, strong) HDVECSuspendScrollView *customScrollView;
@property (nonatomic, strong) HDVECSuspendView *customContentView;
- (void)initWithSuspendType:(NSString *)suspendType;
-(void)updateTimeText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
