//
//  ClientInforViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/17.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "ClientInforViewController.h"
#import "ClientInforCompileController.h"
#import "MBProgressHUD.h"
#import "DXTagView.h"
#import "CompileTableViewCell.h"
#import "ClientInforHeaderView.h"
#import "EMPickerView.h"
#import "KFDatePicker.h"
#import "ChatViewController.h"
@interface ClientInforViewController ()<ClientInforCompileControllerDelegate,EMPickerSaveDelegate,KFDatePickerDelegate>
{
    NSArray *titleArr;
}

@property (strong ,nonatomic) DXTagView *tagView;
@property (strong ,nonatomic) NSMutableArray *tagSource;
@property (strong ,nonatomic) NSMutableDictionary *userInfo;
@property (strong ,nonatomic) ClientInforHeaderView *headerView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIView *headerButtonView;
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *tagButton;
@property(nonatomic,strong)   NSMutableArray *dataArr;
@property(nonatomic,strong) EMPickerView *pickerView;

@end

@implementation ClientInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.headerButtonView];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.tableView];
    self.tableView.height -= CGRectGetMaxY(self.headerButtonView.frame) + 64;
    [self.mainScrollView addSubview:self.tagView];
    
    // Do any additional setup after loading the view.
    [self.tableView reloadData];

//    [self loadUserInfo];
    [self loadVisitorInfoList];
    
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    hudView.tag = 1000;
    [self.tableView addSubview:hudView];
}

#pragma mark - getter

- (NSMutableArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (UIView*)headerButtonView
{
    if (_headerButtonView == nil) {
        _headerButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.height, KScreenWidth, 44)];
        _headerButtonView.backgroundColor = [UIColor whiteColor];
        [_headerButtonView addSubview:self.infoButton];
        [_headerButtonView addSubview:self.tagButton];
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

- (UIButton*)infoButton
{
    if (_infoButton == nil) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _infoButton.frame = CGRectMake(0, 0, KScreenWidth/2, self.headerButtonView.height - 1.f);
        [_infoButton setTitle:@"资料" forState:UIControlStateNormal];
        [_infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

- (UIButton*)tagButton
{
    if (_tagButton == nil) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, self.headerButtonView.height - 1.f);
        [_tagButton setTitle:@"标签" forState:UIControlStateNormal];
        [_tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_tagButton addTarget:self action:@selector(tagButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tagButton;
}

- (UIScrollView*)mainScrollView
{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerButtonView.frame), KScreenWidth, KScreenHeight - CGRectGetMaxY(self.headerButtonView.frame));
        _mainScrollView.contentSize = CGSizeMake(KScreenWidth * 2, KScreenHeight - CGRectGetMaxY(self.headerButtonView.frame));
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.scrollEnabled = NO;
    }
    return _mainScrollView;
}

- (ClientInforHeaderView*)headerView
{
    _headerView = [[ClientInforHeaderView alloc] initWithniceName:_niceName tagImage:_tagImage];
    return _headerView;
}

- (UIView*)tagView
{
    if (_tagView == nil) {
        _tagView = [[DXTagView alloc] initWithFrame:CGRectMake(KScreenWidth, 0, KScreenWidth, self.tableView.height) isFromChat:NO];
        _tagView.userId = _userId;
        _tagView.bgColor = [UIColor clearColor];
    }
    return _tagView;
}

#pragma mark - action
- (void)infoButtonAction
{
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.selectView.left = 0.f;
    }];
}

- (void)tagButtonAction
{
    [self.mainScrollView setContentOffset:CGPointMake(KScreenWidth, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.selectView.left = KScreenWidth/2;
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[CompileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
    }
    HDVisitorInfoItem *model = _dataArr[indexPath.row];
    if (!model.readonly && !_readOnly) {
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.model = model;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_readOnly) {
        return 60;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!_readOnly) {
        return nil;
    }
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = RGBACOLOR(23, 162, 253, 1);
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:@"联系客户" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(contactVisitor) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(20, 10, KScreenWidth-40, 40);
    [footer addSubview:btn];
    return footer;
}


- (void)contactVisitor
{
    [self showHintNotHide:@"创建会话中..."];
    WEAK_SELF
    [[HDClient sharedClient].notiManager asyncMessageCenterCreateSessionWithVisitorId:_userId Completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            HDConversation *model = responseObject;
            ChatViewController *chatView = [[ChatViewController alloc] init];
            chatView.conversationModel = model;
            model.chatter = model.vistor;
            [[DXMessageManager shareManager] setCurSessionId:model.sessionId];
            [weakSelf.navigationController pushViewController:chatView animated:YES];
        } else {
            [weakSelf showHint:@"创建失败"];
        }
    }];

}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HDVisitorInfoItem *item = _dataArr[indexPath.row];
    return item.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_readOnly) {
        return;
    }
    HDVisitorInfoItem *item = _dataArr[indexPath.row];
    if (item.readonly) return;
    if (item.columnType == HDColumnTypeMultiSelected) {
        _pickerView = [[EMPickerView alloc] initWithDataSource:item.options];
        _pickerView.delegate = self;
        _pickerView.tag = indexPath.row;
        [self.view addSubview:_pickerView];
    } else if (item.columnType == HDColumnTypeDate){ //日历
        KFDatePicker *pick = [[KFDatePicker alloc] initWithFrame:CGRectMake(0, KScreenHeight-300, KScreenWidth, 300)];
        pick.tag = indexPath.row;
        pick.delegate =  self;
        [self.view addSubview:pick];
    } else { //单行多行文本
        CompileTableViewCell *cell = (CompileTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        ClientInforCompileController *compile = [[ClientInforCompileController alloc] initWithType:(int)indexPath.row];
        compile.title = item.displayName;
        compile.editContent = cell.nickName.text;
        if (item.columnType == HDColumnTypeNumber) {
            compile.isNumberPad = YES;
        }
        if (cell.nickName.textColor == [UIColor lightGrayColor]) {
            compile.isPlaceHolder = YES;
        }
        compile.delegate = self;
        [self.navigationController pushViewController:compile animated:YES];
    }
}

- (void)saveParameter:(NSString *)value key:(NSString *)key {
    
}

- (void)savePatameter:(NSString *)value index:(NSInteger)index {
    HDVisitorInfoItem *item = _dataArr[index];
    item.values = @[value];
    [_dataArr replaceObjectAtIndex:index withObject:item];
    [self updateVisitorInfomation];
    [self.navigationController popToViewController:self animated:YES];
}

- (void)dateClicked:(UIDatePicker *)datePicker {
    NSTimeInterval time = [datePicker.date timeIntervalSince1970]*1000;
    HDVisitorInfoItem *item = _dataArr[datePicker.tag];
    item.values = @[@(time)];
    [_dataArr replaceObjectAtIndex:datePicker.tag withObject:item];
    [self updateVisitorInfomation];
    
}

- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index {
    HDVisitorInfoItem *item = _dataArr[_pickerView.tag];
    item.values = @[value];
    [_dataArr replaceObjectAtIndex:_pickerView.tag withObject:item];
     [self updateVisitorInfomation];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - private


//new
- (void)loadVisitorInfoList {
    [self showHintNotHide:@"获取访客信息详情..."];
    WEAK_SELF
    
    [[HDClient sharedClient].notiManager asyncFetchVisitorItemsWithVisitorId:_userId completion:^(HDVisitorInfo *visitorInfo, HDError *error) {
        if (error == nil) {
             self.customerId = visitorInfo.customerId;
            for (HDVisitorInfoItem *item in visitorInfo.items) {
                if (item.columnEnable && item.visible) { //启用
                    if (item.columnType == HDColumnTypeMultiSelected) {
                        CGFloat height = 50;
                        if (item.values.count > 0) {
                            NSString *content = item.values[0];
                            NSDictionary *att = @{ NSFontAttributeName: [UIFont systemFontOfSize:17.0]};
                            CGRect rect = [content boundingRectWithSize:CGSizeMake(kVisitorInfomationContentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingUsesFontLeading attributes:att context:nil];
                            height = rect.size.height+20;
                        }
                        item.cellHeight = height;
                    } else {
                        item.cellHeight = 50;
                    }
                    [self.dataArr addObject:item];
                }
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tagView loadTag];
            [weakSelf hideHud];
        } else {
             [weakSelf showHint:@"获取失败"];
        }
       [[weakSelf.tableView viewWithTag:1000] removeFromSuperview];
    }];
        
}

#pragma mark - ClientInforCompileControllerDelegate
- (void)saveClientInfor
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateVisitorInfomation {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
    for (HDVisitorInfoItem *item in _dataArr) {
        if (item.values.count == 0) {
            item.values = @[@""];
        }
        [param setValue:item.values forKey:item.columnName];
    }
    [[HDClient sharedClient].notiManager updateVisitorItemWithCustomerId:self.customerId visitorId:_userId parameters:param completion:^(HDVisitorInfo *visitorInfo, HDError *error) {
        if (error == nil) { //成功
            [self showHint:@"修改成功"];
            [self.tableView reloadData];
        } else { //失败
            [self showHint:@"修改失败"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"__dealloc__%s",__func__);
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
