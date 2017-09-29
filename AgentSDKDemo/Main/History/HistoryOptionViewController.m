//
//  HistoryOptionViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "HistoryOptionViewController.h"

#import "CompileTableViewCell.h"
#import "SelectTagViewController.h"
#import "AddTagViewController.h"
#import "DXTimeFilterView.h"
#import "EMPickerView.h"
#import "EMChatHeaderTagView.h"
#import "EMEditViewController.h"
#import "EMTimePickerViewController.h"
#import "HistoryCompileTableViewCell.h"
#import "EMHistoryTimeView.h"

#define kPickerViewTag 1000
#define kPickerTag 1001

@interface HistoryOptionViewController () <EMPickerSaveDelegate,EMChatHeaderTagViewDelegate,EMEditViewControllerDelegate,EMTimePickerViewDelegate>
{
    NSArray *_timeArray;
    NSArray *_optionArray;
    NSArray *_visitorArray;
    
    NSArray *_timeOptionArray;//时间选项
    NSArray *_originTypeArray;//渠道
    NSArray *_enquiryArray;//评价
    NSMutableArray *_techChannelTypeArray;//关联
    NSArray *_agentUserIdArray;//客服
    NSArray *_tagArray;//标签
    NSArray *_currentArray;
    
    NSMutableArray *_categoryIds;
    NSString *_visitorName;
    NSInteger _originType;//渠道
    NSInteger _techChannelType;//关联
    NSInteger _enquiry;//评价
    NSInteger _agentUserId;//客服
    NSInteger _timeIndex;//时间
    NSInteger _tagIndex;//标签
    
    NSInteger _curSection;
    NSInteger _curIndexRow;
    
    NSDate *_startDate;
    NSDate *_endDate;
    
    BOOL _isStartTime;
}

@property (nonatomic, strong) UIBarButtonItem *optionItem;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) EMPickerView *pickerView;

@property (nonatomic, strong) NSMutableArray *tagNodes;
@property (nonatomic, strong) EMChatHeaderTagView *headerImageView;
@property (nonatomic, strong) EMHistoryTimeView *historyTimeView;

@end

@implementation HistoryOptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"条件筛选";
    
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.navigationItem.rightBarButtonItem = self.optionItem;
    
    self.tableView.backgroundColor = kTableViewHeaderAndFooterColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSummaryResult:) name:NOTIFICATION_ADD_SUMMARY_RESULTS object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initData
{
    _timeArray = @[@"时间",@"开始时间",@"结束事件"];
    if (_type == EMHistoryOptionType) {
        _optionArray = @[@"渠道",@"关联",@"标签",@""];
    } else {
        _optionArray = @[@"渠道",@"关联"];
    }
    _visitorArray = @[@"访客姓名"];
    
    //时间
    _timeOptionArray = @[@{@"key":@"今天",@"value":@"0"},@{@"key":@"昨天",@"value":@"1"},@{@"key":@"本周",@"value":@"2"},@{@"key":@"本月",@"value":@"3"},@{@"key":@"上个月",@"value":@"4"},@{@"key":@"指定时间",@"value":@"5"}];
    
    //渠道
    _originTypeArray = @[@{@"key":@"全部渠道",@"value":@""},@{@"key":@"网页",@"value":@"webim"},@{@"key":@"APP",@"value":@"app"},@{@"key":@"微信",@"value":@"weixin"},@{@"key":@"微博",@"value":@"weibo"}];
    
    //满意度评价
    _enquiryArray = @[@{@"key":@"全部评价",@"value":@""},@{@"key":@"未评价",@"value":@"0"},@{@"key":@"1",@"value":@"1"},@{@"key":@"2",@"value":@"2"},@{@"key":@"3",@"value":@"3"},@{@"key":@"4",@"value":@"4"},@{@"key":@"5",@"value":@"5"}];
    
    //关联
    _techChannelTypeArray = [NSMutableArray arrayWithArray:@[@{@"key":@"全部关联",@"value":@""}]];
    
    //客服
    _agentUserIdArray = @[@{@"key":@"全部客服",@"value":@""}];
    
    //标签
    _tagArray = @[@{@"key":@"全部会话",@"value":@""},@{@"key":@"全部会话标签",@"value":[self _getAllRootNode]},@{@"key":@"未指定会话标签",@"value":@"0"}];
    
    _visitorName = @"";
    _categoryIds = [NSMutableArray array];
    _timeIndex = 2;
    
    _parameters = [NSMutableDictionary dictionary];
    _endDate = [[DXTimeFilterView curWeek] objectForKey:@"last"];
    _startDate = [[DXTimeFilterView curWeek] objectForKey:@"first"];
    if (_startDate) {
        [_parameters setObject:[self formatDate:_startDate] forKey:@"beginDate"];
    }
    if (_endDate) {
        [_parameters setObject:[self formatDate:_endDate] forKey:@"endDate"];
    }
    [_parameters setObject:@"Terminal" forKey:@"state"];
    [_parameters setObject:_visitorName forKey:@"visitorName"];
    [_parameters setObject:@"-1" forKey:@"subCategoryId"];
    [_parameters setObject:@"-1"  forKey:@"categoryId"];
    UserModel  *user = [HDClient sharedClient].currentAgentUser;
    BOOL isAgent = [user.userType isEqualToString:@"Agent"];
    [_parameters setObject:@(isAgent) forKey:@"isAgent"];
    [_parameters setObject:[[_originTypeArray objectAtIndex:_originType] valueForKey:@"value"] forKey:@"originType"];
    [_parameters setObject:_categoryIds forKey:@"summaryIds"];
    [_parameters setObject:[[_techChannelTypeArray objectAtIndex:_techChannelType] valueForKey:@"value"] forKey:@"techChannelId"];
    [_parameters setObject:[[_enquiryArray objectAtIndex:_enquiry] valueForKey:@"value"] forKey:@"enquiry"];
    [_parameters setObject:[[_agentUserIdArray objectAtIndex:_agentUserId] valueForKey:@"value"] forKey:@"agentUserId"];
    [self _LoadTechChannels];
}

#pragma mark - getter

- (EMHistoryTimeView*)historyTimeView
{
    if (_historyTimeView == nil) {
        _historyTimeView = [[EMHistoryTimeView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeAction)];
        [_historyTimeView.startTimeView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeAction)];
        [_historyTimeView.endTimeView addGestureRecognizer:tap2];
        
    }
    return _historyTimeView;
}

- (EMChatHeaderTagView*)headerImageView
{
    if (_headerImageView == nil) {
        _headerImageView = [[EMChatHeaderTagView alloc] initWithSessionId:nil edit:YES];
        _headerImageView.delegate = self;
    }
    return _headerImageView;
}

- (NSDateFormatter*)timeFormatter
{
    if (_timeFormatter == nil) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return _timeFormatter;
}

- (NSDateFormatter*)formatter
{
    if (_formatter == nil) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    return _formatter;
}

- (UIBarButtonItem*)optionItem
{
    if (_optionItem == nil) {
        UIButton *optionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [optionButton setTitle:@"筛选" forState:UIControlStateNormal];
        [optionButton setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
        [optionButton addTarget:self action:@selector(optionAction) forControlEvents:UIControlEventTouchUpInside];
        _optionItem = [[UIBarButtonItem alloc] initWithCustomView:optionButton];
    }
    return _optionItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [_optionArray count];
    }
    return [_visitorArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCompileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[HistoryCompileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.title.text = [_timeArray objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (_timeIndex == 5) {
                cell.nickName.text = @"指定时间";
            } else {
                cell.nickName.text =[[_timeOptionArray objectAtIndex:_timeIndex] valueForKey:@"key"];
            }
        } else if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.historyTimeView.startTimeLabel.text = [self.formatter stringFromDate:_startDate];
            self.historyTimeView.endTimeLabel.text = [self.formatter stringFromDate:_endDate];
            [cell addSubview:self.historyTimeView];
        }
    } else if (indexPath.section == 1) {
        cell.title.text = [_optionArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.nickName.text = [[_originTypeArray objectAtIndex:_originType] valueForKey:@"key"];
        } else if (indexPath.row == 1) {
            cell.nickName.text = [[_techChannelTypeArray objectAtIndex:_techChannelType] valueForKey:@"key"];
        } else if (indexPath.row == 2) {
            if ([_categoryIds count] == 0) {
                cell.nickName.text = [[_tagArray objectAtIndex:_tagIndex] valueForKey:@"key"];
            } else {
                cell.nickName.text = @"指定标签";
            }
        } else if (indexPath.row == 3) {
            cell.title.text = @"选择标签";
            self.headerImageView.top = 44.f;
            [cell addSubview:self.headerImageView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else {
        if (indexPath.row == 0) {
            cell.nickName.text = [_parameters valueForKey:@"visitorName"];
            if (cell.nickName.text.length == 0) {
                cell.nickName.text = @"全部名称";
            }
        }
        cell.title.text = [_visitorArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3) {
        if (self.headerImageView.height < 50) {
            return 50.f;
        }
        return self.headerImageView.height + 44.f;
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 98.f;
    }
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self showPickerAction:indexPath.row section:indexPath.section];
        } else {
            return;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showPickerAction:indexPath.row section:indexPath.section];
        } else if (indexPath.row == 1) {
            [self showPickerAction:indexPath.row section:indexPath.section];
        } else if (indexPath.row == 2) {
            [self showPickerAction:indexPath.row section:indexPath.section];
        } else if (indexPath.row == 3) {
            SelectTagViewController *selectTagView = [[SelectTagViewController alloc] initWithStyle:UITableViewStylePlain tagId:@"0" treeArray:nil color:nil isSelectRoot:YES];
            selectTagView.title = @"选择会话标签";
            CATransition* transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
            transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self.navigationController pushViewController:selectTagView animated:NO];
        }
    } else {
        if (indexPath.row == 0) {
            EMEditViewController *editview = [[EMEditViewController alloc] init];
            editview.title = [_visitorArray objectAtIndex:indexPath.row];
            editview.key = @"visitorName";
            editview.delegate = self;
            [self.navigationController pushViewController:editview animated:YES];
        }
    }
}

#pragma mark - EMTimePickerViewDelegate

- (void)saveStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    _startDate = startDate;
    [self updateParameters:@"beginDate" value:[self formatDate:_startDate]];
    _endDate = endDate;
    [self updateParameters:@"endDate" value:[self formatDate:_endDate]];
    _timeIndex = 5;
    [self.tableView reloadData];
}

#pragma mark - EMEditViewControllerDelegate

- (void)saveParameter:(NSString *)value key:(NSString *)key
{
    [self updateParameters:key value:value];
    [self.tableView reloadData];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark-----pickerview
- (void)showPickerAction:(NSInteger)index section:(NSInteger)section;
{
    _currentArray = nil;
    _curSection = section;
    _curIndexRow = index;
    if (section == 0) {
        _currentArray = _timeOptionArray;
    } else if (section == 1){
        switch (index) {
            case 0:
            {
                //渠道
                _currentArray = _originTypeArray;
            }
                break;
            case 1:
            {
                //关联
                _currentArray = _techChannelTypeArray;
            }
                break;
            case 2:
            {
                //标签
                _currentArray = _tagArray;
            }
                break;
            default:
            {
                return;
            }
                break;
        }
    }
    if (_pickerView == nil) {
        _pickerView = [[EMPickerView alloc] initWithDataSource:_currentArray];
        _pickerView.delegate = self;
    }
    [_pickerView setDataSource:_currentArray];
    [self.view addSubview:_pickerView];
}

#pragma mark - EMPickerSaveDelegate
- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index
{
    if (_curSection == 0) {
        if (_curIndexRow == 0) {
            _timeIndex = index;
            _endDate = [NSDate date];
            _endDate =[[self.timeFormatter dateFromString:[self.timeFormatter stringFromDate:_endDate]] dateByAddingTimeInterval:86400];
            int dayCount = 0;
            switch (_timeIndex) {
                case 0:
                {
                    _endDate = [_endDate dateByAddingTimeInterval:-1];
                    dayCount = -1;
                    _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
                }
                    break;
                case 1:
                {
                    _endDate = [_endDate dateByAddingTimeInterval:-1*86400 - 1];
                    dayCount = -1;
                    _startDate = [_endDate dateByAddingTimeInterval:dayCount*86400 + 1];
                }
                    break;
                case 2:
                {
                    NSDictionary *weekDic = [DXTimeFilterView curWeek];
                    _endDate = [weekDic objectForKey:@"last"];
                    _startDate = [weekDic objectForKey:@"first"];
                }
                    break;
                case 3:
                {
                    NSDictionary *monthDic = [DXTimeFilterView curMonth];
                    _endDate = [monthDic objectForKey:@"last"];
                    _startDate = [monthDic objectForKey:@"first"];
                }
                    break;
                case 4:
                {
                    NSDictionary *lastMonthDic = [DXTimeFilterView lastMonth];
                    _endDate = [lastMonthDic objectForKey:@"last"];
                    _startDate = [lastMonthDic objectForKey:@"first"];
                }
                    break;
                case 5:
                {
                    NSDictionary *weekDic = [DXTimeFilterView curWeek];
                    _endDate = [weekDic objectForKey:@"last"];
                    _startDate = [weekDic objectForKey:@"first"];
                }
                    break;
                default:
                    break;
            }
            if (_startDate) {
                [self updateParameters:@"beginDate" value:[self formatDate:_startDate]];
                [_parameters setObject:[self formatDate:_startDate] forKey:@"beginDate"];
            }
            if (_endDate) {
                [self updateParameters:@"endDate" value:[self formatDate:_endDate]];
            }
        }
    } else if (_curSection == 1) {
        if (_curIndexRow == 0) {
            _originType = index;
            [self updateParameters:@"originType" value:[[_originTypeArray objectAtIndex:_originType] valueForKey:@"value"]];
        } else if (_curIndexRow == 1) {
            _techChannelType = index;
            [self updateParameters:@"techChannelId" value:[[_techChannelTypeArray objectAtIndex:_techChannelType] valueForKey:@"value"]];
        } else if (_curIndexRow == 2) {
            _tagIndex = index;
            [self updateParameters:@"summaryIds" value:[[_tagArray objectAtIndex:_tagIndex] valueForKey:@"value"]];
            [_tagNodes removeAllObjects];
            [_categoryIds removeAllObjects];
            [self.headerImageView setTagDatasource:_tagNodes];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - EMChatHeaderTagViewDelegate

- (void)deleteTagNode:(TagNode *)node
{
    if ([_categoryIds containsObject:node.Id]) {
        for (TagNode* tagNode in _tagNodes) {
            if ([tagNode.Id isEqualToString:node.Id]) {
                [_tagNodes removeObject:tagNode];
                break;
            }
        }
        [self.headerImageView setTagDatasource:_tagNodes];
        [self updateParameters:@"summaryIds" value:[_categoryIds componentsJoinedByString:@","]];
        [_categoryIds removeObject:node.Id];
    }
    [self.tableView reloadData];
}

#pragma mark - action

- (void)startTimeAction
{
    EMTimePickerViewController *pickerView = [[EMTimePickerViewController alloc] init];
    pickerView.delegate = self;
    pickerView.isSettingLeft = YES;
    pickerView.startTime = _startDate;
    pickerView.endTime = _endDate;
    [self.navigationController pushViewController:pickerView animated:YES];
}

- (void)endTimeAction
{
    EMTimePickerViewController *pickerView = [[EMTimePickerViewController alloc] init];
    pickerView.delegate = self;
    pickerView.isSettingLeft = NO;
    pickerView.startTime = _startDate;
    pickerView.endTime = _endDate;
    [self.navigationController pushViewController:pickerView animated:YES];
}

- (void)optionAction
{
    if (self.optionDelegate && [self.optionDelegate respondsToSelector:@selector(historyOptionWithParameters:)]) {
        [self.optionDelegate historyOptionWithParameters:_parameters];
    }
}

- (void)addSummaryResult:(NSNotification*)notification
{
    if (notification.object) {
        TagNode *node = (TagNode*)notification.object;
        if (![_categoryIds containsObject:node.Id]) {
            if (_tagNodes == nil) {
                _tagNodes = [NSMutableArray array];
            }
            [_tagNodes addObject:node];
            [_categoryIds addObject:node.Id];
            [self _getAllLeafNode:node.children];
            [self updateParameters:@"summaryIds" value:[_categoryIds componentsJoinedByString:@","]];
            [_headerImageView setTagDatasource:_tagNodes];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD show:@"已经添加" view:self.view];
        }
    }
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - private

- (void)_LoadTechChannels
{
    WEAK_SELF
    [[HDClient sharedClient].chatManager getChannelsCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            NSArray *json = responseObject;
            if (json && [json isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in json) {
                    [_techChannelTypeArray addObject:@{@"key":[dic valueForKey:@"name"],@"value":[[dic valueForKey:@"id"] stringValue]}];
                }
            }
            [weakSelf.tableView reloadData];
        }
    }];
}

- (NSString*)_getAllRootNode
{
    NSString *result = @"";
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    id jsonData = [ud objectForKey:USERDEFAULTS_DEVICE_TREE];
    NSArray *array = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    if (array && [array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in array) {
            TagNode *node = [[TagNode alloc] initWithDictionary:dic];
            if (result.length == 0) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@",node.Id]];
            } else {
                result = [result stringByAppendingString:[NSString stringWithFormat:@",%@",node.Id]];
            }
        }
    }
    return result;
}

- (void)_getAllLeafNode:(NSArray*)children
{
    if ([children isKindOfClass:[NSNull class]] || [children count] <= 0) {
        return;
    }
    for (NSDictionary *dic in children) {
        if ([dic objectForKey:@"id"]) {
            if ([dic objectForKey:@"children"]) {
                if ([[dic objectForKey:@"children"] isKindOfClass:[NSNull class]]) {
                    TagNode *node = [[TagNode alloc] initWithDictionary:dic];
                    [_tagNodes addObject:node];
                    [_categoryIds addObject:node.Id];
                } else {
                    [self _getAllLeafNode:[dic objectForKey:@"children"]];
                }
            } else {
                TagNode *node = [[TagNode alloc] initWithDictionary:dic];
                [_tagNodes addObject:node];
                [_categoryIds addObject:node.Id];
            }
        }
    }
}

- (NSString*)formatDate:(NSDate*)date
{
    if (date) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000"];
        NSString *string = [format stringFromDate:date];
        return [string stringByAppendingString:@"Z"];
    }
    return @"";
}

- (void)updateParameters:(NSString*)key value:(NSString*)value
{
    if (_parameters) {
        [_parameters setObject:value forKey:key];
    }
}


@end
