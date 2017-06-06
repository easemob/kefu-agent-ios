//
//  HDConversationViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 4/14/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDConversationViewController.h"
#import "HDConversationCell.h"
#import "ChatViewController.h"
#define perpageSize 10

@interface HDConversationViewController ()<SRRefreshDelegate,UIScrollViewDelegate,HDClientDelegate,ChatViewControllerDelegate>

@property(nonatomic,assign) BOOL hasMore; //是否还有更多会话
@property (strong, nonatomic) SRRefreshView *slimeView;
@property(nonatomic,assign) HDConversationType type;
@property(nonatomic,assign) BOOL isRefreshing;
@property(nonatomic,assign) NSInteger page;
@property (strong, nonatomic) NSMutableDictionary *dataSourceDic;

@end

@implementation HDConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"会话";
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.dataSourceDic = [NSMutableDictionary dictionaryWithCapacity:0];
    _type = HDConversationAccessed;
    [self.tableView addSubview:self.slimeView];
    [self loadData];
    [self initDelegate];
}

- (void)initDelegate {
    [[HDClient shareClient] removeDelegate:self];
    [[HDClient shareClient] addDelegate:self delegateQueue:nil];
    [[HDManager shareInstance] registerLocalNoti];
}

- (void)loadData {
    if (!_isRefreshing) {
        @synchronized(self) {
            if (_isRefreshing) {
                return;
            }
            _isRefreshing = YES;
        }
    } else {
        return;
    }
    _page = 1;
    [self showHintNotHide:@"加载数据中..."];
    WEAK_SELF
    [[HDNetworkManager shareInstance] asyncFetchConversationsWithType:_type page:1 limit:perpageSize otherParameters:nil completion:^(NSArray *conversations, HDError *error) {
        [weakSelf hideHud];
        @synchronized (self) {
            _isRefreshing = NO;
        }
        if (!error) {
            [self.dataSource removeAllObjects];
            switch (_type) {
                case HDConversationAccessed: {
                    for (ConversationModel *model in conversations) {
                        [weakSelf.dataSource insertObject:model atIndex:0];
                        [_dataSourceDic setObject:model forKey:model.serciceSessionId];
                        model.lastMessage.sessionServiceId = model.serciceSessionId;
                    }
                    break;
                }
                default:
                    break;
            }
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf.tableView reloadData];
        }
    }];
}
#pragma mark chatviewControllerDelegate
- (void)refreshConversationList {
    [self loadData];
}

#pragma mark - getter
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_type == HDConversationAccessed) {
        return 1;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count == 0) {
        return 1;
    }
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == HDConversationAccessed) {
        HDConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[HDConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
//            cell.rightUtilityButtons = nil;
        }
        
       if ([self.dataSource count] == 0) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
                cell.textLabel.text = @"没有会话";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                return cell;
       }

        ConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[ConversationModel class]]) {
            [cell setModel:model];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
        }
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return DEFAULT_CONVERSATION_CELLHEIGHT;
    } else {
        if (_hasMore) {
            return DEFAULT_CONVERSATION_CELLHEIGHT;
        }
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataSource count] == 0) {
        return;
    }
    if (_type == HDConversationAccessed) {
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        chatVC.delegate = self;
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.conversationModel = [self.dataSource objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark - HDClientDelegate
- (void)newConversationWithSessionId:(NSString *)sessionId {
    [self loadData];
}

- (void)conversationLastMessageChanged:(MessageModel *)message {
    ConversationModel *model = [self.dataSourceDic objectForKey:message.sessionServiceId];
    if (model) {
        model.lastMessage = message;
        model.unreadCount += 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataSource removeObject:model];
            [self.dataSource insertObject:model atIndex:0];
            [self.tableView reloadData];
        });
    }
}


- (void)conversationAutoClosedWithServiceSessionId:(NSString *)serviceSessionId {
    [self loadData];
}

- (void)conversationTransferedByAdminWithServiceSessionId:(NSString *)serviceSessionId {
    [self loadData];
}


- (void)userAccountNeedRelogin {
     [[HDClient shareClient] removeDelegate:self];
    [[HDManager shareInstance] showLoginViewController];
}

- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    
}

//客服身份变化
- (void)roleChange:(RolesChangeType)type {
     [[HDManager shareInstance] showLoginViewController];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 加载更多

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
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadData];
    [_slimeView endRefresh];
}


- (void)dealloc {
    NSLog(@"-%s dealloc",__func__);
}


- (void)didReceiveLocalNotification:(UILocalNotification *)notification {
    if (![HDNetworkManager shareInstance].isAutoLogin) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo valueForKey:@"newMessageConversationId"]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.tabBarController setSelectedIndex:0];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
