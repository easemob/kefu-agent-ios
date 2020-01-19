//
//  ConversationTableController.m
//  EMCSApp
//
//  Created by dhc on 15/4/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "HConversationViewController.h"
#import "DXTableViewCellTypeConversation.h"
#import "DXUserWaitTableViewCell.h"
#import "EMSearchDisplayController.h"
#import "ChatViewController.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "UIAlertView+AlertBlock.h"
#import "AppDelegate.h"
@interface HConversationViewController ()<SRRefreshDelegate,ChatViewControllerDelegate, HDClientDelegate>
{
    BOOL _isRefresh;
    int _unreadcount;
    int _waitUnreadcount;
    int _conversationcount;
    BOOL hasMore;
    UILabel *_resultLabel;
    
    dispatch_queue_t _conversationQueue;
    void* _queueTag;
    
    NSTimeInterval _endConversation;
}

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;

@property (nonatomic, strong) NSMutableArray *searchDataArray;

@property (nonatomic, strong) SRRefreshView *slimeView;
@property (nonatomic, strong) UIView *networkStateView;

@end

@implementation HConversationViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
                         type:(HDConversationType)type
{
    self = [super initWithStyle:style];
    if (self) {
        _type = type;
        _page = -1;
        _dataSourceDic = [NSMutableDictionary new];
        hasMore = NO;
        _conversationQueue = dispatch_queue_create("com.easemob.kefu.conversation", DISPATCH_QUEUE_SERIAL);
        _queueTag = &_queueTag;
        dispatch_queue_set_specific(_conversationQueue, _queueTag, _queueTag, NULL);
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [HDClient.sharedClient addDelegate:self delegateQueue:nil];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (_type != HDConversationAccessed) {
        _page = 1;
    }
    [self.tableView addSubview:self.slimeView];//f5f7fa
    self.tableView.backgroundColor = kTableViewBgColor;
    [self loadData];
}

- (void)connectionStateDidChange:(HDConnectionState)aConnectionState {
    [self isConnect:aConnectionState == HDConnectionConnected];
}

- (void)conversationLastMessageChanged:(HDMessage *)message {
    if ([message.sessionId isEqualToString:[KFManager sharedInstance].currentSessionId]) {
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            return;
        }
    }
    dispatch_async(_conversationQueue, ^{
        HDConversation *model = [self.dataSourceDic objectForKey:message.sessionId];
        if (model.lastMessage.timestamp >= message.timestamp) {
            return ;
        }
        if (model) {
            model.lastMessage = message;
            model.searchWord = model.chatter.nicename;
            if (!message.isSender) {
                model.unreadCount += 1;
            }
            [self.dataSource removeObject:model];
            [self.dataSource insertObject:model atIndex:0];
            _unreadcount = 0;
            for (HDConversation *cModel in self.dataSource) {
                _unreadcount += cModel.unreadCount;
            }
            
            [super dxDelegateAction:@{@"unreadCount": [NSNumber numberWithInt:_unreadcount]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                KFManager *cm = [KFManager sharedInstance]; 
                [cm setTabbarBadgeValueWithAllConversations:self.dataSource];
                [cm setNavItemBadgeValueWithAllConversations:self.dataSource];
                [self.tableView reloadData];
            });
        }
    });
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

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"当前网络连接失败";
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        self.tableView.tableHeaderView = self.networkStateView;
    } else{
        self.tableView.tableHeaderView = nil;
        [self refreshConversationList];
    }
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
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadData];
    [_slimeView endRefresh];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_type == HDConversationAccessed) {
        return 1;
    } else if (_type == HDConversationWaitQueues) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([self.dataSource count] == 0) {
            return 1;
        }
        return [self.dataSource count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == HDConversationAccessed) {
        
        if ([self.dataSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有会话";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        
        DXTableViewCellTypeConversation *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        if (cell == nil) {
            cell = [[DXTableViewCellTypeConversation alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.rightUtilityButtons = nil;
        }
        cell.textLabel.text = @"";
        HDConversation *model = [self.dataSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[HDConversation class]]) {
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

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return DEFAULT_CHAT_CELLHEIGHT;
    } else {
        if (hasMore) {
            return DEFAULT_CHAT_CELLHEIGHT;
        } else {
            return 0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataSource count] == 0) {
        return;
    }
    
    if (_type == HDConversationAccessed) {
        if ([self.conDelegate respondsToSelector:@selector(ConversationPushIntoChat:)]) {
            ChatViewController *chatVC = [[ChatViewController alloc] init];
            chatVC.delegate = self;
            HDConversation *model = [self.dataSource objectAtIndex:indexPath.row];
            chatVC.conversationModel = model;
            model.unreadCount = 0;
            dispatch_async(_conversationQueue, ^{
                [self.dataSource removeObjectAtIndex:indexPath.row];
                [self.dataSource insertObject:model atIndex:indexPath.row];
                chatVC.allConversations = self.dataSource;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.conDelegate ConversationPushIntoChat:chatVC];
                    [NSNotificationCenter.defaultCenter postNotificationName:@"UpdateIconBadge" object:nil];
                    [[KFManager sharedInstance] setTabbarBadgeValueWithAllConversations:self.dataSource];
                });
            });
        }
    }
}


#pragma mark - 刷新UI
- (void)loadData
{
    if (!_isRefresh) {
        @synchronized(self) {
            if (_isRefresh) {
                return;
            }
            _isRefresh = YES;
        }
    } else {
        return;
    }
    _page = 1;
    [self showHintNotHide:@"加载中..."];
    WEAK_SELF
    
    [[HDClient sharedClient].chatManager asyncLoadConversationsWithPage:_page limit:0 completion:^(NSArray *conversations, HDError *error) {
        [weakSelf hideHud];
        @synchronized (weakSelf) {
            _isRefresh = NO;
        }
        if (!error) {
            [self.dataSource removeAllObjects];
            switch (_type) {
                case HDConversationAccessed: {
                    _unreadcount = 0;
                    for (HDConversation *model in conversations) {
                        model.searchWord = [ChineseToPinyin pinyinFromChineseString:model.chatter.nicename];
                        [weakSelf.dataSource insertObject:model atIndex:0];
                        [_dataSourceDic setObject:model forKey:model.sessionId];
                    }
                    [super dxDelegateAction:@{@"unreadCount": [NSNumber numberWithInt:_unreadcount]}];
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

- (void)clearSeesion
{
    [[KFManager sharedInstance] setCurrentSessionId:@""];
}


#pragma mark - chatViewControllerDelegate

- (void)refreshConversationList {
    [self loadData];
}

#pragma mark - notification
- (void)conversationRefresh:(NSNotification*)notification
{
    [self refreshConversationList];
}

- (void)conversationRefreshAutoEnd:(NSNotification*)notification
{
    NSDictionary *body = notification.object;
    NSString *text = [NSString string];
    
    if ([body objectForKey:@"visitorUser"]) {
        VisitorUserModel *model = [[VisitorUserModel alloc] initWithDictionary:[body objectForKey:@"visitorUser"]];
        if (model.nicename.length > 0) {
            text = [text stringByAppendingString:model.nicename];
        }
    }
    text = [text stringByAppendingString:@" 长时间没有回应,系统已自动关闭回话"];
    NSArray *views = [self.navigationController viewControllers];
    if ([views count] > 0) {
        UIViewController *viewController =  [views objectAtIndex:[views count] - 1];
        MBProgressHUD *hud = [MBProgressHUD showMessag:text toView:viewController.view];
        [hud hide:YES afterDelay:2.0];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showMessag:text toView:self.view];
        [hud hide:YES afterDelay:2.0];
    }
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2.0];
}

- (void)endChatSession:(NSNotification*)notification
{
    WEAK_SELF
    dispatch_async(_conversationQueue, ^{
        NSString *sessionServiceId = notification.object;
        if ([weakSelf.dataSourceDic objectForKey:sessionServiceId]) {
            HDConversation *model = [weakSelf.dataSourceDic objectForKey:sessionServiceId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataSource removeObject:model];
                [weakSelf.dataSourceDic removeObjectForKey:sessionServiceId];
                [weakSelf.tableView reloadData];
            });
        }
    });
}


- (void)sort
{
    if (_type == HDConversationAccessed) {
        if ([self.dataSource count] > 0) {
            for (int i = 0; i < [self.dataSource count]; i ++) {
                HDConversation *model = [self.dataSource objectAtIndex:i];
                for (int j = i + 1; j < [self.dataSource count]; j ++) {
                    HDConversation *model2 = [self.dataSource objectAtIndex:j];
                    if (model2.lastMessage.localTime > model.lastMessage.localTime) {
                        model = model2;
                    }
                }
                [self.dataSource removeObject:model];
                [self.dataSource insertObject:model atIndex:i];
            }
        }
    }
}

@end
