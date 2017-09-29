//
//  DXTimeFilterView.h
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DXDatePickerView.h"

@protocol DXTimeFilterViewDelegate <NSObject>

- (void)timeFilterStartDate:(NSDate *)startDate
                    endDate:(NSDate *)endDate
                      title:(NSString*)title;

@end

@interface DXTimeFilterView : UIView<DXDatePickerViewDelegate>
{
    UIButton *_startButton;
    UIButton *_endButton;
    UIButton *_selectedButton;
    
    NSDate *_startDate;
    NSDate *_endDate;
    NSString *_title;
    NSDateFormatter *_formatter;
}

@property (weak, nonatomic) id<DXTimeFilterViewDelegate> delegate;

@property (nonatomic) BOOL isShow;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) DXDatePickerView *datePickerView;

- (instancetype)initWithFrame:(CGRect)frame;

+ (NSDictionary*)curWeek;

+ (NSDictionary*)curMonth;

+ (NSDictionary*)lastMonth;

@end
