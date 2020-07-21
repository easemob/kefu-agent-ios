//
//  HLeaveMessageListViewController.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/13.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HLeaveMessageListViewController.h"
#import "KFLeaveMsgDetailViewController.h"
#import "HLeaveMessageRetrievalViewController.h"
#import "HLeaveMessageListCell.h"
#import "EMPickerView.h"
#import "Masonry.h"
#define kRefreshTagHeight 64

#define kPageSize 10
@interface HLeaveMessageListViewController () <UITableViewDelegate, UITableViewDataSource, EMPickerSaveDelegate, HLeaveMessageRetrievalDelegate> {
    BOOL _isReloading;
    NSInteger _currentPage;
    BOOL _isChooseAll;
    NSArray *_assignees;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headView;
@property (nonatomic, strong) UIButton *footView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIBarButtonItem *assignmentItem; // 分配
@property (nonatomic, strong) UIBarButtonItem *leftItem; // 返回
@property (nonatomic, strong) UIBarButtonItem *selectAllItem; // 全选/取消全选按钮
@property (nonatomic, strong) UIBarButtonItem *selectItem;
@property (nonatomic, strong) EMPickerView *taskView; // 分配

@property (nonatomic, strong) UIBarButtonItem *rightItem; // 筛选

@end

@implementation HLeaveMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.isUndistributed == YES) {
        self.title = @"未分配";
    }else if (self.isCustom == YES) {
        self.title = @"自定义";
        self.navigationItem.rightBarButtonItem = self.rightItem;
    }else {
        self.title = [self navTitleWithType:self.type];
    }
    self.navigationItem.leftBarButtonItem = self.leftItem;
    [self.tableView addSubview:self.headView];
    self.tableView.tableFooterView = self.footView;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.toolbar];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-60);
    }];
    
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    
    [self registerLeaveMessageDetailDidChanged];
    [self reload];
}

- (void)registerLeaveMessageDetailDidChanged {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reload)
                                                 name:kLeaveMessageDetailChanged
                                               object:nil];
}

- (NSString *)navTitleWithType:(HLeaveMessageType)aType {
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

- (void)reload{
    if (self.isUndistributed) {
        [HDClient.sharedClient.leaveMessageMananger asyncFetchUndistributedLeaveMessagesWithPageNum:0
                                                                                           pageSize:kPageSize
                                                                                         completion:^(HResultCursor *result, HDError *error)
         {
             _currentPage = result.pageNum;
             hd_dispatch_main_async_safe(^{
                 [self.datasource removeAllObjects];
                 if (!error && result.elements.count > 0) {
                     [self.datasource addObjectsFromArray:result.elements];
                 }
                 if (result == nil || result.isLast) {
                     [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                     self.footView.enabled = NO;
                 }else {
                     [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                     self.footView.enabled = YES;
                 }
                 
                 [self endReload];
             });
         }];
    }else if (self.isCustom) {
        if (self.retrieval == nil) {
            [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
            self.footView.enabled = NO;
            [self endReload];
            return;
        }
        [HDClient.sharedClient.leaveMessageMananger asyncFetchCustomLeaveMessageWithLeaveMessageRetrieval:self.retrieval pageNum:0 pageSize:kPageSize completion:^(HResultCursor *result, HDError *error) {
            _currentPage = result.pageNum;
            hd_dispatch_main_async_safe(^{
                [self.datasource removeAllObjects];
                if (!error && result.elements.count > 0) {
                    [self.datasource addObjectsFromArray:result.elements];
                }
                if (result == nil || result.isLast) {
                    [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                    self.footView.enabled = NO;
                }else {
                    [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                    self.footView.enabled = YES;
                }
                
                [self endReload];
            });
        }];
    }else {
        [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessagesWithType:self.type
                                                                            pageNum:0
                                                                           pageSize:kPageSize
                                                                         completion:^(HResultCursor *result, HDError *error)
         {
             _currentPage = result.pageNum;
             hd_dispatch_main_async_safe(^{
                 [self.datasource removeAllObjects];
                 if (!error && result.elements.count > 0) {
                     [self.datasource addObjectsFromArray:result.elements];
                 }
                 if (result == nil || result.isLast) {
                     [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                     self.footView.enabled = NO;
                 }else {
                     [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                     self.footView.enabled = YES;
                 }
                 
                 [self endReload];
             });
         }];
    }
}

- (void)loadMore {
    if (self.isUndistributed) {
        [HDClient.sharedClient.leaveMessageMananger asyncFetchUndistributedLeaveMessagesWithPageNum:_currentPage + 1
                                                                                           pageSize:kPageSize
                                                                                         completion:^(HResultCursor *result, HDError *error)
         {
             _currentPage = result.pageNum;
             hd_dispatch_main_async_safe(^{
                 if (!error && result.elements.count > 0) {
                     [self.datasource addObjectsFromArray:result.elements];
                 }
                 if (result == nil || result.isLast) {
                     [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                     self.footView.enabled = NO;
                 }else {
                     [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                     self.footView.enabled = YES;
                 }
                 
                 [self.tableView reloadData];
             });
         }];
    }else if (self.isCustom) {
        [HDClient.sharedClient.leaveMessageMananger asyncFetchCustomLeaveMessageWithLeaveMessageRetrieval:self.retrieval
                                                                                                  pageNum:_currentPage + 1
                                                                                                 pageSize:kPageSize
                                                                                               completion:^(HResultCursor *result, HDError *error)
        {
            _currentPage = result.pageNum;
            hd_dispatch_main_async_safe(^{
                if (!error && result.elements.count > 0) {
                    [self.datasource addObjectsFromArray:result.elements];
                }
                if (result == nil || result.isLast) {
                    [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                    self.footView.enabled = NO;
                }else {
                    [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                    self.footView.enabled = YES;
                }
                
                [self.tableView reloadData];
            });
        }];
    }else {
        [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessagesWithType:self.type
                                                                            pageNum:_currentPage + 1
                                                                           pageSize:kPageSize
                                                                         completion:^(HResultCursor *result, HDError *error)
         {
             _currentPage = result.pageNum;
             hd_dispatch_main_async_safe(^{
                 if (!error && result.elements.count > 0) {
                     [self.datasource addObjectsFromArray:result.elements];
                 }
                 if (result == nil || result.isLast) {
                     [self.footView setTitle:@"已经到底了~" forState:UIControlStateNormal];
                     self.footView.enabled = NO;
                 }else {
                     [self.footView setTitle:@"加载更多" forState:UIControlStateNormal];
                     self.footView.enabled = YES;
                 }
                 
                 [self.tableView reloadData];
             });
         }];
    }
}

- (void)beginReload {
    [self reload];
}

- (void)endReload {
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        _isReloading = NO;
    }];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - 50);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        UINib *nib = [UINib nibWithNibName:@"HLeaveMessageListCell" bundle:nil];
        [_tableView registerNib:nib forCellReuseIdentifier:@"leaveMessageListCell"];
    }
    return _tableView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UILabel alloc] initWithFrame:CGRectZero];
        _headView.text = @"下拉刷新...";
        _headView.textColor = UIColor.darkGrayColor;
        _headView.textAlignment = NSTextAlignmentCenter;
        _headView.alpha = 0;
    }
    
    return _headView;
}

- (UIButton *)footView {
    if (!_footView) {
        _footView = [UIButton buttonWithType:UIButtonTypeCustom];
        _footView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
        [_footView setTitle:@"加载更多" forState:UIControlStateNormal];
        [_footView setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        [_footView addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}

- (UILabel *)selectLabel {
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.
                                                                 width, 30)];
        _selectLabel.backgroundColor = UIColor.grayColor;
        _selectLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _selectLabel;
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

- (UIBarButtonItem *)selectAllItem {
    if (!_selectAllItem) {
        _selectAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(chooseAllAction:)];
    }
    
    return _selectAllItem;
}

- (UIBarButtonItem *)rightItem {
    if (!_rightItem) {
        _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(rightAction:)];
        [_rightItem setTintColor:UIColor.whiteColor];
    }
    
    return _rightItem;
}

- (NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}

- (UIToolbar *)toolbar {
    if(!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 64 - 50, self.view.size.width, 60)];
        [_toolbar setBarTintColor:UIColor.whiteColor];
        self.selectItem = [[UIBarButtonItem alloc] initWithTitle:@"选择"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(chooseAction:)];
        
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
        _toolbar.items = @[self.selectItem, spaceItem, self.assignmentItem];
    }
    return _toolbar;
}

- (UIBarButtonItem *)assignmentItem {
    if (!_assignmentItem) {
        _assignmentItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(assignmentAction:)];
        _assignmentItem.enabled = NO;
    }
    
    return _assignmentItem;
}

- (EMPickerView *)taskView
{
    if (_taskView == nil) {
        _taskView = [[EMPickerView alloc] initWithDataSource:nil topHeight:64];
        _taskView.delegate = self;
    }
    return _taskView;
}


- (void)backAction:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightAction:(UIBarButtonItem *)item {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"HLeaveMessageRetrievalStoryboard" bundle:nil];
    HLeaveMessageRetrievalViewController *vc = (HLeaveMessageRetrievalViewController *)[story instantiateViewControllerWithIdentifier:@"HLeaveMessageRetrievalViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chooseAllAction:(UIBarButtonItem *)item{
    if (!_isChooseAll) {
        item.title = @"取消全选";
        [self.datasource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else {
        item.title = @"全选";
        [[self.tableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tableView deselectRowAtIndexPath:obj animated:NO];
        }];
    }
    
    _isChooseAll = !_isChooseAll;
}

- (void)assignmentAction:(UIBarButtonItem *)item {
    NSMutableArray *selectItems = [NSMutableArray array];
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in indexPaths) {
        HLeaveMessage *leaveMessage = self.datasource[indexPath.row];
        [selectItems addObject:leaveMessage.leaveMessageId];
    }
    
    if (selectItems.count == 0) {
        [self showHint:@"请先选则要分配的项目..."];
        return;
    }
    
    if (HDClient.sharedClient.leaveMessageMananger.assignees.count > 0) {
        _assignees = HDClient.sharedClient.leaveMessageMananger.assignees;
        NSMutableArray *names = [NSMutableArray array];
        for (HAssignee *assignee in _assignees) {
            [names addObject:assignee.nickname];
        }
        [self.taskView setDataSource:names];
        [self showPickerView];
    }else {
        [self showHintNotHide:@"获取列表中..."];
        [HDClient.sharedClient.leaveMessageMananger asyncFetchAssigneeListWithPageNum:0 pageSize:1000 completion:^(HResultCursor *result, HDError *error) {
            [self hideHud];
            if (error) {
                [self showHint:@"获取客服列表失败"];
            }else {
                _assignees = result.elements;
                NSMutableArray *names = [NSMutableArray array];
                for (HAssignee *assignee in _assignees) {
                    [names addObject:assignee.nickname];
                }
                [self.taskView setDataSource:names];
                [self showPickerView];
            }
        }];
    }
}

- (void)showPickerView {
    [self.view addSubview:self.taskView];
}

- (void)chooseAction:(UIBarButtonItem *)item{
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing) {
        item.title = @"取消";
        self.navigationItem.leftBarButtonItem = self.selectAllItem;
        [self.assignmentItem setEnabled:YES];
        self.assignmentItem.title = @"分配";
    }else {
        item.title = @"选择";
        self.navigationItem.leftBarButtonItem = self.leftItem;
        [self.assignmentItem setEnabled:NO];
        self.assignmentItem.title = @"";
    }
}


#pragma mark - EMPickerSaveDelegate
- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index {
    NSMutableArray *selectItems = [NSMutableArray array];
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in indexPaths) {
        HLeaveMessage *leaveMessage = self.datasource[indexPath.row];
        [selectItems addObject:leaveMessage.leaveMessageId];
    }
    HAssignee *assignee = _assignees[index];
    
    [self showHintNotHide:@"分配中..."];
    [HDClient.sharedClient.leaveMessageMananger asyncAssignLeaveMessagesWithMessageIds:selectItems
                                                                             toAgentId:assignee.agentId
                                                                            completion:^(HDError *error)
     {
         [self hideHud];
         if (!error) {
             [self showHint:@"分配成功"];
         }else {
             [self showHint:@"分配失败"];
         }
     }];
    
    [self.taskView removeFromSuperview];
    [self chooseAction:self.selectItem];
    [self reload];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeaveMessageDetailChanged object:nil];
}

#pragma mark - tableView datesource & tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLeaveMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leaveMessageListCell"];
    cell.backgroundColor = UIColor.whiteColor;
    cell.leaveMessage = self.datasource[indexPath.row];
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = -scrollView.contentOffset.y;
    self.headView.alpha = height / kRefreshTagHeight;
    self.headView.frame = CGRectMake(0, scrollView.contentOffset.y, self.view.bounds.size.width, -scrollView.contentOffset.y);
    if (!_isReloading) {
        if (height < kRefreshTagHeight) {
            self.headView.text = @"下拉刷新...";
        }else {
            self.headView.text = @"松开刷新...";
        }
        if (!scrollView.isDragging && height > kRefreshTagHeight) {
            self.headView.text = @"正在刷新...";
            _isReloading = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.contentInset = UIEdgeInsetsMake(kRefreshTagHeight, 0, 0, 0);
            } completion:^(BOOL finished) {
                [self beginReload];
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        return;
    }
    HLeaveMessage *leaveMessage = [self.datasource objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KFLeaveMsgDetailViewController *leaveMsgDetail = [[KFLeaveMsgDetailViewController alloc] initWithModel:leaveMessage];
    [leaveMsgDetail setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:leaveMsgDetail animated:YES];
}

#pragma mark - HLeaveMessageRetrievalDelegate
- (void)didSelectLeaveMessageRetrieval:(HLeaveMessageRetrieval *)aRetrieval {
    self.retrieval = aRetrieval;
    [self reload];
}
@end
