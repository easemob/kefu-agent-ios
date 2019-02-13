//
//  SelectTagViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "SelectTagViewController.h"

#import "EMSearchDisplayController.h"
#import "AddTagViewController.h"
#import "RealtimeSearchUtil.h"



@interface SelectTagViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSString *tagId;
@property (nonatomic, strong) NSArray *treeArray;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, assign) BOOL isSelectRoot;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EMSearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableDictionary *tree;

@end

@implementation SelectTagViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
                        tagId:(NSString *)tagId
                    treeArray:(NSArray*)treeArray
                        color:(UIColor*)color
                 isSelectRoot:(BOOL)isSelect
{
    self = [super initWithStyle:style];
    if (self) {
        _tagId = tagId;
        _treeArray = treeArray;
        _color = color;
        _isSelectRoot = isSelect;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBarButtonItem];
    [self setUpSearchBar];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kTableViewBgColor;
    
    [self _loadTree];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpSearchBar
{
    _searchArray = [NSMutableArray array];
    _tree = [NSMutableDictionary dictionary];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索标签";
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
    self.tableView.tableHeaderView = _searchBar;
    
    _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _searchController.active = NO;
    _searchController.delegate = self;
    _searchController.searchResultsTableView.tableFooterView = [UIView new];
    
    WEAK_SELF
    [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        TagNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[TagNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
        }
        
        TagNode *node = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        if ([weakSelf.tagId isEqualToString:@"0"]) {
            TagNode *parentNode = [weakSelf _getTopParentTree:node.parentId];
            if (parentNode) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ > %@",parentNode.name,node.name];
                cell.color = [parentNode tagNodeColor];
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@",node.name];
                cell.color = [node tagNodeColor];
            }
        } else {
            cell.textLabel.text = node.name;
            cell.color = weakSelf.color;
        }
        if (!node.isEnd) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return 44.f;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [weakSelf.searchController.searchBar endEditing:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([weakSelf.searchController.resultsSource count] > indexPath.row) {
            TagNode *node = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            if (node.isEnd || weakSelf.isSelectRoot) {
                // TODO 保存标签
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_SUMMARY_RESULTS object:node];
                return;
            }
            SelectTagViewController *selectTagView = [[SelectTagViewController alloc] init];
            selectTagView.tagId = node.Id;
            selectTagView.treeArray = [node.children copy];
            if ([weakSelf.tagId isEqualToString:@"0"]) {
                TagNode *parentNode = [weakSelf _getTopParentTree:node.parentId];
                if (parentNode) {
                    selectTagView.color = [parentNode tagNodeColor];
                } else {
                    selectTagView.color = [node tagNodeColor];
                }
            } else {
                selectTagView.color = weakSelf.color;
            }
            selectTagView.title = node.name;
            [weakSelf.navigationController pushViewController:selectTagView animated:YES];
        }
    }];
    
}

- (void)setupBarButtonItem
{
    if (![_tagId isEqualToString:@"0"]) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        [self.navigationItem setHidesBackButton:YES];
    }
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [dropDownButton setTitle:@"取消" forState:UIControlStateNormal];
    [dropDownButton setTitleColor:RGBACOLOR(0xff, 0xff, 0xff, 1) forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dropDownButton];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_SUMMARY_RESULTS object:nil];
}

#pragma mark - private

- (void)_analyzeTree:(NSArray*)array
{
    if ([array isKindOfClass:[NSNull class]] || array == nil || [array count] == 0){
        return;
    }
    for (NSDictionary *dic in array) {
        TagNode *node = [[TagNode alloc] initWithDictionary:dic];
        if ([dic objectForKey:@"children"] == [NSNull null]) {
            node.isEnd = YES;
        } else {
            node.children = [dic objectForKey:@"children"];
        }
        [_searchArray addObject:node];
        [_tree setObject:node forKey:node.Id];
        if ([dic objectForKey:@"children"]) {
            [self _analyzeTree:[dic objectForKey:@"children"]];
        }
    }
}

- (TagNode*)_getTopParentTree:(NSString *)parentId
{
    if ([_tree objectForKey:parentId]) {
        TagNode *node = [_tree objectForKey:parentId];
        if ([node.parentId isEqualToString:@"0"]) {
            return node;
        } else {
            TagNode *temp = [self _getTopParentTree:node.parentId];
            return temp;
        }
    }
    return nil;
}

- (void)_loadTree
{
    if ([self.tagId isEqualToString:@"0"]) {
        if ([_treeArray count] == 0) {
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSData *jsonData = [ud objectForKey:USERDEFAULTS_DEVICE_TREE];
            NSArray *json = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
            if (json) {
                _treeArray = [json copy];
            } else {
                HDConversationManager *conversation = [[HDConversationManager alloc] init];
                WEAK_SELF
                [conversation asyncGetTreeCompletion:^(id responseObject, HDError *error) {
                    if (!error) {
                        NSArray *json = responseObject;
                        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
                        NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:json];
                        [ud setObject:jsonData forKey:USERDEFAULTS_DEVICE_TREE];
                        [ud synchronize];
                        [weakSelf _loadTree];
                    }
                }];
                return;
            }
        }
        [self _analyzeTree:_treeArray];
        for (NSDictionary *dic in _treeArray) {
            TagNode *node = [[TagNode alloc] initWithDictionary:dic];
            node.children = [dic objectForKey:@"children"];
            if ([dic objectForKey:@"children"] == [NSNull null]) {
                node.isEnd = YES;
            } else {
                node.children = [dic objectForKey:@"children"];
            }
            [self.dataSource addObject:node];
        }
    } else {
        for (NSDictionary *dic in _treeArray) {
            TagNode *node = [[TagNode alloc] initWithDictionary:dic];
            if ([dic objectForKey:@"children"] == [NSNull null]) {
                node.isEnd = YES;
            } else {
                node.children = [dic objectForKey:@"children"];
            }
            [self.dataSource addObject:node];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagNodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[TagNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
    }
    
    TagNode *node = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = node.name;
    if ([_tagId isEqualToString:@"0"]) {
        cell.color = [node tagNodeColor];
    } else {
        cell.color = _color;
    }
    if (!node.isEnd) {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
         cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataSource count] > indexPath.row) {
        TagNode *node = [self.dataSource objectAtIndex:indexPath.row];
        if (node.isEnd) {
            // TODO 保存标签
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_SUMMARY_RESULTS object:node];
            return;
        }
        UIColor *color;
        if ([_tagId isEqualToString:@"0"]) {
            color = [node tagNodeColor];
        } else {
            color = _color;
        }
        SelectTagViewController *selectTagView = [[SelectTagViewController alloc] initWithStyle:UITableViewStylePlain tagId:node.Id treeArray:[node.children copy] color:color isSelectRoot:_isSelectRoot];
        selectTagView.title = node.name;
        [self.navigationController pushViewController:selectTagView animated:YES];
    }
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
    if ([_tagId isEqualToString:@"0"]) {
        [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.searchArray searchText:(NSString *)searchText collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
            if (results) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.searchController.resultsSource removeAllObjects];
                    [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                    [weakSelf.searchController.searchResultsTableView reloadData];
                });
            }
        }];
    } else {
        [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
            if (results) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.searchController.resultsSource removeAllObjects];
                    [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                    [weakSelf.searchController.searchResultsTableView reloadData];
                });
            }
        }];
    }
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

@end
