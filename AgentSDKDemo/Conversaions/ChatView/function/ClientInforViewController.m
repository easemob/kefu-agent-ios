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
#import "KFiFrameView.h"
#import "CompileTableViewCell.h"
#import "ClientInforHeaderView.h"
#import "EMPickerView.h"
#import "KFDatePicker.h"
#import "ChatViewController.h"

#define kBlackListBtnHeight 54

@interface ClientInforViewController ()<ClientInforCompileControllerDelegate,EMPickerSaveDelegate,KFDatePickerDelegate>
{
    NSArray *titleArr;
    NSString *_kefuIm;
    NSString *_visitorInfo;
}

@property (nonatomic, strong) DXTagView *tagView;
@property (nonatomic, strong) KFiFrameView *iframeView;
@property (nonatomic, strong) NSMutableArray *tagSource;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) ClientInforHeaderView *headerView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *headerButtonView;
@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, strong) UIButton *iframeButton;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) EMPickerView *pickerView;

@property (nonatomic, strong) UIButton *blackListBtn;

@end

@implementation ClientInforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.headerButtonView];
    [self.view addSubview:self.mainScrollView];
    self.tableView.height -= CGRectGetMaxY(self.headerButtonView.frame) + 64;
    if (isIPHONEX) {
        self.tableView.height -= 64;
    }
    [self.mainScrollView addSubview:self.tableView];
    [self.mainScrollView addSubview:self.tagView];
    [self.mainScrollView addSubview:self.iframeView];
    [self.tableView reloadData];
    [self loadVisitorInfoList];
    [self loadBlackType];
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    hudView.tag = 1000;
    [self.tableView addSubview:hudView];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:self.blackListBtn.bounds];
    [self.tableView.tableFooterView addSubview:self.blackListBtn];
}

- (void)addBlackList:(UIButton *)btn {
    
    void(^block)(BOOL isSuccess) = ^(BOOL isSuccess) {
        [self hideHud];
        if (isSuccess) {
            self.blackListBtn.selected = !self.blackListBtn.selected;
        }else {
            [self showHint:@"设置失败, 请稍后重试"];
        }
    };
    
    void(^lengthLimitBlock)() = ^() {
        [self hideHud];
        [self showHint:@"设置失败，请确认输入的字数在1~150个字之间。"];
    };
    
    if (btn.selected) {
        [self showHintNotHide:@"设置中..."];
        [HDClient.sharedClient.visitorManager removeVisitorFromBlacklist:self.user.agentId
                                                          vistorNickname:self.user.nicename
                                                              completion:^(HDError * _Nonnull error)
        {
            block(!error);
        }];
    }else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入原因"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:nil];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showHintNotHide:@"设置中..."];
            NSString *str = [alertController.textFields firstObject].text;
            
            if (str.length > 150 || str.length == 0) {
                lengthLimitBlock();
                return ;
            }
            
            [HDClient.sharedClient.visitorManager addVisitorToBlacklist:weakSelf.user.agentId
                                                         vistorNickname:weakSelf.user.nicename
                                                       serviceSessionId:weakSelf.serviceSessionId
                                                                 reason:str
                                                             completion:^(HDError * _Nonnull error)
            {
                block(!error);
            }];
        }];
        
    
        [alertController addAction:sureAction];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - getter

- (NSMutableArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (UIView *)headerButtonView
{
    if (_headerButtonView == nil) {
        _headerButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.height, KScreenWidth, 44)];
        _headerButtonView.backgroundColor = [UIColor whiteColor];
        [_headerButtonView addSubview:self.infoButton];
        [_headerButtonView addSubview:self.tagButton];
        [_headerButtonView addSubview:self.iframeButton];
        [_headerButtonView addSubview:self.selectView];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 0.5f, KScreenWidth, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_headerButtonView addSubview:line];
    }
    return _headerButtonView;
}

- (UIView *)selectView
{
    if (_selectView == nil) {
        _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerButtonView.height - 1.5f, KScreenWidth / 3, 1.f)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth / 3, 1.5f)];
        line.backgroundColor = RGBACOLOR(25, 163, 255, 1);
        [_selectView addSubview:line];
    }
    return _selectView;
}

- (UIButton *)infoButton
{
    if (_infoButton == nil) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _infoButton.frame = CGRectMake(0, 0, KScreenWidth/3, self.headerButtonView.height - 1.f);
        [_infoButton setTitle:@"资料" forState:UIControlStateNormal];
        [_infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _infoButton;
}

- (UIButton *)tagButton
{
    if (_tagButton == nil) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tagButton.frame = CGRectMake(KScreenWidth / 3, 0, KScreenWidth / 3, self.headerButtonView.height - 1.f);
        [_tagButton setTitle:@"标签" forState:UIControlStateNormal];
        [_tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_tagButton addTarget:self action:@selector(tagButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tagButton;
}

- (UIButton *)iframeButton
{
    if (_iframeButton == nil) {
        _iframeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iframeButton.frame = CGRectMake(KScreenWidth / 3 * 2, 0, KScreenWidth / 3, self.headerButtonView.height - 1.f);
        [_iframeButton setTitle:@"iframe" forState:UIControlStateNormal];
        [_iframeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_iframeButton addTarget:self action:@selector(iframeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iframeButton;
}

- (UIScrollView *)mainScrollView
{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerButtonView.frame), KScreenWidth, KScreenHeight - CGRectGetMaxY(self.headerButtonView.frame));
        _mainScrollView.contentSize = CGSizeMake(KScreenWidth * 3, KScreenHeight - CGRectGetMaxY(self.headerButtonView.frame));
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.scrollEnabled = NO;
    }
    return _mainScrollView;
}

- (ClientInforHeaderView *)headerView
{
    _headerView = [[ClientInforHeaderView alloc] initWithniceName:_niceName tagImage:_tagImage];
    return _headerView;
}

- (UIView *)tagView
{
    if (_tagView == nil) {
        _tagView = [[DXTagView alloc] initWithFrame:CGRectMake(KScreenWidth, 0, KScreenWidth, self.tableView.height) isFromChat:NO];
        _tagView.userId = _userId;
        _tagView.bgColor = [UIColor clearColor];
    }
    return _tagView;
}


- (KFiFrameView *)iframeView {
    if (!_iframeView) {
        _iframeView = [[KFiFrameView alloc] initWithFrame:self.tableView.bounds iframe:nil];
        _iframeView.left = KScreenWidth * 2;
        _iframeView.backgroundColor = UIColor.redColor;
    }
    return _iframeView;
}

- (UIButton *)blackListBtn {
    if (!_blackListBtn) {
        _blackListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _blackListBtn.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 54);
        _blackListBtn.backgroundColor = UIColor.redColor;
        _blackListBtn.titleLabel.textColor = UIColor.whiteColor;
        [_blackListBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
        [_blackListBtn setTitle:@"从黑名单移除" forState:UIControlStateSelected];
        [_blackListBtn addTarget:self action:@selector(addBlackList:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blackListBtn;
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
        self.selectView.left = KScreenWidth / 3;
    }];
}

- (void)iframeButtonAction {
    
    __weak typeof(self)weakSelf = self;
    dispatch_block_t block = ^{ @autoreleasepool {
        KFIframeModel *model = [[HDUserManager sharedInstance] getAgentUserModel].iframeModel;
        if (model) {
            weakSelf.iframeView.kefuIm = _kefuIm;
            weakSelf.iframeView.visitorInfo = _visitorInfo;
            [weakSelf.iframeView reloadWebViewFromModel:model user:weakSelf.user];
        }
    }};
    
    [self.mainScrollView setContentOffset:CGPointMake(KScreenWidth * 2, 0) animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.selectView.left = KScreenWidth / 3 * 2;
    }];
    
    if (!_kefuIm || !_visitorInfo) {
        [self showHudInView:self.view hint:@"获取中..."];
        [HDClient.sharedClient.notiManager asyncFetchVisitorChatInfoWithId:_userId
                                                                completion:^(id info, HDError *error)
        {
            [weakSelf hideHud];
            if (!error) {
                NSArray *kefus = info[@"kefuIms"];
                _kefuIm = kefus.firstObject;
                _visitorInfo = info[@"visitorIm"];
                block();
            }else {
                [weakSelf showHint:@"获取失败..."];
            }
        }];
    }else {
        block();
    }
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
            [[KFManager sharedInstance] setCurrentSessionId:model.sessionId];
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
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[KFDatePicker class]] ||
            [subView isKindOfClass:[EMPickerView class]]) {
            [subView removeFromSuperview];
            break;
        }
    }
    
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

- (void)loadBlackType {
    [HDClient.sharedClient.visitorManager checkVisitorInBlacklist:self.user.agentId
                                                       completion:^(BOOL isInBlackList, HDError * _Nonnull error)
    {
        if (isInBlackList) {
            self.blackListBtn.selected = YES;
        }
    }];
}

//new
- (void)loadVisitorInfoList {
    [self showHintNotHide:@""];
    WEAK_SELF
    
    [[HDClient sharedClient].notiManager asyncFetchVisitorItemsWithVisitorId:_userId completion:^(HDVisitorInfo *visitorInfo, HDError *error) {
        if (error == nil) {
            [self.dataArr removeAllObjects];
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
    [[HDClient sharedClient].notiManager updateVisitorItemWithCustomerId:self.customerId visitorId:_userId parameters:param completion:^(id responseObject, HDError *error) {
        if (error == nil) { //成功
            [self loadVisitorInfoList];
            [self showHint:@"修改成功"];
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

@end
