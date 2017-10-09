//
//  JNGroupViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/12/29.
//  Copyright © 2015年 easemob. All rights reserved.
//

#import "JNGroupViewController.h"
#import "EMSearchDisplayController.h"
#import "CustomerChatViewController.h"
#import "DXTableViewCellType1.h"
#import "RealtimeSearchUtil.h"
#import "HomeViewController.h"
#import "ChineseToPinyin.h"
#import "SRRefreshView.h"
#import "JNGroupViewController.h"

@interface JiNengGroup : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *queueId;

- (instancetype)initWithName:(NSString*)name
                      detail:(NSString*)detail
                     queueId:(NSString*)queueId;

@end

@implementation JiNengGroup

- (instancetype)initWithName:(NSString *)name
                      detail:(NSString *)detail
                     queueId:(NSString*)queueId
{
    self = [super init];
    if (self) {
        _name = name;
        _detail = detail;
        _queueId = queueId;
    }
    return self;
}

@end

@implementation DXTableViewCellType1 (JNGroup)

- (void)setJiNengGroupModel:(JiNengGroup *)model;
{
    self.headerImageView.image = [UIImage imageNamed:@"default_agent_avatar"];
    self.titleLabel.text = model.name;
    self.contentLabel.text = model.detail;
    if ([model.detail isEqualToString:@"(0/0)"]) {
        self.userInteractionEnabled = NO;
    } else {
        self.userInteractionEnabled = YES;
    }
}

@end

@interface JNGroupViewController ()<UISearchBarDelegate, UISearchDisplayDelegate,SRRefreshDelegate>
{
    NSString *_curRemoteAgentId;
    BOOL _isRefresh;
    int _customerUnreadcount;
    UILabel *_resultLabel;
    JiNengGroup *_curModel;
    dispatch_queue_t _jnRefreshQueue;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableDictionary *dataSourceDic;

@property (strong, nonatomic) SRRefreshView *slimeView;

@end

@implementation JNGroupViewController
{
    HDConversationManager *_com;
}

@synthesize searchBar = _searchBar;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _com = [[HDConversationManager alloc] initWithSessionId:_serviceSessionId];
    
    _jnRefreshQueue = dispatch_queue_create("com.kefuapp.jnRefresh", DISPATCH_QUEUE_SERIAL);
    
    [self setUpSearchBar];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addSubview:self.slimeView];
    
    [self loadData];
    self.title = @"技能组";
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
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

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2.5, 0, self.tableView.frame.size.width-5, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    [_searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    _searchBar.backgroundImage = [self.view imageWithColor:RGBACOLOR(0xef, 0xef, 0xf4, 1) size:_searchBar.frame.size];
    _searchBar.tintColor = RGBACOLOR(0x4d, 0x4d, 0x4d, 1);
    self.tableView.tableHeaderView = _searchBar;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) - 0.5, self.tableView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:line];
    self.tableView.tableHeaderView = _searchBar;
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    
}

#pragma mark - private
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jinengAction
{
    JNGroupViewController *jn = [[JNGroupViewController alloc] init];
    jn.serviceSessionId = [_serviceSessionId copy];
    [self.navigationController pushViewController:jn animated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(tableView == self.searchDisplayController.searchResultsTableView){
        if ([self.searchController.resultsSource count] == 0) {
            return 1;
        }
        return [self.searchController.resultsSource count];
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DXTableViewCellType1 *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[DXTableViewCellType1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchController.resultsSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有搜索到……";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
    }
    
    JiNengGroup *group = tableView != self.searchDisplayController.searchResultsTableView ? [self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];
    [cell setJiNengGroupModel:group];
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DEFAULT_CHAT_CELLHEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
    }
    JiNengGroup *group = tableView != self.searchDisplayController.searchResultsTableView ? [self.dataSource objectAtIndex:indexPath.row]:[self.searchController.resultsSource objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定将该会话转接给%@吗？",group.name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
    _curModel = group;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex && alertView.tag == 1000) {
        [self showHintNotHide:@"转接中..."];
//        NSString *path = [NSString stringWithFormat:@"v1/ServiceSession/%@/AgentQueue/%@",self.serviceSessionId,_curModel.queueId];
        WEAK_SELF
        
        [_com transferConversationWithQueueId:_curModel.queueId completion:^(id responseObject, HDError *error) {
            [weakSelf hideHud];
            if (!error) {
                [weakSelf showHint:@"会话已转接"];
                [[KFManager sharedInstance].wait loadData];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(popToRoot)]) {
                    [weakSelf.delegate popToRoot];
                }
            } else {
                [weakSelf hideHud];
            }
        }];
    }
}


#pragma mark - data

- (void)loadData
{
    WEAK_SELF
    dispatch_async(_jnRefreshQueue, ^{
        [_com getSkillGroupCompletion:^(id responseObject, HDError *error) {
            if (error == nil) {
                [weakSelf.dataSource removeAllObjects];
                NSDictionary *json = responseObject;
                
                for (NSDictionary *dic in json) {
                    NSDictionary *agentQueue = [dic objectForKey:@"agentQueue"];
                    if ([agentQueue objectForKey:@"queueGroupType"] && [[agentQueue objectForKey:@"queueGroupType"] isEqualToString:@"SystemDefault"]) {
                        continue;
                    }
                    id agentUsers = [agentQueue objectForKey:@"agentUsers"];
                    NSString *detail = @"";
                    if ([agentUsers isKindOfClass:[NSArray class]]) {
                        int count = 0;
                        for (NSDictionary *user in agentUsers) {
                            if ([user objectForKey:@"onLineState"] && [[user objectForKey:@"onLineState"] isEqualToString:@"Online"]) {
                                count++;
                            }
                        }
                        detail = [NSString stringWithFormat:@"(%d/%lu)",count,(unsigned long)[agentUsers count]];
                    }
                    JiNengGroup *group = [[JiNengGroup alloc] initWithName:[agentQueue objectForKey:@"queueName"] detail:detail queueId:[agentQueue objectForKey:@"queueId"]];
                    [weakSelf.dataSource addObject:group];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
        }];
    });
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        return;
    }
    NSString *search = [ChineseToPinyin pinyinFromChineseString:searchText];
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)search collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    //    searchBar.userInteractionEnabled = NO;
    //    [self performSelector:@selector(searchBarEnabled) withObject:nil afterDelay:2.0];
    return YES;
}

- (void)searchBarEnabled
{
    _searchBar.userInteractionEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:@""];
        }
    }
    return YES;
}

#pragma mark - private
- (void)clearSession
{
    _curRemoteAgentId = @"";
}

- (void)searhResign
{
    [_searchBar resignFirstResponder];
}

- (void)sort
{
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
@end
