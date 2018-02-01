//
//  HistoryConversationsController.m
//  EMCSApp
//
//  Created by dhc on 15/4/11.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "HistoryConversationsController.h"
#import "DXTableViewCellTypeConversation.h"
#import "ChatViewController.h"
#import "UserTagModel.h"
#import "SelectTagViewController.h"
#import "AddTagViewController.h"
#import "DXTimeFilterView.h"
#import "EMSearchDisplayController.h"
#import "HistoryOptionViewController.h"
#import "RealtimeSearchUtil.h"
#import "ChineseToPinyin.h"
#import "EMTagView.h"
#import "EMHeaderImageView.h"
#import "UINavigationItem+Margin.h"

#define BUTTON_HEIGHT 44

@interface DXHistoryCell : DXTableViewCellTypeConversation

@property (nonatomic, strong) EMTagView *tagView;
@property (nonatomic, strong) UILabel *tagCountLabel;

- (void)setHistoryConversationModel:(HDHistoryConversation *)model;

@end

@implementation DXHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tagView = [[EMTagView alloc] initWithRootNode:nil childNode:nil];
        [self.contentView addSubview:_tagView];
        
        _tagCountLabel = [[UILabel alloc] init];
        _tagCountLabel.frame = CGRectMake(0, 0, 30, 20);
        _tagCountLabel.textAlignment = NSTextAlignmentRight;
        _tagCountLabel.backgroundColor = [UIColor clearColor];
        _tagCountLabel.textColor = [UIColor blackColor];
        _tagCountLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:_tagCountLabel];
    }
    return self;
}

- (void)setHistoryConversationModel:(HDHistoryConversation *)model
{
    [super setHistoryModel:model];
    if (model.summarys != [NSNull null] &&[model.summarys count] > 0) {
        NSArray *firstTag = [model.summarys objectAtIndex:0];
        if ([firstTag isKindOfClass:[NSArray class]]) {
            if ([firstTag count] == 1) {
                TagNode *rootNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:0]];
                [_tagView setWithRootNode:rootNode childNode:nil];
            } else if ([firstTag count] >= 2) {
                TagNode *rootNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:0]];
                TagNode *childNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:[firstTag count]-1]];
                [_tagView setWithRootNode:rootNode childNode:childNode];
            }
        }
        
        if ([model.summarys count] >= 2) {
            _tagCountLabel.text = [NSString stringWithFormat:@"(%@)",@((int)[model.summarys count])];
            _tagCountLabel.hidden = NO;
        } else {
            _tagCountLabel.hidden = YES;
        }
    } else {
        _tagCountLabel.hidden = YES;
        [_tagView setWithRootNode:nil childNode:nil];
    }
    self.contentLabel.text = [NSString stringWithFormat:@"%@ - %@", @"客服" ,model.agentUserNiceName];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_tagCountLabel.hidden) {
        _tagView.left = self.width - _tagView.width -11;
        _tagView.top = CGRectGetMaxY(self.timeLabel.frame) + 8;
    } else {
        _tagCountLabel.top = CGRectGetMaxY(self.timeLabel.frame) + 8;
        _tagCountLabel.left = self.width - _tagCountLabel.width - 11;
        _tagCountLabel.height = _tagView.height;
        _tagView.top = CGRectGetMaxY(self.timeLabel.frame) + 8;
        _tagView.left = self.width - _tagView.width - 11 - _tagCountLabel.width;
    }
}

@end

@interface HistoryConversationsController()<SWTableViewCellDelegate,UISearchBarDelegate, UISearchDisplayDelegate,HistoryOptionDelegate>
{
    BOOL hasMore;
    BOOL _isRefresh;
    NSString *_originType;
    NSString *_categoryIds;
    NSString *_categoryType;
    NSInteger _totalCount;
    NSMutableDictionary *_parameters;
}

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) UILabel *headerView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong, nonatomic) UIBarButtonItem *optionItem;
@property (strong, nonatomic) EMHeaderImageView *headerImageView;

@end


@implementation HistoryConversationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"历史会话列表";
    if (self.userId.length) {
        if (self.userId.length > 6) {
            self.title = [NSString stringWithFormat:@"%@...历史会话",[self.userId substringToIndex:6]];
        } else {
            self.title = [NSString stringWithFormat:@"%@历史会话",self.userId];
        }
    }
    [self.navigationItem setTitleView:self.titleBtn];//双击返回顶部
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
    self.navigationItem.rightBarButtonItem = self.optionItem;
    
    [self initData]; //请求历史会话的参数
    [self setUpSearchBar];
    [self.view addSubview:self.searchBar];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.top = self.searchBar.height;
    self.tableView.height -= self.searchBar.height;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kTableViewBgColor;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (EMHeaderImageView*)headerImageView
{
    return [KFManager sharedInstance].headImageView;
}

- (UIBarButtonItem*)optionItem
{
    if (_optionItem == nil) {
        UIButton *optionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [optionButton setImage:[UIImage imageNamed:@"agents_icon_shai_Text2"] forState:UIControlStateNormal];
        [optionButton setImage:[UIImage imageNamed:@"agents_icon_shai_Text2"] forState:UIControlStateSelected];
        optionButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [optionButton addTarget:self action:@selector(optionAction) forControlEvents:UIControlEventTouchUpInside];
        _optionItem = [[UIBarButtonItem alloc] initWithCustomView:optionButton];
    }
    return _optionItem;
}

- (UILabel*)headerView
{
    if (_headerView == nil) {
        _headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _headerView.backgroundColor = RGBACOLOR(229, 229, 229, 1);
        _headerView.font = [UIFont systemFontOfSize:12.f];
        _headerView.textColor = RGBACOLOR(26, 26, 26, 1);
        _headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@(0),@(0)];
    }
    return _headerView;
}

- (void)setUpSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    [_searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    _searchBar.backgroundImage = [self.view imageWithColor:RGBACOLOR(0xef, 0xef, 0xf4, 1) size:_searchBar.frame.size];
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
        DXHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[DXHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.rightUtilityButtons = [weakSelf rightButtons];
        }
        
        cell.delegate = weakSelf;
        HDHistoryConversation *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
        [cell setHistoryConversationModel:model];
        return cell;
    }];
    
    [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return DEFAULT_CHAT_CELLHEIGHT;
    }];
    
    [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [weakSelf.searchController.searchBar endEditing:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([weakSelf.searchController.resultsSource count] > indexPath.row) {
            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeCallBackChat];
            HDHistoryConversation *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            chatView.conversationModel = model;
            [weakSelf.navigationController pushViewController:chatView animated:YES];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([self.dataSource count] == 0) {
            return 1;
        }
        return [self.dataSource count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DXHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[DXHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.rightUtilityButtons = [self rightButtons];
        }
        if ([self.dataSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
            cell.textLabel.text = @"没有记录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        cell.delegate = self;
        HDHistoryConversation *model = [self.dataSource objectAtIndex:indexPath.row];
        [cell setHistoryConversationModel:model];
        return cell;
    } else if (indexPath.section == 1) {
        DXLoadmoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversationLoadMore"];
        if (cell == nil) {
            cell = [[DXLoadmoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationLoadMore"];
        }
        [cell setHasMore:hasMore];
        return cell;
    }
    
    return nil;
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
    if (indexPath.section == 0) {
        if ([self.dataSource count] == 0) {
            return;
        }
        if (_userId && _userId.length > 0) {
            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeCallBackChat];
            HDHistoryConversation *model = [self.dataSource objectAtIndex:indexPath.row];
            chatView.conversationModel = model;
            [self.navigationController pushViewController:chatView animated:YES];
        } else {
            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeCallBackChat];
            HDHistoryConversation *model = [self.dataSource objectAtIndex:indexPath.row];
            chatView.conversationModel = model;
            [self.navigationController pushViewController:chatView animated:YES];
        }
    } else {
        if (hasMore) {
            [self loadData];
        }
    }
}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            HDHistoryConversation *model = [self.dataSource objectAtIndex:cellIndexPath.row];
            [self showHintNotHide:@"回呼中..."];
            WEAK_SELF
            [[HDClient sharedClient].chatManager asyncFetchCreateSessionWithVistorId:model.chatter.userId completion:^(HDHistoryConversation *history, HDError *error) {
                if (error == nil) {
                    ChatViewController *chatView = [[ChatViewController alloc] init];
                    chatView.conversationModel = model;
                    model.chatter = model.vistor;
                    [[KFManager sharedInstance] setCurrentSessionId:model.sessionId];
                    [[KFManager sharedInstance].wait loadData];
                    [weakSelf.navigationController pushViewController:chatView animated:YES];
                } else {
                     [weakSelf showHint:error.errorDescription];
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

#pragma mark - HistoryOptionDelegate
- (void)historyOptionWithParameters:(NSMutableDictionary *)parameters
{
    _page = 1;
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    _parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [self loadDataWithParameters:_parameters];
    [self.navigationController popViewControllerAnimated:YES];
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
    searchText = [ChineseToPinyin pinyinFromChineseString:searchText];
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(searchWord) resultBlock:^(NSArray *results) {
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


#pragma mark - private
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:RGBACOLOR(41, 170, 234, 1) title:@"回呼"];
    return rightUtilityButtons;
}

#pragma mark - action

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"historyBackAction" object:nil];
}

- (void)optionAction
{
    HistoryOptionViewController *historyOption = [[HistoryOptionViewController alloc] init];
    historyOption.optionDelegate = self;
    historyOption.type = EMHistoryOptionType;
    [self.navigationController pushViewController:historyOption animated:YES];
}

- (void)endChatAction
{
//    if (_endPicker.hidden) {
//        _endPicker.hidden = NO;
//    } else {
//        _endPicker.hidden = YES;
//    }
    SelectTagViewController *selectTagView = [[SelectTagViewController alloc] initWithStyle:UITableViewStylePlain tagId:@"0" treeArray:nil color:nil isSelectRoot:YES];
//    selectTagView.conversation =
    selectTagView.title = @"选择会话标签";
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:selectTagView animated:NO];
}

#pragma mark - data


- (void)initData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    _endDate = [[DXTimeFilterView curWeek] objectForKey:@"last"];
    _startDate = [[DXTimeFilterView curWeek] objectForKey:@"first"];
    _page = 1;
    _originType = @"";
    _categoryIds = @"";
    _categoryType = @"0";
}

- (void)loadDataWithParameters:(NSMutableDictionary*)parameters
{
    if (parameters == nil) {
        parameters = [NSMutableDictionary dictionary];
        
        if (_startDate) {
            [parameters setObject:[self formatDate:_startDate] forKey:@"beginDate"];
        }
        
        if (_endDate) {
            [parameters setObject:[self formatDate:_endDate] forKey:@"endDate"];
        }
        [parameters setObject:@"Terminal" forKey:@"state"];
        [parameters setObject:@"-1" forKey:@"subCategoryId"];
        [parameters setObject:@"-1"  forKey:@"categoryId"];
        if (_originType) {
            [parameters setObject:_originType forKey:@"originType"];
        }
        
        UserModel *user = [HDClient sharedClient].currentAgentUser;

        BOOL isAgent = [user.userType isEqualToString:@"Agent"];
        
        [parameters setObject:@(isAgent) forKey:@"isAgent"];
        if (_categoryType) {
            [parameters setObject:_categoryType forKey:@"categoryType"];
        }
        if (_categoryIds) {
            [parameters setObject:_categoryIds forKey:@"categoryIds"];
        }
        if (_categoryIds) {
            [parameters setObject:_categoryIds forKey:@"summaryIds"];
        }
    }

    if (_userId && _userId.length > 0) {
        [parameters setObject:_userId forKey:@"visitorName"];
    }
    
    [self showHintNotHide:@"加载历史记录"];
    WEAK_SELF

    [[HDClient sharedClient].chatManager asyncFetchHistoryConversationWithPage:_page limit:hPageLimit parameters:parameters completion:^(NSArray *conversations, HDError *error, NSInteger totalNum) {
        [weakSelf hideHud];
        if (!error) {
            if (_page == 1) {
                [weakSelf.dataSource removeAllObjects];
            }
            _page++;
            _totalCount = totalNum;
            for (HDHistoryConversation *model in conversations) {
                model.searchWord = [ChineseToPinyin pinyinFromChineseString:model.vistor.nicename];
                [weakSelf.dataSource addObject:model];
            }
            weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[weakSelf.dataSource count]),@(_totalCount)];
            if (totalNum < hPageLimit) {
                hasMore = NO;
            } else {
                if (_totalCount > [self.dataSource count]) {
                    hasMore = YES;
                } else {
                    hasMore = NO;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        } else {
            weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@(0),@(0)];
            [weakSelf showHint:@"加载失败"];
        }
    }];

}

#pragma mark 点击menu执行
- (void)reloadData {
    _page = 1;
    [self loadDataWithParameters:_parameters];
}

- (void)loadData
{
    [self loadDataWithParameters:_parameters];
}

- (NSString*)formatDate:(NSDate*)date
{
    if (date) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000"];
        NSString *string = [format stringFromDate:date];
        return [string stringByAppendingString:@"Z"];
    }
    return @"";
}

@end
