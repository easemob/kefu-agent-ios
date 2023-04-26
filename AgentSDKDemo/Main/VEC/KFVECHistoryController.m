//
//  KFVECHistoryController.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/24.
//  Copyright © 2023 环信. All rights reserved.
//

#import "KFVECHistoryController.h"
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
#import "HDVECAgoraCallManager.h"
#import "KFVecCallHistoryModel.h"
#import "KFVECCallTableViewCell.h"
#import "HDVECAgoraCallManager.h"
#import "KFVECHistoryOptionViewController.h"



#define BUTTON_HEIGHT 44
@interface VECDXHistoryCell : KFVECCallTableViewCell

@property (nonatomic, strong) EMTagView *tagView;
@property (nonatomic, strong) UILabel *tagCountLabel;

- (void)setHistoryConversationModel:(KFVecCallHistoryModel *)model;

@end

@implementation VECDXHistoryCell

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

- (void)setHistoryConversationModel:(KFVecCallHistoryModel *)model
{
    [super setVECHistoryModel:model];
//    if ([model.summarys isKindOfClass:[NSArray class]] &&[model.summarys count] > 0) {
//        NSArray *firstTag = [model.summarys objectAtIndex:0];
//        if ([firstTag isKindOfClass:[NSArray class]]) {
//            if ([firstTag count] == 1) {
//                TagNode *rootNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:0]];
//                [_tagView setWithRootNode:rootNode childNode:nil];
//            } else if ([firstTag count] >= 2) {
//                TagNode *rootNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:0]];
//                TagNode *childNode = [[TagNode alloc] initWithDictionary:[firstTag objectAtIndex:[firstTag count]-1]];
//                [_tagView setWithRootNode:rootNode childNode:childNode];
//            }
//        }
//
//        if ([model.summarys count] >= 2) {
//            _tagCountLabel.text = [NSString stringWithFormat:@"(%@)",@((int)[model.summarys count])];
//            _tagCountLabel.hidden = NO;
//        } else {
//            _tagCountLabel.hidden = YES;
//        }
//    } else {
//        _tagCountLabel.hidden = YES;
//        [_tagView setWithRootNode:nil childNode:nil];
//    }
//    self.contentLabel.text = [NSString stringWithFormat:@"%@ - %@", @"客服" ,model.agentUserNiceName];
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
@interface KFVECHistoryController ()<SWTableViewCellDelegate,UISearchBarDelegate,VECHistoryOptionDelegate>
{
    BOOL hasMore;
    BOOL _isRefresh;
    NSString *_originType;
    NSString *_categoryIds;
    NSString *_categoryType;
    NSInteger _totalCount;
    NSMutableDictionary *_parameters;
}

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) UILabel *headerView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIBarButtonItem *optionItem;
@property (nonatomic, strong) EMHeaderImageView *headerImageView;
@property (nonatomic, strong) NSMutableArray *searchDataArray;


@end

@implementation KFVECHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"视频记录";
    
    [self.navigationItem setTitleView:self.titleBtn];//双击返回顶部
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.headerImageView];
    self.navigationItem.rightBarButtonItem = self.optionItem;
    
    [self initData]; //请求历史会话的参数
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
        VECDXHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[VECDXHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VECCellTypeConversation"];
            cell.rightUtilityButtons = [self rightButtons];
        }
        if ([self.dataSource count] == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VECCellTypeConversationCustom"];
            cell.textLabel.text = @"没有记录";
            cell.backgroundColor = UIColor.whiteColor;
            cell.textLabel.textColor = UIColor.grayColor;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            return cell;
        }
        cell.delegate = self;
        KFVecCallHistoryModel *model = [self.dataSource objectAtIndex:indexPath.row];
        [cell setHistoryConversationModel:model];
        return cell;
    } else if (indexPath.section == 1) {
        KFVECDXLoadmoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VECCellTypeConversationLoadMore"];
        if (cell == nil) {
            cell = [[KFVECDXLoadmoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VECCellTypeConversationLoadMore"];
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
//            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeCallBackChat];
//            HDHistoryConversation *model = [self.dataSource objectAtIndex:indexPath.row];
//            chatView.conversationModel = model;
//            [self.navigationController pushViewController:chatView animated:YES];
        } else {
//            ChatViewController *chatView = [[ChatViewController alloc] initWithtype:ChatViewTypeCallBackChat];
//            HDHistoryConversation *model = [self.dataSource objectAtIndex:indexPath.row];
//            chatView.conversationModel = model;
//            [self.navigationController pushViewController:chatView animated:YES];
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
            [[HDClient sharedClient].chatManager asyncFetchCreateSessionWithVistorId:model.vistor.agentId completion:^(HDHistoryConversation *history, HDError *error) {
                [self hideHud];
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

#pragma mark - VECHistoryOptionDelegate
- (void)vecHistoryOptionWithParameters:(NSMutableDictionary *)parameters
{
    _page = 0;
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    _parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [self loadDataWithParameters:_parameters];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchDataArray removeAllObjects];
    [self.searchDataArray addObjectsFromArray:self.dataSource];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:self.searchDataArray];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchController dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.searchDataArray searchText:searchText
                                       collationStringSelector:@selector(description)
                                                   resultBlock:^(NSArray *results) {
        if (results) {
            hd_dispatch_main_async_safe(^(){
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
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
    KFVECHistoryOptionViewController *historyOption = [[KFVECHistoryOptionViewController alloc] init];
    historyOption.optionDelegate = self;
    historyOption.type = VECEMHistoryOptionType;
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
    _page = 0;
}

- (void)loadDataWithParameters:(NSMutableDictionary*)parameters
{
    if (parameters == nil) {
        parameters = [NSMutableDictionary dictionary];
        NSString *currentDate = [self formatDate:[NSDate date]];
        NSArray * state = @[@"Processing",@"Terminal",@"Abort"];
        [parameters hd_setValue:[NSNumber numberWithInteger:_page] forKey:@"pageNum"];
//        [parameters hd_setValue:@1000 forKey:@"pageSize"];
        [parameters hd_setValue:[HDClient sharedClient].currentAgentUser.tenantId forKey:@"tenantId"];
        [parameters hd_setValue:[HDClient sharedClient].currentAgentUser.agentId forKey:@"agentUserId"];
        [parameters hd_setValue:state forKey:@"state"];
        [parameters setObject:[NSString stringWithFormat:@"%@00:00:00",currentDate] forKey:@"createDateFrom"];
        [parameters setObject:[NSString stringWithFormat:@"%@24:00:00",currentDate] forKey:@"createDateTo"];
    }
    [parameters hd_setValue:[NSNumber numberWithInteger:_page] forKey:@"pageNum"];
    [parameters hd_setValue:[NSNumber numberWithInteger:hPageSize] forKey:@"pageSize"];
    [self showHintNotHide:@"加载历史记录"];
    WEAK_SELF
    // 获取视频记录
    [ [HDClient sharedClient].vecCallManager vec_getRtcSessionhistoryParameteData:parameters completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {
        [weakSelf hideHud];
        if (!error) {
            
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary * dic = responseObject;
                if (_page == 0) {
                    [weakSelf.dataSource removeAllObjects];
                }
                _page++;
                NSInteger totalNum =[[dic objectForKey:@"totalElements"] integerValue];
                _totalCount = totalNum;
                weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[weakSelf.dataSource count]),@(_totalCount)];
                if ([[dic allKeys] containsObject:@"entities"] && [[dic valueForKey:@"entities"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray * array = [dic valueForKey:@"entities"];
                    
                    NSArray * tmpModelArray = [KFVecCallHistoryModel arrayOfModelsFromDictionaries:array error:nil];
                    
                    [weakSelf.dataSource addObjectsFromArray:tmpModelArray];
                    
                    if (weakSelf.dataSource&&weakSelf.dataSource.count> 0) {
                        weakSelf.headerView.text = [NSString stringWithFormat:@"   当前展示数%@ (总共 %@)",@((int)[weakSelf.dataSource count]),@(_totalCount)];
                        if (totalNum < hPageSize) {
                            hasMore = NO;
                        } else {
                            if (_totalCount > [weakSelf.dataSource count]) {
                                hasMore = YES;
                            } else {
                                hasMore = NO;
                            }
                        }

                        hd_dispatch_main_async_safe(^(){
                            [weakSelf.tableView reloadData];
                        });
                        
                    }
                }
            }

        } else {
            hd_dispatch_main_async_safe((^(){
                weakSelf.headerView.text = [NSString stringWithFormat:@"  当前展示数%@ (总共 %@)",@(0),@(0)];
                [weakSelf showHint:@"加载失败"];
            }));
        }

    }];
    


}

#pragma mark 点击menu执行
- (void)reloadData {
    _page = 0;
    [self loadDataWithParameters:_parameters];
}

- (void)loadData
{
    [self loadDataWithParameters:_parameters];
}

- (NSString *)formatDate:(NSDate*)date
{
    if (date) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd "];
        NSString *string = [format stringFromDate:date];
        return [string stringByAppendingString:@""];
    }
    return @"";
}

@end
