//
//  QuickReplyViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/4/16.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "QuickReplyViewController.h"

#import "QuickReplyAddViewController.h"
#import "QuickReplyModel.h"
#import "SWTableViewCell.h"
#import "SRRefreshView.h"
#import "QuickReplySubViewController.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"

@interface QuickReplyViewController ()<SWTableViewCellDelegate,SRRefreshDelegate,QuickReplySubViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    BOOL _isRefresh;
    QuickReplyModel *_quickReplyModel;
    dispatch_queue_t _quickReplyRefreshQueue;
    NSMutableDictionary *_selected;
}
@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EMSearchDisplayController *searchController;

@end

@implementation QuickReplyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
     [self loadReply];
    
    _dataArray = [NSMutableArray array];
    _quickReplyRefreshQueue = dispatch_queue_create("com.kefuapp.quickReplyRefreshQueue", DISPATCH_QUEUE_SERIAL);
    _selected = [NSMutableDictionary dictionary];
    
    self.title = @"常用语";
    [self.navigationItem setTitleView:self.titleBtn];//双击返回顶部
    self.navigationItem.leftBarButtonItem = self.backItem;
    // Do any additional setup after loading the view.
    
    [self.tableView addSubview:self.slimeView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setUpSearchBar];
    self.tableView.tableHeaderView = self.searchBar;
    
    
}

#pragma mark - getter

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    [_searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    _searchBar.backgroundImage = [self.view imageWithColor:[UIColor whiteColor] size:_searchBar.frame.size];
    _searchBar.tintColor = RGBACOLOR(0x4d, 0x4d, 0x4d, 1);
    [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg"] forState:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateHighlighted];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bg_select"] forState:UIControlStateSelected];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) - 0.5, self.tableView.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_searchBar addSubview:line];
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    
    WEAK_SELF
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeGroup"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellTypeGroup"];
        }
        QuickReplyMessageModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        if ([model isKindOfClass:[QuickReplyMessageModel class]]) {
            cell.textLabel.text = model.phrase;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return 50.f;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [weakSelf.searchController.searchBar endEditing:YES];
        
        QuickReplySubViewController *quickReply = [[QuickReplySubViewController alloc] init];
        quickReply.quickReplyModel = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        NSMutableArray *dtArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *sub in quickReply.quickReplyModel.children) {
            QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:sub];
            [dtArr addObject:subModel];
        }
        quickReply.dataArray = dtArr;
        quickReply.delegate = weakSelf;
        [weakSelf.navigationController pushViewController:quickReply animated:YES];
        return;
    }];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeGroup"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellTypeGroup"];
    }
    QuickReplyMessageModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.phrase;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QuickReplySubViewController *quickReply = [[QuickReplySubViewController alloc] init];
    quickReply.quickReplyModel = [self.dataArray objectAtIndex:indexPath.row];
    quickReply.dataArray = [NSMutableArray arrayWithArray:[self.dataSource objectAtIndex:indexPath.row]];
    quickReply.delegate = self;
    [self.navigationController pushViewController:quickReply animated:YES];
    return;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    WEAK_SELF
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataArray searchText:(NSString *)searchText collationStringSelector:@selector(phrase) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
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
    [self loadReply];
    [_slimeView endRefresh];
}

#pragma QuickReplySubViewDelegate

- (void)clickQuickReplyMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(sendQuickReplyMessage:)]){
        [self.delegate sendQuickReplyMessage:message];
    }
}

#pragma mark - private
- (void)loadReply
{
    WEAK_SELF
    [self showHintNotHide:@"加载快捷回复..."];
    [[HDClient sharedClient].chatManager getQuickReplyCompletion:^(id responseObject, HDError *error) {
        [weakSelf hideHud];
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                [weakSelf.dataSource removeAllObjects];
                [weakSelf.dataArray removeAllObjects];
                NSArray *entities = responseObject;
                for (NSDictionary *dic in entities) {
                    QuickReplyMessageModel *model = [[QuickReplyMessageModel alloc] initWithDictionary:dic];
                    [weakSelf.dataArray addObject:model];
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    if (model.children && [model.children isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *temp in model.children) {
                            QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:temp];
                            [array addObject:subModel];
                        }
                    }
                    [_selected setObject:[NSNumber numberWithBool:NO] forKey:model.Id];
                    [weakSelf.dataSource addObject:array];
                }
            }
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:@"获取快捷回复失败"];
        }
    }];
    
}

- (void)loadReplyFromLocal
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSData *jsonData = [ud objectForKey:USERDEFAULTS_QUICK_REPLY];
    NSDictionary *responseObject = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        [self.dataSource removeAllObjects];
        [self.dataArray removeAllObjects];
        NSArray *entities = [responseObject objectForKey:@"entities"];
        for (NSDictionary *dic in entities) {
            QuickReplyMessageModel *model = [[QuickReplyMessageModel alloc] initWithDictionary:dic];
            [self.dataArray addObject:model];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if (model.children && [model.children isKindOfClass:[NSArray class]]) {
                for (NSDictionary *temp in model.children) {
                    QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:temp];
                    [array addObject:subModel];
                }
            }
            [_selected setObject:[NSNumber numberWithBool:NO] forKey:model.Id];
            [self.dataSource addObject:array];
        }
    }
    [self.tableView reloadData];
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
