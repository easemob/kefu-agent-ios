//
//  LeaveMsgViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/9/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "LeaveMsgViewController.h"
#import "SRRefreshView.h"
#import "EMHeaderImageView.h"
#import "LeaveMsgDetailModel.h"
#import "KFLeaveMsgDetailViewController.h"
#import "KFLeaveMsgListCell.h"
#import "DXTipView.h"

@interface LeaveMsgViewController () <SRRefreshDelegate,EMChatManagerDelegate,KFLeaveMsgDetailViewControllerDelegate>
{
    NSInteger _page;        //页码
    NSInteger _pageSize;    //每页的数据条数
    BOOL _hasMore;
    
    NSObject *_refreshLock;
    BOOL _isRefresh;
    
    NSString *_projectId;   //projectId
    
    DXTipView *_badgeView; //unread
    
    NSString *_currentUnreadCount;
}

@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) EMHeaderImageView *headerImageView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (assign, nonatomic) NSInteger totalCount;
@property (strong, nonatomic) UILabel *headerView;

//badge


@end

@implementation LeaveMsgViewController

- (void)viewDidLoad
{
    NSLog(@"---- %p",self);
    [super viewDidLoad];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView addSubview:self.slimeView];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kTableViewBgColor;
    
    _badgeView = [[DXTipView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    
    _pageSize = 20;
    [self getLeaveMessageList];
}

- (void)getLeaveMessageList {
    [self loadAndRefreshDataWithCompletion:^(BOOL success) {
        
    }];
}




- (void)leaveMsgDetailViewController:(KFLeaveMsgDetailViewController *)vc {

    [self slimeRefreshStartRefresh:_slimeView];
}

#pragma mark - getter

- (UILabel*)headerView
{
    if (_headerView == nil) {
        _headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _headerView.backgroundColor = RGBACOLOR(229, 229, 229, 1);
        _headerView.font = [UIFont systemFontOfSize:12.f];
        _headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@(0),@(0)];
    }
    return _headerView;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIBarButtonItem*)headerViewItem
{
    if (_headerViewItem == nil) {
        _headerViewItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
    }
    return _headerViewItem;
}

- (EMHeaderImageView*)headerImageView
{
    return [KFManager sharedInstance].headImageView;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

#pragma mark - action

- (void)headImageItemAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_hasMore) {
        if (section == 0) {
            return [self.dataArray count];
        } else {
            return 1;
        }
    }
    return [self.dataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_hasMore) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ListCellID = @"MessageListCell";
    if (indexPath.section == 0) {
        KFLeaveMsgListCell *listCell = [tableView dequeueReusableCellWithIdentifier:ListCellID];
        if (!listCell) {
            listCell = [[KFLeaveMsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ListCellID];
        }
        listCell.model = self.dataArray[indexPath.row];
        return listCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadMoreCell"];
    }
    
    cell.textLabel.text = @"点击加载更多";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        HDLeaveMessage *model = [self.dataArray objectAtIndex:indexPath.row];
        KFLeaveMsgDetailViewController *leaveMsgDetail = [[KFLeaveMsgDetailViewController alloc] initWithModel:model];
        leaveMsgDetail.delegate = self;
        [leaveMsgDetail setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:leaveMsgDetail animated:YES];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        [self loadAndRefreshDataWithCompletion:^(BOOL success) {
            cell.userInteractionEnabled = YES;
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    _page = 0;
    [self loadAndRefreshDataWithCompletion:^(BOOL success) {
        [self.slimeView endRefresh];
    }];

}

#pragma mark - private
- (void)loadAndRefreshDataWithCompletion:(void (^)(BOOL success))completion
{
    WEAK_SELF
    @synchronized (_refreshLock) {
        if (_isRefresh) {
            return;
        }
        _isRefresh = YES;
    }

    [self showHintNotHide:@"加载中..."];
    
//    [[HDClient sharedClient].leaveMsgManager asyncFetchUntreatedLeaveMessagesCountWithCompletion:^(int count, HDError *error)
//    {
//
//    }];
//    
//    return;
    [[HDClient sharedClient].leaveMsgManager asyncGetLeaveMessagesWithStatusId:nil pageIndex:_page pageSize:_pageSize parameters:nil completion:^(NSArray<HDLeaveMessage *> *leaveMessages, HDError *error) {
        [weakSelf hideHud];
        @synchronized (_refreshLock) {
            _isRefresh = NO;
        }
        if (error == nil) {
            if (_page == 0) {
                [weakSelf.dataArray removeAllObjects];
            }
            _page ++;
            [weakSelf.dataArray addObjectsFromArray:leaveMessages];
            if (leaveMessages.count == _pageSize) {
                _hasMore = YES;
            } else {
                _hasMore = NO;
            }
            weakSelf.totalCount = [HDClient sharedClient].leaveMsgManager.totalCount;
            [weakSelf.tableView reloadData];
            _currentUnreadCount = [NSString stringWithFormat:@"%lu",(unsigned long)weakSelf.dataArray.count];
            weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",_currentUnreadCount,@(_totalCount)];
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
            _currentUnreadCount = [NSString stringWithFormat:@"%lu",(unsigned long)weakSelf.dataArray.count];
            weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",_currentUnreadCount,@(_totalCount)];
        }
    }];
}


- (void)refreshLeaveMessageList
{
    _page = 0;
    [self loadAndRefreshDataWithCompletion:^(BOOL success) {
        
    }];
}
- (void)setMSGWithBadgeValue:(NSString*)badgeValue
{
//    currentBadgeValue = badgeValue;
    //设置提醒数
    if (badgeValue && [badgeValue intValue] >= 100) {
        _badgeView.tipNumber = @"99+";
    } else {
        _badgeView.tipNumber = badgeValue;
    }
    if (badgeValue == nil) {
        [self setLeaveMsgUnRead:NO];
    } else {
        [self setLeaveMsgUnRead:YES];
    }
}

- (void)setLeaveMsgUnRead:(BOOL) aFlag
{
    LeaveMsgViewController *leaveMsgVC = (LeaveMsgViewController*)[self.tabBarController.childViewControllers objectAtIndex:3];
    if (aFlag) {
        [leaveMsgVC.tabBarItem setFinishedSelectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_crmhighlight"] rightImage:[self imageWithView:_badgeView]] withFinishedUnselectedImage:[self combine:[UIImage imageNamed:@"tabbar_icon_crm"] rightImage:[self imageWithView:_badgeView]]];
    }
}

- (UIImage *)imageWithView:(UIView *)v {
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)combine:(UIImage*)leftImage rightImage:(UIImage*)rightImage {
    CGFloat width = leftImage.size.width + 20;
    CGFloat height = leftImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, 0.0);
    
    CGRect rect = CGRectMake(10, 0, leftImage.size.width, leftImage.size.height);
    [leftImage drawInRect:rect];
    
    rect.origin.x += width/2;
    [rightImage drawInRect:CGRectMake(leftImage.size.width - 10, 0, rightImage.size.width, rightImage.size.height)];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imagez;
}

- (NSMutableDictionary*)_getSafeDictionary:(NSDictionary*)dic
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    if ([[userInfo allKeys] count] > 0) {
        for (NSString *key in [userInfo allKeys]){
            if ([userInfo objectForKey:key] == [NSNull null]) {
                [userInfo removeObjectForKey:key];
            } else {
                if ([[userInfo objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    [userInfo setObject:[self _getSafeDictionary:[userInfo objectForKey:key]] forKey:key];
                }
            }
        }
    }
    return userInfo;
}

@end
