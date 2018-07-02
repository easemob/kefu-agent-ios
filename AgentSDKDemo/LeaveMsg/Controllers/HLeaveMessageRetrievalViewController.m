//
//  HLeaveMessageRetrievalViewController.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/26.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HLeaveMessageRetrievalViewController.h"
#import "EMPickerView.h"
#import "HTimePickerView.h"

@interface HLeaveMessageRetrievalViewController () <UITableViewDataSource, UITableViewDelegate, EMPickerSaveDelegate, HTimePickerViewDelegate>
{
    NSIndexPath *_selectIndexPath;
    NSInteger _timeIndex;
    NSInteger _agentIndex;
    NSInteger _typeIndex;
    NSInteger _channelIndex;
    NSInteger _timeSelected;
}
@property (nonatomic, strong) UIView *timeSelectView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *agentLabel;
@property (weak, nonatomic) IBOutlet UITextField *customerTextField;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;

@property (nonatomic, strong) UIButton *startTimeBtn;
@property (nonatomic, strong) UIButton *endTimeBtn;


@property (nonatomic, strong) HTimePickerView *timePicker;
@property (nonatomic, strong) EMPickerView *pickerView;

@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) UIBarButtonItem *leftItem;

@end

@implementation HLeaveMessageRetrievalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义筛选";
    self.navigationItem.rightBarButtonItem = self.rightItem;
    self.navigationItem.leftBarButtonItem = self.leftItem;
    self.tableView.tableFooterView = [self tableViewFootView];
    [self updateInfo];
}

- (NSArray *)dateArray{
    return @[@"指定时间", @"今天", @"昨天", @"本周", @"本月", @"上月"];
}

- (NSArray *)agentsArray {
    return @[@"未分配", HDClient.sharedClient.currentAgentUser.nicename];
}

- (NSArray *)messageTypesArray {
    return @[@"全部留言", @"未处理", @"处理中", @"已解决"];
}

- (NSArray *)channelsArray {
    return @[@"全部渠道", @"网页", @"App", @"微博"];
}

- (UIBarButtonItem *)rightItem {
    if (!_rightItem) {
        _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(searchAction:)];
        [_rightItem setTintColor:UIColor.whiteColor];
    }
    
    return _rightItem;
}

- (UIBarButtonItem *)leftItem {
    if (!_leftItem) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    return _leftItem;
}

- (EMPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[EMPickerView alloc] initWithDataSource:nil];
        _pickerView.delegate = self;
    }
    
    return _pickerView;
}

- (HTimePickerView *)timePicker {
    if (!_timePicker) {
        _timePicker = [[HTimePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        _timePicker.delegate = self;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        _timePicker.formatter = dateFormatter;
    }
    
    return _timePicker;
}

- (UIButton *)startTimeBtn {
    if (!_startTimeBtn) {
        _startTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startTimeBtn setTitle:@"" forState:UIControlStateNormal];
        [_startTimeBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _startTimeBtn.frame = CGRectMake(0, 0, 140, 40);
        _startTimeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_startTimeBtn addTarget:self action:@selector(startBtnAction:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _startTimeBtn;
}

- (UIButton *)endTimeBtn {
    if(!_endTimeBtn) {
        _endTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_endTimeBtn setTitle:@"" forState:UIControlStateNormal];
        [_endTimeBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _endTimeBtn.frame = CGRectMake(0, 0, 140, 40);
        _endTimeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_endTimeBtn addTarget:self action:@selector(endBtnAction:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _endTimeBtn;
}

- (UIView *)tableViewFootView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectInset(footView.frame, 5, 5);
    CGRect frame = btn.frame;
    frame.origin.y = 0;
    btn.frame = frame;
    [btn setTitle:@"清空筛选" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clearRetrievalAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = UIColor.whiteColor;
    [footView addSubview:btn];
    return footView;
}

- (UIView *)timeSelectView {
    if (!_timeSelectView) {
        _timeSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 120)];
        _timeSelectView.backgroundColor = UIColor.whiteColor;
        UIView *subView = [[UIView alloc] initWithFrame:CGRectInset(_timeSelectView.frame, 10, 10)];
        subView.layer.masksToBounds = YES;
        subView.layer.cornerRadius = 5;
        subView.layer.borderWidth = 0.5;
        subView.layer.borderColor = UIColor.lightGrayColor.CGColor;
        [_timeSelectView addSubview:subView];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(subView.frame.origin.x, _timeSelectView.frame.size.height / 2, subView.frame.size.width, 0.5)];
        lineView.backgroundColor = UIColor.lightGrayColor;
        lineView.alpha = 0.5;
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
        label1.text = @"开始时间";
        [label1 sizeToFit];
        CGRect frame = label1.frame;
        frame.origin.y = (subView.frame.size.height / 2 - frame.size.height) / 2;
        frame.origin.x = 8;
        label1.frame = frame;
        [subView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
        label2.text = @"结束时间";
        [label2 sizeToFit];
        frame = label2.frame;
        frame.origin.y = (subView.frame.size.height / 2 - frame.size.height) / 2 + subView.frame.size.height / 2;
        frame.origin.x = 8;
        label2.frame = frame;
        [subView addSubview:label2];
        [_timeSelectView addSubview:lineView];
        
        CGFloat x = label1.frame.origin.x + label1.frame.size.width + 40;
        CGFloat y = label1.frame.origin.y;
        self.startTimeBtn.frame = CGRectMake(x, y, _timeSelectView.frame.size.width - x - 55, label1.frame.size.height);
        
        [subView addSubview:self.startTimeBtn];
        
        x = label2.frame.origin.x + label2.frame.size.width + 40;
        y = label2.frame.origin.y;
        self.endTimeBtn.frame = CGRectMake(x, y, _timeSelectView.frame.size.width - x - 55, label2.frame.size.height);
        [subView addSubview:self.endTimeBtn];
        
        x = self.startTimeBtn.frame.origin.x + self.startTimeBtn.frame.size.width + 5;
        y = self.startTimeBtn.frame.origin.y;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shai_setting_icon_open@2x"]];
        imgView.frame = CGRectMake(x, y, 24, 24);
        [subView addSubview:imgView];
        
        
        x = self.endTimeBtn.frame.origin.x + self.endTimeBtn.frame.size.width + 5;
        y = self.endTimeBtn.frame.origin.y;
        imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shai_setting_icon_open@2x"]];
        imgView.frame = CGRectMake(x, y, 24, 24);
        [subView addSubview:imgView];
    }
    
    return _timeSelectView;
}

- (void)searchAction:(UIBarButtonItem *)btn {
    BOOL isSetTime = YES;
    do {
        if (!self.startTimeBtn.titleLabel.text || [self.startTimeBtn.titleLabel.text isEqualToString:@""]) {
            isSetTime = NO;
            break;
        }
        
        if (!self.endTimeBtn.titleLabel.text || [self.endTimeBtn.titleLabel.text isEqualToString:@""]) {
            isSetTime = NO;
            break;
        }
    } while (0);
    HLeaveMessageRetrieval *retrieval = [[HLeaveMessageRetrieval alloc] init];
    if (isSetTime) {
        NSDate *startDate = [self.timePicker.formatter dateFromString:self.startTimeBtn.titleLabel.text];
        NSDate *endDate = [self.timePicker.formatter dateFromString:self.endTimeBtn.titleLabel.text];
        retrieval.created_startDate = startDate;
        retrieval.created_endDate = endDate;
    }
    
    retrieval.channelType = [self channelFromStr];
    retrieval.leaveMessageType = [self messageTypeFromStr];
    retrieval.agentName = [self.agentLabel.text isEqualToString:@"未分配"] ? @"" : HDClient.sharedClient.currentAgentUser.agentId;
    retrieval.customerName = self.customerTextField.text;
    if (self.delegate) {
        [self.delegate didSelectLeaveMessageRetrieval:retrieval];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (HChannelType)channelFromStr {
    if ([self.channelLabel.text isEqualToString:@"网页"]) {
        return HChannelType_Web;
    }
    
    if ([self.channelLabel.text isEqualToString:@"App"]) {
        return HChannelType_App;
    }
    
    if ([self.channelLabel.text isEqualToString:@"Weibo"]) {
        return HChannelType_WeiBo;
    }
    
    return HChannelType_All;
}

- (HLeaveMessageType)messageTypeFromStr {
    if ([self.typeLabel.text isEqualToString:@"未处理"]) {
        return HLeaveMessageType_untreated;
    }
    if ([self.typeLabel.text isEqualToString:@"处理中"]) {
        return HLeaveMessageType_processing;
    }
    if ([self.typeLabel.text isEqualToString:@"已解决"]) {
        return HLeaveMessageType_resolved;
    }
   
    return HLeaveMessageType_custom;
}

- (void)backAction:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startBtnAction:(UIButton *)btn {
    if (!_timePicker) {
        [self.view addSubview:self.timePicker];
    }
    _timeSelected = 0;
    [self.timePicker showDateTimePickerView];
}

- (void)endBtnAction:(UIButton *)btn {
    if (!_timePicker) {
        [self.view addSubview:self.timePicker];
    }
    _timeSelected = 1;
    [self.timePicker showDateTimePickerView];
}

- (void)clearRetrievalAction:(UIButton *)btn {
    _timeIndex = 0;
    _agentIndex = 0;
    _typeIndex = 0;
    _channelIndex = 0;
    _customerTextField.text = @"";
    [self updateInfo];
}

- (void)updateInfo {
    self.timeLabel.text = [self dateArray][_timeIndex];
    self.agentLabel.text = [self agentsArray][_agentIndex];
    self.typeLabel.text = [self messageTypesArray][_typeIndex];
    self.channelLabel.text = [self channelsArray][_channelIndex];
}

#pragma mark - HTimePicker delegate
- (void)didClickFinishDateTimePickerView:(NSString *)date {
    if (_timeSelected == 0) {
        [self.startTimeBtn setTitle:date forState:UIControlStateNormal];
    }else {
        [self.endTimeBtn setTitle:date forState:UIControlStateNormal];
    }
}

#pragma mark - table view delegate & datasource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return self.timeSelectView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 120;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndexPath = indexPath;
    if ([self isDateLabelSelected]) {
        return;
    }
    
    if ([self isAgentLabelSelected]) {
        [self.pickerView setDataSource:[self agentsArray]];
        [self.pickerView.pickView selectRow:_agentIndex inComponent:0 animated:NO];
    }
    
    if ([self isLeaveMessageTypeSelected]) {
        [self.pickerView setDataSource:[self messageTypesArray]];
        [self.pickerView.pickView selectRow:_typeIndex inComponent:0 animated:NO];
    }
    
    if ([self isLeaveMessageChannelSelected]) {
        [self.pickerView setDataSource:[self channelsArray]];
        [self.pickerView.pickView selectRow:_channelIndex inComponent:0 animated:NO];
    }
    
    [self.view addSubview:self.pickerView];
}

- (void)savePickerWithValue:(NSString*)value index:(NSInteger)index {
    if ([self isDateLabelSelected]) {
        _timeIndex = index;
    }
    
    if ([self isAgentLabelSelected]) {
        _agentIndex = index;
    }
    
    if ([self isLeaveMessageTypeSelected]) {
        _typeIndex = index;
    }
    
    if ([self isLeaveMessageChannelSelected]) {
        _channelIndex = index;
    }

    [self updateInfo];
}

- (BOOL)isDateLabelSelected {
    return (_selectIndexPath.section == 0 && _selectIndexPath.row == 0);
}

- (BOOL)isAgentLabelSelected {
    return (_selectIndexPath.section == 1 && _selectIndexPath.row == 0);
}

- (BOOL)isLeaveMessageTypeSelected {
    return (_selectIndexPath.section == 1 && _selectIndexPath.row == 2);
}

- (BOOL)isLeaveMessageChannelSelected {
    return (_selectIndexPath.section == 1 && _selectIndexPath.row == 3);
}

@end
