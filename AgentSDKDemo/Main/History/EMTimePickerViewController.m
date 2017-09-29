//
//  EMTimePickerViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMTimePickerViewController.h"

@interface EMTimePickerViewController ()
{
    BOOL _isSettingLeft;
}

@property (strong, nonatomic) UIButton *saveButton;

@property (strong, nonatomic) UIView *headerButtonView;
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIDatePicker *timePicker;

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSDateFormatter *formatterDate;
@property (strong, nonatomic) NSDateFormatter *formatterTime;

@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;

@end

@implementation EMTimePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"时间";
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.hidden = YES;
    
    [self.view addSubview:self.headerButtonView];
    [self.view addSubview:self.dateLabel];
    [self.view addSubview:self.datePicker];
    if (KScreenHeight > 568) {
        [self.view addSubview:self.timeLabel];
        [self.view addSubview:self.timePicker];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
    
    [self.datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    [self.timePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    if (_isSettingLeft) {
        [self leftButtonAction];
    } else {
        [self rightButtonAction];
    }
}

#pragma mark - getter

- (void)setIsSettingLeft:(BOOL)isSettingLeft
{
    _isSettingLeft = isSettingLeft;
}

- (UILabel*)startTimeLabel
{
    if (_startTimeLabel == nil) {
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, KScreenWidth/2, 30)];
        _startTimeLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _startTimeLabel.text = [self.formatter stringFromDate:self.startTime];
        _startTimeLabel.font = [UIFont systemFontOfSize:15];
        _startTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _startTimeLabel;
}

- (UILabel*)endTimeLabel
{
    if (_endTimeLabel == nil) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, KScreenWidth/2, 30)];
        _endTimeLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _endTimeLabel.text = [self.formatter stringFromDate:self.endTime];
        _endTimeLabel.font = [UIFont systemFontOfSize:15];
        _endTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _endTimeLabel;
}

- (NSDateFormatter*)formatter
{
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return _formatter;
}

- (NSDateFormatter*)formatterDate
{
    if (_formatterDate == nil) {
        _formatterDate = [[NSDateFormatter alloc] init];
        [_formatterDate setDateFormat:@"yyyy-MM-dd"];
    }
    return _formatterDate;
}

- (NSDateFormatter*)formatterTime
{
    if (_formatterTime == nil) {
        _formatterTime = [[NSDateFormatter alloc] init];
        [_formatterTime setDateFormat:@"HH:mm"];
    }
    return _formatterTime;
}

- (UILabel*)dateLabel
{
    if (_dateLabel == nil) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerButtonView.frame), KScreenWidth, 50)];
        _dateLabel.text = @"设置日期";
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _dateLabel.font = [UIFont systemFontOfSize:17.f];
    }
    return _dateLabel;
}

- (UILabel*)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.datePicker.frame), KScreenWidth, 50)];
        _timeLabel.text = @"设置时间";
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _timeLabel.font = [UIFont systemFontOfSize:17.f];
    }
    return _timeLabel;
}

- (UIDatePicker*)datePicker
{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.frame = CGRectMake(0, CGRectGetMaxY(self.headerButtonView.frame) + 50, KScreenWidth, _datePicker.height);
        _datePicker.backgroundColor = [UIColor whiteColor];
        if (KScreenHeight > 568) {
            _datePicker.datePickerMode = UIDatePickerModeDate;
        } else {
            _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSDate *minDate = [formatter dateFromString:@"2012-01-01"];
        _datePicker.minimumDate = minDate;
    }
    return _datePicker;
}

- (UIDatePicker*)timePicker
{
    if (_timePicker == nil) {
        _timePicker = [[UIDatePicker alloc] init];
        _timePicker.frame = CGRectMake(0, CGRectGetMaxY(self.datePicker.frame) + 50, KScreenWidth, _timePicker.height);
        _timePicker.backgroundColor = [UIColor whiteColor];
        _timePicker.datePickerMode = UIDatePickerModeTime;
    }
    return _timePicker;
}

- (UIView*)headerButtonView
{
    if (_headerButtonView == nil) {
        _headerButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 70)];
        _headerButtonView.backgroundColor = [UIColor whiteColor];
        [_headerButtonView addSubview:self.rightButton];
        [_headerButtonView addSubview:self.leftButton];
        [_headerButtonView addSubview:self.selectView];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 0.5f, KScreenWidth, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_headerButtonView addSubview:line];
    }
    return _headerButtonView;
}

- (UIView*)selectView
{
    if (_selectView == nil) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 1.5f, KScreenWidth/2, 1.f)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(25.f, 0, KScreenWidth/2 - 50.f, 1.5f)];
        line.backgroundColor = RGBACOLOR(25, 163, 255, 1);
        [_selectView addSubview:line];
    }
    return _selectView;
}

- (UIButton*)leftButton
{
    if (_leftButton == nil) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, 0, KScreenWidth/2, 65.f);
        [_leftButton setTitle:@"开始时间" forState:UIControlStateNormal];
        [_leftButton setTitleEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
        [_leftButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_leftButton addSubview:self.startTimeLabel];
    }
    return _leftButton;
}

- (UIButton*)rightButton
{
    if (_rightButton == nil) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 65.f);
        [_rightButton setTitle:@"结束时间" forState:UIControlStateNormal];
        [_rightButton setTitleEdgeInsets:UIEdgeInsetsMake(-15, 0, 0, 0)];
        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_rightButton addSubview:self.endTimeLabel];
    }
    return _rightButton;
}

- (UIButton*)saveButton
{
    if (_saveButton == nil) {
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitleColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1) forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

#pragma mark - action
- (void)saveAction
{
    if (_startTime && _endTime) {
        if ([_startTime timeIntervalSince1970] > [_endTime timeIntervalSince1970]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"设置的结束时间小于开始时间" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveStartDate:endDate:)]) {
        [self.delegate saveStartDate:_startTime endDate:_endTime];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftButtonAction
{
    _isSettingLeft = YES;
    [self.datePicker setDate:_startTime animated:YES];
    [self.timePicker setDate:_startTime animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.selectView.left = 0;
    }];
}

- (void)rightButtonAction
{
    _isSettingLeft = NO;
    [self.datePicker setDate:_endTime animated:YES];
    [self.timePicker setDate:_endTime animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.selectView.left = KScreenWidth/2;
    }];
}

- (void)dateChange:(id)sender
{
    NSString *dateString;
    if (KScreenHeight > 568) {
        dateString = [NSString stringWithFormat:@"%@ %@",[self.formatterDate stringFromDate:self.datePicker.date],[self.formatterTime stringFromDate:self.timePicker.date]];
    } else {
        dateString = [NSString stringWithFormat:@"%@",[self.formatter stringFromDate:self.datePicker.date]];
    }
    if (_isSettingLeft) {
        _startTime = [self.formatter dateFromString:dateString];
        _startTimeLabel.text = [self.formatter stringFromDate:_startTime];
    } else {
        _endTime = [self.formatter dateFromString:dateString];
        _endTimeLabel.text = [self.formatter stringFromDate:_endTime];
    }
}

@end
