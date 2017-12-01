//
//  QuickReplySubViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "QuickReplySubViewController.h"

#import "QuickReplyAddViewController.h"
#import "SWTableViewCell.h"
#import "QuickReplyModel.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"

@protocol EMQuickReplySubCellDelegate <NSObject>

- (void)clickCellWithCell:(UITableViewCell*)cell;

@end

@interface EMQuickReplySubCell : UITableViewCell

@property (nonatomic, strong) UIButton *delButton;
@property (nonatomic, weak) id<EMQuickReplySubCellDelegate> delegate;

- (void)setModel:(QuickReplyMessageModel*)model isEidt:(BOOL)isEdit;

- (void)setSpecialModel:(QuickReplyMessageModel*)model;

@end

@implementation EMQuickReplySubCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.delButton];
    }
    return self;
}

- (UIButton*)delButton
{
    if (_delButton == nil) {
        _delButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _delButton.frame = CGRectMake(0, 0, 44, 44);
        [_delButton setImage:[UIImage imageNamed:@"phrase_delete_Ellipse"] forState:UIControlStateNormal];
        [_delButton addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
        _delButton.hidden = YES;
    }
    return _delButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_delButton.hidden) {
        self.textLabel.left = 10;
    } else {
        self.textLabel.left = 40;
    }
}

- (void)setModel:(QuickReplyMessageModel *)model isEidt:(BOOL)isEdit
{
    if (isEdit) {
        _delButton.hidden = NO;
    } else {
        _delButton.hidden = YES;
    }
    
    self.textLabel.text = model.phrase;
    [_delButton setImage:[UIImage imageNamed:@"phrase_delete_Ellipse"] forState:UIControlStateNormal];
}

- (void)setSpecialModel:(QuickReplyMessageModel *)model
{
     _delButton.hidden = NO;
    if (model.parentId == 0) {
        self.textLabel.text = @"添加常用语";
        [_delButton setImage:[UIImage imageNamed:@"phrase_new_Ellipse"] forState:UIControlStateNormal];
    } else {
        self.textLabel.text = @"添加常用语";
        [_delButton setImage:[UIImage imageNamed:@"phrase_new_Ellipse"] forState:UIControlStateNormal];
    }
}

- (void)delAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellWithCell:)]) {
        [self.delegate clickCellWithCell:self];
    }
}

@end

@interface QuickReplySubViewController ()<SWTableViewCellDelegate,QuickReplyAddViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,EMQuickReplySubCellDelegate,QuickReplySelfSubViewDelegate>
{
    BOOL _edit;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *addButton;

@end

@implementation QuickReplySubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"常用语";
    self.tableView.tableFooterView = [[UIView alloc] init];
    _edit = NO;
    [self.tableView reloadData];
    
    self.navigationItem.leftBarButtonItems = @[self.backItem,[[UIBarButtonItem alloc] initWithCustomView:self.cancelButton]];
    if (_quickReplyModel.agentUserId.length > 0) {
        [self setupBarButtonItem];
    }

    [self setUpSearchBar];
    [self.view addSubview:self.addButton];
    self.tableView.tableHeaderView = self.searchBar;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _addButton.frame =CGRectMake(_addButton.left, KScreenHeight - 120 + self.tableView.contentOffset.y , _addButton.width,_addButton.height);
}

#pragma mark - getter

- (UIButton*)addButton
{
    if (_addButton == nil) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"ic_add_menu"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
        [_addButton setBackgroundColor:kNavBarBgColor];
        _addButton.frame = CGRectMake(KScreenWidth - 60, KScreenHeight - 120, 50, 50);
        _addButton.layer.cornerRadius = _addButton.width/2;
        _addButton.hidden = YES;
    }
    return _addButton;
}

- (UIButton*)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

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
        EMQuickReplySubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeQuickReply"];
        if (cell == nil) {
            cell = [[EMQuickReplySubCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellTypeQuickReply"];
        }
        
        QuickReplyMessageModel *qrMsgModel = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        if (qrMsgModel.leaf == 0) {
            [cell setModel:qrMsgModel isEidt:NO];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            [cell setModel:qrMsgModel isEidt:NO];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return 44.f;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        QuickReplyMessageModel *qrMsgModel = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        if (qrMsgModel.leaf == 0) {
            QuickReplySubViewController *quickReply = [[QuickReplySubViewController alloc] init];
            quickReply.quickReplyModel = qrMsgModel;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if (qrMsgModel.children && [qrMsgModel.children isKindOfClass:[NSArray class]]) {
                for (NSDictionary *temp in qrMsgModel.children) {
                    QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:temp];
                    [array addObject:subModel];
                }
            }
            quickReply.dataArray = array;
            quickReply.selfDelegate = weakSelf;
            [weakSelf.navigationController pushViewController:quickReply animated:YES];
        } else {
            if ([weakSelf.delegate respondsToSelector:@selector(clickQuickReplyMessage:)]) {
                [weakSelf.delegate clickQuickReplyMessage:qrMsgModel.phrase];
            } else if ([weakSelf.selfDelegate respondsToSelector:@selector(clickQuickReplyMessage:)]) {
                [weakSelf.selfDelegate clickQuickReplyMessage:qrMsgModel.phrase];
            }
        }
    }];
}

- (void)setupBarButtonItem
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitle:@"保存" forState:UIControlStateSelected];
    [editButton setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
    [editButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_edit) {
        if (_quickReplyModel.parentId == 0) {
            return 2;
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_edit) {
        if (section == 1) {
            return 1;
        }
    }
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMQuickReplySubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeQuickReply"];
    if (cell == nil) {
        cell = [[EMQuickReplySubCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellTypeQuickReply"];
    }
    
    if (_edit) {
        if (indexPath.section == 1) {
            [cell setSpecialModel:_quickReplyModel];
            cell.delegate = self;
            return cell;
        }
    }
    QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:indexPath.row];
    if (qrMsgModel.leaf == 0) {
        [cell setModel:qrMsgModel isEidt:_edit];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        [cell setModel:qrMsgModel isEidt:_edit];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.delegate = self;
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

    if (_edit) {
        if (indexPath.section == 1) {
            [self addQuickReplyAction];
            return;
        }
        QuickReplyAddViewController *addView = [[QuickReplyAddViewController alloc] init];
        addView.delegate = self;
        QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:indexPath.row];
        addView.qrMsgModel = qrMsgModel;
        addView.parentId = _quickReplyModel.Id;
        addView.title = @"编辑快捷回复";
        [self.navigationController pushViewController:addView animated:YES];
    } else {
        QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:indexPath.row];
        if (qrMsgModel.leaf == 0) {
            QuickReplySubViewController *quickReply = [[QuickReplySubViewController alloc] init];
            quickReply.quickReplyModel = qrMsgModel;
            if (qrMsgModel.childrenArray == nil) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (qrMsgModel.children && [qrMsgModel.children isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *temp in qrMsgModel.children) {
                        QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:temp];
                        [array addObject:subModel];
                    }
                }
                qrMsgModel.childrenArray = [NSMutableArray arrayWithArray:array];
            }
            quickReply.dataArray = qrMsgModel.childrenArray;
            quickReply.selfDelegate = self;
            [self.navigationController pushViewController:quickReply animated:YES];
        } else {
            if ([self.delegate respondsToSelector:@selector(clickQuickReplyMessage:)]) {
                [self.delegate clickQuickReplyMessage:qrMsgModel.phrase];
            } else if ([self.selfDelegate respondsToSelector:@selector(clickQuickReplyMessage:)]) {
                [self.selfDelegate clickQuickReplyMessage:qrMsgModel.phrase];
            }
        }
    }
}

#pragma mark - EMQuickReplySubCellDelegate

- (void)clickCellWithCell:(UITableViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    if (cellIndexPath.section == 1) {
        [self addQuickReplyAction];
        return;
    }
    QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:cellIndexPath.row];
    [self showHintNotHide:@"删除快捷回复"];
    WEAK_SELF
    [[HDClient sharedClient].chatManager deleteQuickReplyWithId:qrMsgModel.Id completion:^(id responseObject, HDError *error) {
        [weakSelf hideHud];
        if (!error) {
            [weakSelf.dataArray removeObjectAtIndex:cellIndexPath.row];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [weakSelf.tableView endUpdates];
            [weakSelf showHint:@"已删除"];
        } else {
            [weakSelf showHint:@"删除失败"];
        }
    }];

}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            QuickReplyAddViewController *addView = [[QuickReplyAddViewController alloc] init];
            addView.delegate = self;
            QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:cellIndexPath.row];
            addView.qrMsgModel = qrMsgModel;
            addView.parentId = addView.qrMsgModel.Id;
            addView.title = @"编辑快捷回复";
            [self.navigationController pushViewController:addView animated:YES];
            [cell hideUtilityButtonsAnimated:NO];
        }
            break;
        case 1:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            QuickReplyMessageModel *qrMsgModel = [self.dataArray objectAtIndex:cellIndexPath.row];
            WEAK_SELF
            [self showHintNotHide:@"删除快捷回复"];
            [[HDClient sharedClient].chatManager deleteQuickReplyWithId:qrMsgModel.Id completion:^(id responseObject, HDError *error) {
                [weakSelf hideHud];
                if (!error) {
                    [self.dataArray objectAtIndex:cellIndexPath.row];
                    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                    [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    [weakSelf showHint:@"已删除"];
                } else {
                    [weakSelf showHint:@"删除失败"];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (void)openQuickReplyToReloadView
{
    [self.tableView reloadData];
}

- (void)longPressSwipeableTableViewCell:(QuickReplyMessageModel *)model
{
}

#pragma mark - action

- (void)cancelAction
{
    NSArray *array = self.navigationController.viewControllers;
    if ([array count] >= 3) {
        [self.navigationController popToViewController:[array objectAtIndex:[array count] - 3] animated:YES];
    }
}

- (void)editAction:(id)sender
{
    _edit = !_edit;
    _addButton.hidden = !_edit;
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    [self.tableView reloadData];
}

- (void)addAction
{
    QuickReplyAddViewController *addView = [[QuickReplyAddViewController alloc] init];
    addView.parentId = _quickReplyModel.Id;
    addView.delegate = self;
    if (_quickReplyModel.parentId == 0) {
        addView.leaf = 0;
        addView.title = @"添加子分类";
    } else {
        addView.leaf = 1;
        addView.title = @"添加常用语";
    }
    [self.navigationController pushViewController:addView animated:YES];
}

- (void)addQuickReplyAction
{
    QuickReplyAddViewController *addView = [[QuickReplyAddViewController alloc] init];
    addView.parentId = _quickReplyModel.Id;
    addView.delegate = self;
    addView.leaf = 1;
    addView.title = @"添加常用语";
    [self.navigationController pushViewController:addView animated:YES];
}

#pragma mark - private
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"编辑"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return @[];
}

#pragma mark - QuickReplyAddViewDelegate

- (void)addQuickReplyMessage:(QuickReplyMessageModel*)model
{
    if (model == nil) {
        [self.tableView reloadData];
        return;
    }
    [self.dataArray addObject:model];
    [self.tableView reloadData];
    [self refreshQuickReply];
}

- (void)refreshQuickReply
{
    [[HDClient sharedClient].chatManager getQuickReplyCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:responseObject];
                [ud setObject:data forKey:USERDEFAULTS_QUICK_REPLY];
                [ud synchronize];
            }
        }
    }]; 
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

#pragma mark - QuickReplySelfSubViewDelegate

- (void)clickQuickReplyMessage:(NSString*)message
{
    if ([self.delegate respondsToSelector:@selector(clickQuickReplyMessage:)]) {
        [self.delegate clickQuickReplyMessage:message];
    }
}

@end
