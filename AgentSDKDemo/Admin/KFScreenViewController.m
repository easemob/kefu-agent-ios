//
//  KFScreenViewController.m
//  EMCSApp
//
//  Created by afanda on 5/8/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFScreenViewController.h"
#import "KFDatePicker.h"
#import "EMPickerView.h"

@implementation SessionOption
static SessionOption *sessionOption = nil;
+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionOption = [[SessionOption alloc] init];
    });
    return sessionOption;
}

@end
@implementation MessageOption
static MessageOption *messageOption = nil;
+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageOption = [[MessageOption alloc] init];
    });
    return messageOption;
}
@end

@implementation KFScreenOption

static KFScreenOption *_option = nil;
+(instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _option = [[KFScreenOption alloc] init];
    });
    return _option;
}

- (SessionOption *)sessionOption {
    return [SessionOption shareInstance];
}

- (MessageOption *)messageOption {
    return [MessageOption shareInstance];
}
@end

typedef NS_ENUM(NSUInteger, TimeIntervalType) {
    TimeIntervalTypeBegin = 382,
    TimeIntervalTypeEnd,
};

static  NSString *  const   day     = @"1d";
static  NSString *  const   week    = @"1w";
static  NSString *  const   month   = @"1M";

@interface KFScreenViewController ()<UITableViewDataSource,UITableViewDelegate,KFDatePickerDelegate,EMPickerSaveDelegate>

@end

@implementation KFScreenViewController
{
    TrendDataType _type;
    KFDatePicker *_datePicker;
    KFScreenOption *_option;
}

- (instancetype)initWithType:(TrendDataType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kTableViewBgColor;
    self.title = @"筛选";
    _option = [KFScreenOption shareInstance];
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView reloadData];
    self.tableView.tableFooterView = [UIView new];
    [self setNav];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self chooseTimeIntervalWithTimeType:TimeIntervalTypeBegin];
    }
    if (indexPath.row == 1) {
        [self chooseTimeIntervalWithTimeType:TimeIntervalTypeEnd];
    }
    if (indexPath.row == 2) {
        [self chooseType];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"开始时间:";
        cell.detailTextLabel.text = _type== TrendDataTypeSession ? _option.sessionOption.beginTimeString : _option.messageOption.beginTimeString;
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"结束时间:";
        cell.detailTextLabel.text = _type== TrendDataTypeSession ? _option.sessionOption.endTimeString : _option.messageOption.endTimeString;
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"展示方式";
        cell.detailTextLabel.text = _type== TrendDataTypeSession ? _option.sessionOption.display : _option.messageOption.display;
    }
    return cell;
}

//

- (void)chooseTimeIntervalWithTimeType:(TimeIntervalType)type {
    KFDatePicker *pick = [[KFDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    pick.delegate =  self;
    if (type == TimeIntervalTypeBegin) {
        [pick setDate:_type == TrendDataTypeSession ? _option.sessionOption.beginTimeDate : _option.messageOption.beginTimeDate];
        pick.maxDate = [self getMinDate];
        pick.tag = TimeIntervalTypeBegin;
    }
    if (type == TimeIntervalTypeEnd) {
        [pick setDate:_type == TrendDataTypeSession ? _option.sessionOption.endTimeDate : _option.messageOption.endTimeDate];
        pick.minDate = [NSDate dateWithTimeInterval:23*60*60+59 sinceDate:_type == TrendDataTypeSession ? _option.sessionOption.beginTimeDate : _option.messageOption.beginTimeDate];
        pick.tag = TimeIntervalTypeEnd;
    }
    [self.view addSubview:pick];
}

- (void)chooseType {
    EMPickerView *typePicker = [[EMPickerView alloc] initWithDataSource:@[@"日",@"周",@"月"] topHeight:20];
    typePicker.delegate = self;
    [self.view addSubview:typePicker];
}

- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index {
    NSArray *ar = @[@"1d",@"1w",@"1M"];
    if (_type == TrendDataTypeSession) {
        _option.sessionOption.display = value;
        _option.sessionOption.displayPa = ar[index];
    } else {
        _option.messageOption.display = value;
        _option.messageOption.displayPa = ar[index];
    }
    [self reloadData];
}

//选中时间
- (void)dateClicked:(UIDatePicker *)datePicker {
    NSDate *date = datePicker.date;
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    if (datePicker.tag == TimeIntervalTypeBegin) {
        if(_type == TrendDataTypeSession) {
            _option.sessionOption.beginTimeInterval = interval;
            _option.sessionOption.beginTimeString = [formatter stringFromDate:date];
            _option.sessionOption.beginTimeDate = date;
        } else {
            _option.messageOption.beginTimeInterval = interval;
            _option.messageOption.beginTimeString = [formatter stringFromDate:date];
            _option.messageOption.beginTimeDate = date;
        }
        
    }
    if (datePicker.tag == TimeIntervalTypeEnd) {
        if(_type == TrendDataTypeSession) {
            _option.sessionOption.endTimeInterval = interval;
            _option.sessionOption.endTimeString = [formatter stringFromDate:date];
            _option.sessionOption.endTimeDate = date;
        } else {
            _option.messageOption.endTimeInterval = interval;
            _option.messageOption.endTimeString = [formatter stringFromDate:date];
            _option.messageOption.endTimeDate = date;
        }
    }
    [self reloadData];
}



- (void)submit {
    if (_delegate && [_delegate respondsToSelector:@selector(submitOptions:)]) {
        [_delegate submitOptions:_option];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


//private

- (void)reloadData {
    [self.tableView reloadData];
}

- (NSDate *)getMinDate {
    NSTimeInterval curval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval endval = [_type == TrendDataTypeSession ? _option.sessionOption.endTimeDate:_option.messageOption.endTimeDate timeIntervalSince1970];
    if (curval<=endval) {
        return [NSDate date];
    }
    return _type == TrendDataTypeSession ? _option.sessionOption.endTimeDate : _option.messageOption.endTimeDate;
}

- (void)setNav {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"筛选 " style:UIBarButtonItemStylePlain target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItem = item;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
