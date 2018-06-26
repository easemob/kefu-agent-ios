//
//  HLeaveMessageViewController.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/12.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HLeaveMessageViewController.h"
#import "HLeaveMessageCell.h"
#import "HLeaveMessageListViewController.h"
#import <AgentSDK/AgentSDK.h>

#define kRefreshTagHeight 64

@interface HLeaveMessageViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _untreatedCount;
    NSInteger _processingCount;
    NSInteger _resolvedCount;
    NSInteger _undistributedCount;
    NSInteger _cuntomCount;
    BOOL _isReloading;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headView;

@end

@implementation HLeaveMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"HLeaveMessageCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"leaveMsgCellId"];
    [self.tableView addSubview:self.headView];
    [self.view addSubview:self.tableView];
    [self beginReload]; // 如果有更新事件，可以通过notification调用 beginReload
    
    self.tabBarItem.badgeValue = @"10";
}

- (void)reloadCount {

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessageCountWithType:HLeaveMessageType_untreated
                                                                             completion:^(NSInteger count, HDError *error)
        {
            _untreatedCount = count;
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessageCountWithType:HLeaveMessageType_processing
                                                                             completion:^(NSInteger count, HDError *error)
         {
             _processingCount = count;
             dispatch_group_leave(group);
         }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HDClient.sharedClient.leaveMessageMananger asyncFetchLeaveMessageCountWithType:HLeaveMessageType_resolved
                                                                             completion:^(NSInteger count, HDError *error)
         {
             _resolvedCount = count;
             dispatch_group_leave(group);
         }];
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HDClient.sharedClient.leaveMessageMananger asyncFetchUndistributedLeaveMessageCountCompletion:^(NSInteger count, HDError *error)
         {
             _undistributedCount = count;
             dispatch_group_leave(group);
         }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self endReload];
    });
    
}

- (void)beginReload {
    [self reloadCount];
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
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
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

#pragma mark - table datasource & table delegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HLeaveMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leaveMsgCellId"];
    switch (indexPath.row) {
        case 0:
        {
            cell.lLeaveMsgTypeName.text = @"未处理留言";
            cell.lLeaveMsgCount.text = [NSString stringWithFormat:@" %d ",(int)_untreatedCount];
            [cell setupUnreadCountBgColor:UIColor.orangeColor];
            [cell setupUnreadCountTextColor:UIColor.whiteColor];
        }
            break;
        case 1:
        {
            cell.lLeaveMsgTypeName.text = @"处理中留言";
            cell.lLeaveMsgCount.text = [NSString stringWithFormat:@" %d ",(int)_processingCount];
            [cell setupUnreadCountBgColor:UIColor.clearColor];
            [cell setupUnreadCountTextColor:UIColor.blackColor];
        }
            break;
        case 2:
        {
            cell.lLeaveMsgTypeName.text = @"已解决留言";
            cell.lLeaveMsgCount.text = [NSString stringWithFormat:@" %d ",(int)_resolvedCount];
            [cell setupUnreadCountBgColor:UIColor.clearColor];
            [cell setupUnreadCountTextColor:UIColor.blackColor];
        }
            break;
        case 3:
        {
            cell.lLeaveMsgTypeName.text = @"未分配留言";
            cell.lLeaveMsgCount.text = [NSString stringWithFormat:@" %d ",(int)_undistributedCount];
            [cell setupUnreadCountBgColor:UIColor.clearColor];
            [cell setupUnreadCountTextColor:UIColor.blackColor];
        }
            break;
        case 4:
        {
            cell.lLeaveMsgTypeName.text = @"自定义留言筛选";
            cell.lLeaveMsgCount.text = [NSString stringWithFormat:@" %d ",(int)_cuntomCount];
            [cell setupUnreadCountBgColor:UIColor.clearColor];
            [cell setupUnreadCountTextColor:UIColor.blackColor];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5; // 目前只有5项
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HLeaveMessageListViewController *lMsgListVC = [[HLeaveMessageListViewController alloc] init];
    switch (indexPath.row) {
        case 0:{
            lMsgListVC.type = HLeaveMessageType_untreated;
        } break;
        case 1:{
            lMsgListVC.type = HLeaveMessageType_processing;
        } break;
        case 2:{
            lMsgListVC.type = HLeaveMessageType_resolved;
        } break;
        case 3:{
            lMsgListVC.type = HLeaveMessageType_all;
            lMsgListVC.isUndistributed = YES;
        } break;
        case 4:{
            lMsgListVC.type = HLeaveMessageType_custom;
            lMsgListVC.isCustom = YES;
        } break;
        default:
            break;
    }
    [self.navigationController pushViewController:lMsgListVC animated:YES];
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



@end
