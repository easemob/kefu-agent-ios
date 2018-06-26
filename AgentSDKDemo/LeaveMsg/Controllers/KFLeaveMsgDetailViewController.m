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
@property (nonatomic,strong) HLeaveMessage *model;
@property (nonatomic, strong) EMPickerView *taskView;
@property (nonatomic, strong) EMPickerView *statusView;
@property (nonatomic,strong) LeaveMsgInputView *inputView;
@end

@implementation KFLeaveMsgDetailViewController
{
    NSMutableArray *_headViewDatasource;
    CGFloat         _headViewHeight;
    NSMutableArray *_headInfoHeights;
    NSIndexPath    *_currentIndexPath;
    NSDictionary   *_temp;
    NSMutableArray <HLeaveMessageComment *> *_dataSource;
    NSString *_currentLeaveMsgStatusId;
    //分配
    NSMutableArray *_assginees;
    
    NSString *_currentAssginee; //当前分配name
}


- (instancetype)initWithModel:(HLeaveMessage *)model {
    if (self = [super init]) {
        _model = model;
//        _currentLeaveMsgStatusId = model.status.ID;
        rowHeight = 40;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"留言详情";
    _assginees = [NSMutableArray arrayWithCapacity:0];
    HAssignee *assigee = [[HAssignee alloc] init];
    assigee.nickname = @"未分配";
    [_assginees addObject:assigee];
    [self setup];
}

- (void)loadAssignees {
    // 获取通讯录
    [HDClient.sharedClient.leaveMessageMananger asyncFetchAssigneeListWithPageNum:0 pageSize:1000 completion:^(HResultCursor *result, HDError *error) {
        if (error == nil) {
            [_assginees removeObjectsInRange:NSMakeRange(1, _assginees.count - 1)];
        }
        [_assginees addObjectsFromArray:result.elements];
    }];
}

- (void)setup {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _headViewDatasource = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    _headViewHeight = [self calculateHeight];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    self.tableView.height = KScreenHeight - 64 - 88;
    [self loadLeaveMessageAllComments];
}

#pragma mark - 评论

- (void)loadLeaveMessageAllComments
{
    [self loadAssignees];
    [HDClient.sharedClient.leaveMessageMananger asyncFetchCommentsWithLeaveMessageId:_model.leaveMessageId
                                                                             pageNum:0
                                                                            pageSize:1000
                                                                          completion:^(HResultCursor *cursor, HDError *error)
    {
                if (error == nil) {
                    [_dataSource removeAllObjects];
                }
                [_dataSource addObjectsFromArray:cursor.elements];
                [self.tableView reloadData];
    }];
}

- (CGFloat)calculateHeight {
    CGFloat height = 0;
    NSString *projectId = [NSString stringWithFormat:@"No.%@",_model.leaveMessageId];
    NSString *subject = [NSString stringWithFormat:@"主题:%@",_model.subject];
    NSString *creator = [NSString stringWithFormat:@"发起人:%@",_model.creator.username];
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
    
    for (NSString *str in _headViewDatasource) {
        CGFloat strHeight = [NSString heightOfString:str font:15.0 width:KScreenWidth - 20] + 5;
        
        if (!_headInfoHeights) {
            _headInfoHeights = [NSMutableArray array];
        }
        [_headInfoHeights addObject:[NSNumber numberWithFloat:strHeight]];
        
        height += strHeight;
    }
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


- (void)didselectImageAttachment:(HLeaveMessageCommentAttachment *)attachment {
     [[MessageReadManager defaultManager] showBrowserWithImages:@[[NSURL URLWithString:attachment.url]]];
}

- (void)didSelectFileAttachment:(HLeaveMessageCommentAttachment *)attachment
{
    NSString *textToShare = [NSString stringWithFormat:@"%@:%@",@"附件",attachment.attachmentName];
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
    NSArray *atts = [attachments copy];
    WEAK_SELF
    [weakSelf showHint:@"发送中"];
    [HDClient.sharedClient.leaveMessageMananger asyncSendLeaveMessageCommentWithMessageId:_model.leaveMessageId
                                                                                  comment:text
                                                                              attachments:atts
                                                                               completion:^(HDError *error)
    {
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
        KFLeaveMsgDetailHeadView *header = [[KFLeaveMsgDetailHeadView alloc] initWithModel:_model dataSource:_headViewDatasource heights:_headInfoHeights];
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
        if (_dataSource.count > 0 && indexPath.row > 0) {
            return [KFLeaveMsgCommentCell _heightForModel:_dataSource[indexPath.row - 1]] + 30;
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
            tip.centerX = KScreenWidth / 2;
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
            cell.detailTextLabel.text = _model.assignee == nil? @"未分配":_model.assignee.username;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"状态:";
            cell.detailTextLabel.text = [self strWithType:_model.type];
        }
        return cell;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (NSString *)strWithType:(HLeaveMessageType)aType {
    NSString *ret = @"";
    switch (aType) {
        case HLeaveMessageType_untreated:
            ret = @"未处理";
            break;
        case HLeaveMessageType_processing:
            ret = @"处理中";
            break;
        case HLeaveMessageType_resolved:
            ret = @"已解决";
            break;
        default:
            break;
    }
    return ret;
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

- (EMPickerView *)statusView
{
    if (_statusView == nil) {
        _statusView = [[EMPickerView alloc] initWithDataSource:@[
                                                                 [self strWithType:HLeaveMessageType_untreated],
                                                                 [self strWithType:HLeaveMessageType_processing],
                                                                 [self strWithType:HLeaveMessageType_resolved]]
                                                     topHeight:64];
        _statusView.tag = PickerViewTagDistribute;
        _statusView.delegate = self;
        
    }
    return _statusView;
}

- (EMPickerView *)taskView
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
    for (HAssignee *assignee in _assginees) {
        [arr addObject:assignee.nickname];
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
                    HAssignee *assignee = _assginees[index];
                    MBProgressHUD *hud = [MBProgressHUD showMessag:@"分配中" toView:self.view];
                    [HDClient.sharedClient.leaveMessageMananger asyncAssignLeaveMessagesWithMessageIds:@[_model.leaveMessageId] toAgentId:assignee.agentId completion:^(HDError *error) {
                        if (!error) {
                            [hud setLabelText:@"分配成功"];
                            _currentAssginee = assignee.nickname;
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
                if ([_model.assignee.username isEqualToString:value]) return; else { //delete
                    MBProgressHUD *hud = [MBProgressHUD showMessag:@"分配中" toView:self.view];
                    if (index == 0) {
                        [HDClient.sharedClient.leaveMessageMananger asyncUnAssignLeaveMessageId:@[_model.leaveMessageId] completion:^(HDError *error) {
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
                        HAssignee *assignee = _assginees[index];
                        
                        [HDClient.sharedClient.leaveMessageMananger asyncAssignLeaveMessagesWithMessageIds:@[_model.leaveMessageId] toAgentId:assignee.agentId completion:^(HDError *error) {
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
            
            HLeaveMessageType type = 0;
            if (index == 0) {
                type = HLeaveMessageType_untreated;
            }
            if (index == 1) {
                type = HLeaveMessageType_processing;
            }
            if (index == 2) {
                type = HLeaveMessageType_resolved;
            }
            MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中" toView:self.view];
            [HDClient.sharedClient.leaveMessageMananger asyncSetLeaveMessagesTypeWithMessageId:_model.leaveMessageId
                                                                                          type:type
                                                                                    completion:^(HDError *error) {
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
    [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessageInfoWithLeaveMessageId:_model.leaveMessageId completion:^(HLeaveMessage *leaveMessage, HDError *error) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

@end
