//
//  KFScreenViewController.h
//  EMCSApp
//
//  Created by afanda on 5/8/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionOption : NSObject
+(instancetype)shareInstance;
//开始时间戳[单位:秒]
@property(nonatomic,assign) NSTimeInterval beginTimeInterval;
//结束时间戳[单位:秒]
@property(nonatomic,assign) NSTimeInterval endTimeInterval;
//开始时间Date
@property(nonatomic,strong) NSDate *beginTimeDate;
//结束时间Date
@property(nonatomic,strong) NSDate *endTimeDate;
//开始时间string
@property(nonatomic,copy) NSString *beginTimeString;
//结束时间string
@property(nonatomic,copy) NSString *endTimeString;

//展示方式["日、周、月"]
@property(nonatomic,copy) NSString *display;

//展示参数["1d","1w","1M"]
@property(nonatomic,copy) NSString *displayPa;
@end

@interface MessageOption : NSObject
+(instancetype)shareInstance;
//开始时间戳[单位:秒]
@property(nonatomic,assign) NSTimeInterval beginTimeInterval;
//结束时间戳[单位:秒]
@property(nonatomic,assign) NSTimeInterval endTimeInterval;
//开始时间Date
@property(nonatomic,strong) NSDate *beginTimeDate;
//结束时间Date
@property(nonatomic,strong) NSDate *endTimeDate;
//开始时间string
@property(nonatomic,copy) NSString *beginTimeString;
//结束时间string
@property(nonatomic,copy) NSString *endTimeString;

//展示方式["日、周、月"]
@property(nonatomic,copy) NSString *display;
//展示参数["1d","1w","1M"]
@property(nonatomic,copy) NSString *displayPa;
@end

@interface KFScreenOption : NSObject

@property(nonatomic,copy) SessionOption *sessionOption;
@property(nonatomic,copy) MessageOption *messageOption;

+ (instancetype)shareInstance;

@end


@protocol KFScreenViewControllerDelegate <NSObject>

- (void)submitOptions:(KFScreenOption *)option;

@end

typedef NS_ENUM(NSUInteger, TrendDataType) {
    TrendDataTypeSession = 32,
    TrendDataTypeMessage
};

@interface KFScreenViewController : KFBaseViewController

@property(nonatomic,assign) id<KFScreenViewControllerDelegate> delegate;

- (instancetype)initWithType:(TrendDataType)type;

@end
