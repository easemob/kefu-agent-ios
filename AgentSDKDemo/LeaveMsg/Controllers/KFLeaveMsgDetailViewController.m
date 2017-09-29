//
//  KFLeaveMsgDetailViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFLeaveMsgDetailViewController.h"
#import "KFLeaveMsgDetailHeadView.h"
#import "EMPickerView.h"
#import "KFLeaveMsgCommentCell.h"
#import "MessageReadManager.h"
#import "LeaveMsgInputView.h"

typedef NS_ENUM(NSUInteger, PickerViewTag) {
    PickerViewTagDistribute=123,
    PickerViewTagState,
};

typedef NS_ENUM(NSUInteger, LeaveStateTag) {
    LeaveStateTagNot = 62704,
    LeaveStateTagDoing,
    LeaveStateTagDone,
};

@interface KFLeaveMsgDetailViewController ()<UITableViewDelegate,UITableViewDataSource,EMPickerSaveDelegate,LeaveMsgInputViewDelegate,LeaveMsgCellDelegate>
@property(nonatomic,strong) HDLeaveMessage *model;
@property (nonatomic, strong) EMPickerView *taskView;
@property (nonatomic, strong) EMPickerView *statusView;
@property(nonatomic,strong) NSMutableArray *stateIDs;
@property(nonatomic,strong) NSMutableArray *stateNames;
@property(nonatomic,strong) LeaveMsgInputView *inputView;
@end

@implementation KFLeaveMsgDetailViewController
{
    NSMutableArray *_headViewDatasource;
    CGFloat         _headViewHeight;
    NSIndexPath    *_currentIndexPath;
    NSDictionary   *_temp;
    NSMutableArray <HDLeaveMessage *> *_dataSource;
    NSString *_currentLeaveMsgStatusId;
    //分配
    NSMutableArray *_assginees;
    
    NSString *_currentAssginee; //当前分配name
}


- (instancetype)initWithModel:(HDLeaveMessage *)model {
    if (self = [super init]) {
        _model = model;
        _currentLeaveMsgStatusId = model.status.ID;
        rowHeight = 40;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"留言详情";
    _assginees = [NSMutableArray arrayWithCapacity:0];
    UserModel *user = [UserModel new];
    user.nicename = @"未分配";
    user.userId = nil;
    [_assginees addObject:user];
    [self setup];
}

- (void)loadAssignees {
    [[HDClient sharedClient].leaveMsgManager asyncGetAssigneesCompletion:^(NSArray<HDAssignee *> *assignees, HDError *error) {
        [_assginees addObjectsFromArray:assignees];
    }];
}

- (void)setup {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _stateIDs = [NSMutableArray array];
    _stateNames = [NSMutableArray array];
    _headViewDatasource = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    _headViewHeight = [self calculateHeight];
    [self getState];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    self.tableView.height = KScreenHeight-64-88;
    [self loadLeaveMessageAllComments];
}

#pragma mark - 评论

- (void)loadLeaveMessageAllComments
{
    [self loadAssignees];
    
    [[HDClient sharedClient].leaveMsgManager asyncGetLeaveMsgCommentWithLeaveMsgId:_model.ID completion:^(NSArray<HDLeaveMessage *> *comments, HDError *error) {
        [_dataSource addObjectsFromArray:comments];
        [self.tableView reloadData];
    }];
}


//获取处理状态个数及ID
- (void)getState {
    [[HDClient sharedClient].leaveMsgManager asyncGetLeaveMsgStatusWithParameters:nil completion:^(NSArray<HDStatus *> *statuses, HDError *error) {
        if (error == nil) {
            for (HDStatus *status in statuses) {
                [_stateNames addObject:status.name];
                [_stateIDs addObject:status.ID];
            }
        }
    }];
}

- (CGFloat)calculateHeight {
    CGFloat height = 0;
    NSString *projectId = [NSString stringWithFormat:@"No.%@",_model.ID];
    NSString *subject = [NSString stringWithFormat:@"主题:%@",_model.subject];
    NSString *creator = [NSString stringWithFormat:@"发起人:%@",_model.creator.name];
    NSString *content = [NSString stringWithFormat:@"内容:%@",_model.content];
    NSString *phone   = _model.creator.phone ? [NSString stringWithFormat:@"手机:%@",_model.creator.phone]:nil;
    NSString *email   = _model.creator.email ? [NSString stringWithFormat:@"邮箱:%@",_model.creator.email]:nil;
    NSString *company = _model.creator.company ? [NSString stringWithFormat:@"公司:%@",_model.creator.company]:nil;
    [_headViewDatasource addObject:projectId];
    [_headViewDatasource addObject:subject];
    if(creator) [_headViewDatasource addObject:creator];
    [_headViewDatasource addObject:content];
    if(phone) [_headViewDatasource addObject:phone];
    if(email) [_headViewDatasource addObject:email];
    if(company) [_headViewDatasource addObject:company];
    height = _headViewDatasource.count*rowHeight;
    height += [NSString heightOfString:subject font:15.0 width:KScreenWidth-20];
    height += [NSString heightOfString:content font:15.0 width:KScreenWidth-20];
    return height;
}
- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    if (toHeight == self.inputView.height) { //编辑
         self.inputView.bottom = KScreenHeight;
    } else {
        [self inputViewReset];
    }
    [self scrollViewToBottom:YES];
}

- (void)inputViewReset {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.inputView.top = KScreenHeight-88.0-64;
    } completion:^(BOOL finished) {
        [self.inputView resetAttachmentButton];
    }];
}


- (void)didselectImageAttachment:(HDAttachment *)attachment {
     [[MessageReadManager defaultManager] showBrowserWithImages:@[[NSURL URLWithString:attachment.url]]];
}

- (void)didSelectFileAttachment:(HDAttachment*)attachment
{
    NSString *textToShare = [NSString stringWithFormat:@"%@:%@",@"附件",attachment.name];
    NSURL *urlToShare = [NSURL URLWithString:attachment.url];
    NSArray *activityItems = @[textToShare, urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeMail];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)didSendText:(NSString *)text attachments:(NSArray *)attachments
{
    WEAK_SELF
    [weakSelf showHint:@"发送中"];
    [[HDClient sharedClient].leaveMsgManager asyncPostLeaveMsgCommentWithLeaveMsgId:_model.ID text:text attachments:attachments completion:^(id responseObject, HDError *error) {
        [weakSelf hideHud];
        if (error == nil) {
            [weakSelf.view endEditing:YES];
            [weakSelf loadLeaveMessageAllComments];
        } else {
             NSLog(@"发送失败，请检查网络");
        }
    }];
    
}

- (void)didSelectImageWithPicker:(UIImagePickerController *)imagePicker
{
    [self presentViewController:imagePicker animated:YES completion:NULL];
}
- (LeaveMsgInputView*)inputView
{
    if (_inputView == nil) {
        _inputView = [[LeaveMsgInputView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 88.f, KScreenWidth, 88.f + 162.f)];
        _inputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _inputView.delegate = self;
    }
    return _inputView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return _headViewHeight;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        KFLeaveMsgDetailHeadView *header = [[KFLeaveMsgDetailHeadView alloc] initWithModel:_model dataSource:_headViewDatasource height:_headViewHeight];
        WEAK_SELF
        header.tapTableview = ^ {
            [weakSelf inputViewReset];
        };
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (_dataSource.count > 0 && indexPath.row >0) {
            return [KFLeaveMsgCommentCell _heightForModel:_dataSource[indexPath.row-1]] + 30;
        }
    }
    if (indexPath.section == 0) {
        return rowHeight;
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            UIButton *tip = [[UIButton alloc] initWithFrame:cell.contentView.bounds];
            [tip setTitle:@"评论" forState:UIControlStateNormal];
            [tip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            tip.userInteractionEnabled = YES;
            tip.centerX = KScreenWidth/2;
            [cell.contentView  addSubview:tip];
            return cell;
        } else {
            static NSString *cellID = @"commentCell";
            KFLeaveMsgCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            cell.delegate = self;
            if (!cell) {
                cell = [[KFLeaveMsgCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.delegate = self;
            }
            cell.model = _dataSource[indexPath.row-1];
            return cell;
        }
    }
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 1)];
        lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
        [cell.contentView addSubview:lineView];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"分配:";
            cell.detailTextLabel.text = _model.assignee==nil? @"未分配":_model.assignee.name;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"状态:";
            cell.detailTextLabel.text = _model.status.name;
        }
        return cell;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    [self inputViewReset];
    _currentIndexPath = indexPath;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.view addSubview:self.taskView];
        }
        if (indexPath.row == 1) {
            [self.view addSubview:self.statusView];
        }
    }
    if (indexPath.section == 1) {
        [self.view endEditing:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return _dataSource.count + 1;
    }
    return 1;
}

#pragma mark - picker

- (EMPickerView*)statusView
{
    if (_statusView == nil) {
        _statusView = [[EMPickerView alloc] initWithDataSource:_stateNames topHeight:64];
        _statusView.tag = PickerViewTagDistribute;
        _statusView.delegate = self;
    }
    return _statusView;
}

- (EMPickerView*)taskView
{
    if (_taskView == nil) {
        _taskView = [[EMPickerView alloc] initWithDataSource:[self getNames] topHeight:64];
        _taskView.tag = PickerViewTagState;
        _taskView.delegate = self;
    }
    return _taskView;
}
- (NSArray *)getNames {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (UserModel *model in _assginees) {
        [arr addObject:model.nicename];
    }
    return arr;
}

- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index {
    WEAK_SELF
    //two kinds of situations:distribution and treat
    switch (_currentIndexPath.row) {
        case 0: {//distribute:four kinds of situations
            if (_model.assignee == nil ) {//之前是未分配
                if (index == 0) {
                    return;
                } else {//take
                    UserModel *user = _assginees[index];
                    MBProgressHUD *hud = [MBProgressHUD showMessag:@"分配中" toView:self.view];
                    [[HDClient sharedClient].leaveMsgManager asyncAssignLeaveMsgWithUser:user leaveMsgId:_model.ID completion:^(id responseObject, HDError *error) {
                        if (!error) {
                            [hud setLabelText:@"分配成功"];
                            _currentAssginee = user.nicename;
                            if (_delegate &&[_delegate respondsToSelector:@selector(leaveMsgDetailViewController:)]) {
                                [_delegate leaveMsgDetailViewController:self];
                            }
                            [hud hide:YES afterDelay:0.5];
                            [self reloadDetailData];
                        } else {
                            [hud setLabelText:@"分配失败"];
                            [hud hide:YES afterDelay:0.5];
                        }
                    }];
                }
            } else {
                if ([_model.assignee.name isEqualToString:value]) return; else { //delete
                    MBProgressHUD *hud = [MBProgressHUD showMessag:@"分配中" toView:self.view];
                    if (index == 0) {
                        [[HDClient sharedClient].leaveMsgManager asyncUnAssignLeaveMsgWithUserId:_model.assignee.ID leaveMsgId:_model.ID completion:^(id responseObject, HDError *error) {
                            if (error == nil) {
                                [hud setLabelText:@"分配成功"];
                                if (_delegate &&[_delegate respondsToSelector:@selector(leaveMsgDetailViewController:)]) {
                                    [_delegate leaveMsgDetailViewController:self];
                                }
                                [hud hide:YES afterDelay:0.5];
                                [self reloadDetailData];
                            } else {
                                [hud setLabelText:@"分配失败"];
                                [hud hide:YES afterDelay:0.5];
                            }
                        }];
                    } else {
                        UserModel *user = _assginees[index];
                        
                        [[HDClient sharedClient].leaveMsgManager asyncAssignLeaveMsgWithUser:user leaveMsgId:_model.ID completion:^(id responseObject, HDError *error) {
                            if (!error) {
                                [hud setLabelText:@"分配成功"];
                                if (_delegate &&[_delegate respondsToSelector:@selector(leaveMsgDetailViewController:)]) {
                                    [_delegate leaveMsgDetailViewController:self];
                                }
                                [hud hide:YES afterDelay:0.5];
                                [self reloadDetailData];
                            } else {
                                [hud setLabelText:@"分配失败"];
                                [hud hide:YES afterDelay:0.5];
                            }
                        }];
                    }
                }
            }
             break;
        }
        case 1:{ //未处理、处理中、已解决
            //take
            if ([_currentLeaveMsgStatusId isEqualToString:_stateIDs[index]]) {
                break;
            }
            MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中" toView:self.view];
            [[HDClient sharedClient].leaveMsgManager asyncSetLeaveMsgStatusWithLeaveMsgId:_model.ID statusId:_stateIDs[index] completion:^(id responseObject, HDError *error) {
                 [hud hide:YES afterDelay:0.5];
                if (error == nil) {
                    if (_delegate &&[_delegate respondsToSelector:@selector(leaveMsgDetailViewController:)]) {
                        [_delegate leaveMsgDetailViewController:self];
                    }
                    [weakSelf reloadDetailData];
                } else {
                     [hud setLabelText:@"保存失败"];
                }
            }];
            break;
        }
        default:
            break;
    }
}


- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)reloadDetailData
{
    WEAK_SELF
    [[HDClient sharedClient].leaveMsgManager asyncGetLeaveMsgDetailWithLeaveMsgId:_model.ID completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                _model = [[HDLeaveMessage alloc] initWithDictionary:responseObject];
                _currentLeaveMsgStatusId = _model.status.ID;
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
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
