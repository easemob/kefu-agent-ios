//
//  DXTimeFilterView.m
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXTimeFilterView.h"

#define kAnimaTime 0.25

@interface MyButton : UIButton

@property (nonatomic) UILabel *myTitleLabel;

@end

@implementation MyButton

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_myTitleLabel == nil) {
        _myTitleLabel = [[UILabel alloc] init];
        [self addSubview:_myTitleLabel];
    }
    _myTitleLabel.frame = CGRectMake(10, 0, CGRectGetWidth(frame)-10, CGRectGetHeight(frame));
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _myTitleLabel.textColor = RGBACOLOR(27, 168, 237, 1);
    } else {
        _myTitleLabel.textColor = RGBACOLOR(0x09, 0x09, 0x09, 1);
    }
}

@end

@implementation DXTimeFilterView
{
    UIButton *_btn;
    UIButton *_close;
    MyButton *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isShow = NO;
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd";
        _formatter.timeZone = [NSTimeZone localTimeZone];
        [self setupSubviews];
    }
    
    return self;
}

#pragma mark - property

- (DXDatePickerView *)datePickerView
{
    if (_datePickerView == nil) {
        CGFloat height = [DXDatePickerView datePickerViewHeight];
        _datePickerView = [[DXDatePickerView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - height - 44, self.frame.size.width, height)];
        _datePickerView.delegate = self;
        _datePickerView.datePicker.maximumDate = [NSDate date];
    }
    
    return _datePickerView;
}

#pragma mark - layout

- (void)setupSubviews
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(20, 32, self.frame.size.width - 40, 355)];
    _contentView.layer.cornerRadius = 4.f;
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _close = [UIButton buttonWithType:UIButtonTypeCustom];
    _close.frame = CGRectMake(CGRectGetMinX(_contentView.frame) + CGRectGetWidth(_contentView.frame) - 32 + 6, 0, 32, 32);
    [_close setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    [_close setImage:[UIImage imageNamed:@"icon_close_select"] forState:UIControlStateHighlighted];
    [_close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_close];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_contentView.frame) - 155, _contentView.frame.size.width, 0.5)];
    line1.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
//    [_contentView addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, _contentView.frame.size.height - 70.5, _contentView.frame.size.width, 0.5)];
    line2.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [_contentView addSubview:line2];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(_contentView.frame.size.width - 80, _contentView.frame.size.height - 51, 70, 32)];
    [okButton setTitle:@"查询" forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [okButton addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
    [okButton setBackgroundImage:[[UIImage imageNamed:@"button_blue2"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateNormal];
    [okButton setBackgroundImage:[[UIImage imageNamed:@"button_blue2_select"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateHighlighted];
    [_contentView addSubview:okButton];
    
    NSArray *titles = @[@"今天", @"昨天", @"本周", @"本月", @"上个月"];
    float width = _contentView.frame.size.width;
    float height = 44;
    for (int i = 0; i < [titles count]; i++) {
        int index = i;
        MyButton *button = [[MyButton alloc] initWithFrame:CGRectMake(0, 40 * (i), width, height)];
        if (index == 2) {
            button.selected = YES;
            _selectedButton = button;
            _btn = button;
        }
        button.tag = index + 1;
        [button.myTitleLabel setText:[titles objectAtIndex:index]];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button addTarget:self action:@selector(filterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -width/2 - 50, 0, 0)];
        [button setImage:[UIImage imageNamed:@"icon_select_right"] forState:UIControlStateSelected];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, width - 47, 0, 0)];
        [_contentView addSubview:button];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) - 0.5, _contentView.frame.size.width, 0.5)];
        line.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        [_contentView addSubview:line];
    }
    
    _titleLabel = [[MyButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame), CGRectGetWidth(_contentView.frame), 40)];
    _titleLabel.tag = 8;
    [_titleLabel.myTitleLabel setText:@"指定时间段"];
    _titleLabel.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_titleLabel addTarget:self action:@selector(startDateAction) forControlEvents:UIControlEventTouchUpInside];
    [_titleLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, -width/2 - 50, 0, 0)];
    [_titleLabel setImage:[UIImage imageNamed:@"icon_select_right"] forState:UIControlStateSelected];
    [_titleLabel setImageEdgeInsets:UIEdgeInsetsMake(0, width - 37, 0, 0)];
    [_contentView addSubview:_titleLabel];
    
    width = (_contentView.frame.size.width - _titleLabel.frame.size.width - 20 - 20) / 2;
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(line1.frame) + 40, CGRectGetWidth(_contentView.frame)/2 - 20, 35)];
    _startButton.backgroundColor = [UIColor colorWithRed: 235 / 255.0 green: 235 / 255.0 blue: 235 / 255.0 alpha:1.0];
    [_startButton addTarget:self action:@selector(startDateAction) forControlEvents:UIControlEventTouchUpInside];
    [_startButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _startButton.clipsToBounds = YES;
    _startButton.layer.cornerRadius = 5;
    [_contentView addSubview:_startButton];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_startButton.frame) + 5, CGRectGetMaxY(line1.frame) + 57, 10, 0.5)];
    line3.backgroundColor = [UIColor lightGrayColor];
    [_contentView addSubview:line3];
    
    _endButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(line3.frame) + 5, CGRectGetMaxY(line1.frame) + 40, CGRectGetWidth(_contentView.frame)/2 - 20, 35)];
    [_endButton setBackgroundColor:[UIColor colorWithRed: 235 / 255.0 green: 235 / 255.0 blue: 235 / 255.0 alpha:1.0]];
    [_endButton addTarget:self action:@selector(endDateAction) forControlEvents:UIControlEventTouchUpInside];
    [_endButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _endButton.clipsToBounds = YES;
    _endButton.layer.cornerRadius = 5;
    [_contentView addSubview:_endButton];
    
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_contentView.frame), self.frame.size.width, self.frame.size.height - _contentView.frame.size.height)];
    [self addSubview:tapView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [tapView addGestureRecognizer:tap];
    
    _endDate = [[DXTimeFilterView curWeek] objectForKey:@"last"];
    _startDate = [[DXTimeFilterView curWeek] objectForKey:@"first"];
    
    [_startButton setTitle:[_formatter stringFromDate:_startDate] forState:UIControlStateNormal];
    [_endButton setTitle:[_formatter stringFromDate:_endDate] forState:UIControlStateNormal];

}

#pragma mark - DXDatePickerViewDelegate

- (void)datePickerDidSelectedDate:(NSDate *)date
{
    [UIView animateWithDuration:kAnimaTime animations:^{
        _contentView.top = 32;
        _close.top = 0;
    } completion:^(BOOL finished) {
        if (_startButton.selected) {
            _startDate = [_formatter dateFromString:[_formatter stringFromDate:date]];
            [_startButton setTitle:[_formatter stringFromDate:date] forState:UIControlStateNormal];
            if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
                _startButton.selected = NO;
            }
        }
        else if (_endButton.selected){
            _endDate = [_formatter dateFromString:[_formatter stringFromDate:date]];
            _endDate = [_endDate dateByAddingTimeInterval:86400-1];
            [_endButton setTitle:[_formatter stringFromDate:date] forState:UIControlStateNormal];
            if ([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
                _endButton.selected = NO;
            }
            if ([_endDate timeIntervalSince1970] < [_startDate timeIntervalSince1970]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"结束时间不能小于开始时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [self performSelector:@selector(endDateAction) withObject:nil afterDelay:0.5];
            }
        }
    }];
}

#pragma mark - action

- (void)filterButtonAction:(id)sender
{
    if (sender == nil) {
        return;
    }
    
    _titleLabel.selected = NO;
    
    UIButton *button = (UIButton *)sender;
    if (button == _selectedButton) {
        return;
    }
    
    if (_selectedButton.tag == button.tag) {
        button.selected = NO;
        _selectedButton = nil;
    }
    else{
        _selectedButton.selected = NO;
        button.selected = YES;
        _selectedButton = button;
    }
    
    _startDate = nil;
    _endDate = nil;
    [_startButton setTitle:@"" forState:UIControlStateNormal];
    [_endButton setTitle:@"" forState:UIControlStateNormal];
    
    NSInteger index = _selectedButton.tag;
    _endDate = [NSDate date];
    NSLog(@"%@",[_formatter stringFromDate:_endDate]);
    _endDate =[[_formatter dateFromString:[_formatter stringFromDate:_endDate]] dateByAddingTimeInterval:86400];
    _endDate = [_formatter dateFromString:[_formatter stringFromDate:_endDate]];
    int dayCount = 0;
    switch (index) {
        case 1:
        {
            _endDate = [_endDate dateByAddingTimeInterval:-1];
            dayCount = -1;
            _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
        }
            break;
        case 2:
        {
            _endDate = [_endDate dateByAddingTimeInterval:-1*86400 - 1];
            dayCount = -1;
            _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
        }
            break;
        case 3:
        {
            NSDictionary *weekDic = [DXTimeFilterView curWeek];
            _endDate = [weekDic objectForKey:@"last"];
            _startDate = [weekDic objectForKey:@"first"];
        }
            break;
        case 4:
        {
            NSDictionary *monthDic = [DXTimeFilterView curMonth];
            _endDate = [monthDic objectForKey:@"last"];
            _startDate = [monthDic objectForKey:@"first"];
        }
            break;
        case 5:
        {
            NSDictionary *lastMonthDic = [DXTimeFilterView lastMonth];
            _endDate = [lastMonthDic objectForKey:@"last"];
            _startDate = [lastMonthDic objectForKey:@"first"];
        }
            break;
        case 6:
        {
            dayCount = -180;
            _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400];
        }
            break;
        default:
            break;
    }
    [_startButton setTitle:[_formatter stringFromDate:_startDate] forState:UIControlStateNormal];
    [_endButton setTitle:[_formatter stringFromDate:_endDate] forState:UIControlStateNormal];
}

- (void)startDateAction
{
    _titleLabel.selected = YES;
    _selectedButton.selected = NO;
    _selectedButton = nil;
//    _startDate = nil;
    
    [UIView animateWithDuration:kAnimaTime animations:^{
        _contentView.top =  -_contentView.height/2;
        _close.top = -_contentView.height/2;
    } completion:^(BOOL finished) {
        [self addSubview:self.datePickerView];
        _startButton.selected = YES;
        _endButton.selected = NO;
        if (_startDate) {
            [self.datePickerView.datePicker setDate:_startDate animated:YES];
        }
    }];
}

- (void)endDateAction
{
    _titleLabel.selected = YES;
    _selectedButton.selected = NO;
    _selectedButton = nil;
//    _endDate = nil;
    
    [UIView animateWithDuration:kAnimaTime animations:^{
        _contentView.top =  -_contentView.height/2;
        _close.top = -_contentView.height/2;
    } completion:^(BOOL finished) {
        [self addSubview:self.datePickerView];
        _endButton.selected = YES;
        _startButton.selected = NO;
        if (_endDate) {
            [self.datePickerView.datePicker setDate:_endDate animated:YES];
        }
    }];
}

- (void)resetAction
{
    _selectedButton.selected = NO;
    _btn.selected = YES;
    _selectedButton = _btn;
    _startDate = nil;
    _endDate = nil;
    [_startButton setTitle:@"" forState:UIControlStateNormal];
    [_endButton setTitle:@"" forState:UIControlStateNormal];
    [self.datePickerView removeFromSuperview];
}

- (void)okAction
{
    [UIView animateWithDuration:kAnimaTime animations:^{
        _contentView.top = 32;
        _close.top = 0;
    } completion:^(BOOL finished) {
    }];
    
    if (_selectedButton) {
        NSInteger index = _selectedButton.tag;
        //TODO:
        _endDate = [NSDate date];
        _endDate =[[_formatter dateFromString:[_formatter stringFromDate:_endDate]] dateByAddingTimeInterval:86400];
        int dayCount = 0;
        switch (index) {
            case 1:
            {
                _endDate = [_endDate dateByAddingTimeInterval:-1];
                dayCount = -1;
                _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
                _title = @"今天";
            }
                break;
            case 2:
            {
                _endDate = [_endDate dateByAddingTimeInterval:-1*86400 - 1];
                dayCount = -1;
                _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
                _title = @"昨天";
            }
                break;
            case 3:
            {
                NSDictionary *weekDic = [DXTimeFilterView curWeek];
                _endDate = [weekDic objectForKey:@"last"];
                _startDate = [weekDic objectForKey:@"first"];
                _title = @"本周";
            }
                break;
            case 4:
            {
                NSDictionary *monthDic = [DXTimeFilterView curMonth];
                _endDate = [monthDic objectForKey:@"last"];
                _startDate = [monthDic objectForKey:@"first"];
                _title = @"本月";
            }
                break;
            case 5:
            {
                NSDictionary *lastMonthDic = [DXTimeFilterView lastMonth];
                _endDate = [lastMonthDic objectForKey:@"last"];
                _startDate = [lastMonthDic objectForKey:@"first"];
                _title = @"上个月";
            }
                break;
            case 6:
            {
                dayCount = -180;
                _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400];
            }
                break;
            default:
                break;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(timeFilterStartDate:endDate:title:)]) {
            [_delegate timeFilterStartDate:_startDate endDate:_endDate title:_title];
        }
        [self hide];
    } else {
        if (_startButton.currentTitle.length == 0 || _endButton.currentTitle.length == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请完整填写开始时间和结束时间" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            [self.datePickerView removeFromSuperview];
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(timeFilterStartDate:endDate:title:)]) {
            [_delegate timeFilterStartDate:_startDate endDate:[_endDate dateByAddingTimeInterval:86400] title:@"指定时间"];
        }
        [self hide];
    }
}

- (void)hide
{
    if (_startButton.selected || _endButton.selected) {
        _startButton.selected = NO;
        _endButton.selected = NO;
        [self.datePickerView removeFromSuperview];
    }
    else{
        _isShow = NO;
        [self removeFromSuperview];
    }
}

+ (NSDictionary*)curWeek
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:now];
    
    // 得到星期几
    // 1(星期天) 2(星期二) 3(星期三) 4(星期四) 5(星期五) 6(星期六) 7(星期天)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    NSLog(@"weekDay:%ld   day:%ld",weekDay,day);
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 1;
        lastDiff = 0;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 8 - weekDay;
    }
    
    NSLog(@"firstDiff:%ld   lastDiff:%ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    lastDayOfWeek = [lastDayOfWeek dateByAddingTimeInterval:-1];
    return @{@"first":firstDayOfWeek,@"last":lastDayOfWeek};
}

+ (NSDictionary*)curMonth
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:now];
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [firstDayComp setDay:1];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [lastDayComp setMonth:[comp month] + 1];
    [lastDayComp setDay:1];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    lastDayOfWeek = [lastDayOfWeek dateByAddingTimeInterval:-1];
    return @{@"first":firstDayOfWeek,@"last":lastDayOfWeek};
}

+ (NSDictionary*)lastMonth
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSDayCalendarUnit
                                         fromDate:now];
    
    NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [firstDayComp setMonth:[comp month] - 1];
    [firstDayComp setDay:1];
    NSDate *firstDayOfWeek= [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [lastDayComp setDay:1];
    NSDate *lastDayOfWeek= [calendar dateFromComponents:lastDayComp];
    lastDayOfWeek = [lastDayOfWeek dateByAddingTimeInterval:-1];
    return @{@"first":firstDayOfWeek,@"last":lastDayOfWeek};
}


@end
