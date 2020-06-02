//
//  AddTagViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/6.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "AddTagViewController.h"
//#import "NSDictionary+SafeValue.h"
#import "SelectTagViewController.h"
#import "CommentEditViewController.h"
#import "SRRefreshView.h"
#import "EMChatHeaderTagView.h"

@implementation TagNode

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _Id = [dictionary safeStringValueForKey:@"id"];
        _parentId = [dictionary safeStringValueForKey:@"parentId"];
        _tenantId = [dictionary safeStringValueForKey:@"tenantId"];
        _name = [dictionary safeStringValueForKey:@"name"];
        _desc = [dictionary safeStringValueForKey:@"description"];
        _color = [dictionary safeIntegerValueForKey:@"color"];
        _createDateTime = [dictionary safeStringValueForKey:@"createDateTime"];
        _lastUpdateDateTime = [dictionary safeStringValueForKey:@"lastUpdateDateTime"];
        _deleted = [[NSNumber numberWithInteger:[dictionary safeIntegerValueForKey:@"deleted"]] boolValue];
    }
    return self;
}

- (UIColor*)tagNodeColor
{
    return RGBACOLOR(_color>>24 & 0xff, _color>>16 & 0xff, _color>>8 & 0xff, 1);
}

@end

@implementation TagNodeTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.left = 30.f;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 230, 231, 1).CGColor);
    //    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));
    //下分割线
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5f));
}

- (void)setColor:(UIColor *)color
{
    if (_circleView == nil) {
        _circleView = [[UIView alloc] initWithFrame:CGRectZero];
        _circleView.left = 10.f;
        _circleView.top = 16.f;
        _circleView.width = 12.f;
        _circleView.height = 12.f;
        _circleView.layer.cornerRadius = _circleView.width/2;
        [self addSubview:_circleView];
    }
    _circleView.backgroundColor = color;
}

@end

@interface EMAddTagCell : UITableViewCell

@end

@implementation EMAddTagCell

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 230, 231, 1).CGColor);
    //    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));
    //下分割线
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5f));
}

@end

@interface AddTagViewController ()<SRRefreshDelegate,EMChatHeaderTagViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong) NSArray *treeArray;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSMutableDictionary *commentDic;

@property (nonatomic, strong) SRRefreshView *slimeView;
@property (nonatomic, strong) EMChatHeaderTagView *headerTagView;

@end

@implementation AddTagViewController
{
    HDConversationManager *_conversation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会话标签与备注";
    _conversation = [[HDConversationManager alloc] initWithSessionId:_sessionId];
    // Do any additional setup after loading the view.
    [self setupBarButtonItem];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = kTableViewHeaderAndFooterColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView addSubview:self.slimeView];
    
    [self _loadTree];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSummaryResult:) name:NOTIFICATION_ADD_SUMMARY_RESULTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addComment:) name:NOTIFICATION_ADD_COMMENT object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (EMChatHeaderTagView*)headerTagView
{
    if (_headerTagView == nil) {
        _headerTagView = [[EMChatHeaderTagView alloc] initWithSessionId:_sessionId edit:YES];
        _headerTagView.delegate = self;
    }
    return _headerTagView;
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

- (void)setupBarButtonItem
{
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    UIButton *dropDownButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    if (self.saveAndEnd &&[HDClient sharedClient].currentAgentUser.isStopSessionNeedSummary) {
        dropDownButton.width = 80;
        [dropDownButton setTitle:@"保存结束" forState:UIControlStateNormal];
    } else {
        dropDownButton.width = 40;
        [dropDownButton setTitle:@"保存" forState:UIControlStateNormal];
    }
    [dropDownButton setTitleColor:RGBACOLOR(0x1b, 0xa8, 0xed, 1) forState:UIControlStateNormal];
    [dropDownButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dropDownButton];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction
{
    UserModel *user = [HDClient sharedClient].currentAgentUser;
    if (user.isStopSessionNeedSummary) {
        if ([_selectArray count] == 0) {
            [self showHint:@"请选择标签"];
            return;
        }
    }
    
    [self showHudInView:self.view hint:@"保存中..."];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_selectArray,@"array", nil];
    WEAK_SELF
    
    [_conversation asyncSaveSessionSummaryResultsParameters:parameters completion:^(id responseObject, HDError *error) {
        [weakSelf hideHud];
        if (!error) {
            [weakSelf showHint:@"保存成功"];
            if (weakSelf.saveAndEnd) { //结束会话时候
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(saveAndEndChat)]) {
                    [weakSelf.delegate saveAndEndChat];
                }
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [weakSelf showHint:@"保存失败"];
        }
    }];
    
    if ([weakSelf.commentDic objectForKey:@"comment"]) {
        [_conversation asyncSaveSessionCommentParameters:_commentDic completion:^(id responseObject, HDError *error) {
            if (error) {
                [weakSelf showHint:@"标签备注保存失败!"];
            }
        }];
    }
}

#pragma mark - private
- (void)addSummaryResult:(NSNotification*)notification
{
    if (notification.object) {
        TagNode *node = (TagNode*)notification.object;
        if (![_selectArray containsObject:node.Id]) {
            NSMutableArray *array = [self.dataSource objectAtIndex:0];
            if ([self.tree objectForKey:node.Id]) {
                [array addObject:[self.tree objectForKey:node.Id]];
                [_selectArray addObject:node.Id];
                [_headerTagView setTagDatasource:[self.dataSource objectAtIndex:0]];
                [self.tableView reloadData];
            }
            NSMutableArray *views = [NSMutableArray array];
            for (UIViewController *view in [self.navigationController viewControllers]) {
                [views addObject:view];
                if ([view isKindOfClass:[AddTagViewController class]]) {
                    break;
                }
            }
            [self.navigationController setViewControllers:views animated:YES];
        } else {
            [self showHint:@"该标签已存在"];
        }
    } else {
        NSMutableArray *views = [NSMutableArray array];
        for (UIViewController *view in [self.navigationController viewControllers]) {
            [views addObject:view];
            if ([view isKindOfClass:[AddTagViewController class]]) {
                break;
            }
        }
        [self.navigationController setViewControllers:views animated:YES];
    }
}

- (void)addComment:(NSNotification*)notification
{
    if (notification.object) {
        [_commentDic setObject:notification.object forKey:@"comment"];
        if ([self.dataSource count] >= 2) {
            NSMutableArray *array = [self.dataSource objectAtIndex:1];
            [array replaceObjectAtIndex:0 withObject:notification.object];
            [self.tableView reloadData];
        }
    }
}

- (void)_loadData
{
    
    WEAK_SELF
    [_conversation asyncGetSessionSummaryResultsCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            NSArray *arr = responseObject;
            NSMutableArray *mArr = [weakSelf.dataSource objectAtIndex:0];
            for (NSNumber *numKey in arr) {
                NSString *key = [NSString stringWithFormat:@"%@",numKey];
                [_selectArray addObject:key];
                if ([weakSelf.tree objectForKey:key]) {
                    [mArr addObject:[weakSelf.tree objectForKey:key]];
                }
            }
            [weakSelf.headerTagView setTagDatasource:[self.dataSource objectAtIndex:0]];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)_loadComment
{
    WEAK_SELF
    [_conversation asyncGetSessionCommentCompletion:^(id responseObject, HDError *error) {
        if (!error) {
            NSDictionary *json = responseObject;
            if (json != nil) {
                NSMutableArray *array = [weakSelf.dataSource objectAtIndex:1];
                [array addObject:[json objectForKey:@"comment"]];
                weakSelf.commentDic = [NSMutableDictionary dictionaryWithDictionary:json];
                [weakSelf.tableView reloadData];
            } else {
                NSMutableArray *array = [weakSelf.dataSource objectAtIndex:1];
                [array addObject:@"文字备注1000字符500文字"];
                [weakSelf.tableView reloadData];
                weakSelf.commentDic = [NSMutableDictionary dictionary];
                [weakSelf.commentDic setObject:weakSelf.sessionId forKey:@"serviceSessionId"];
            }
        }
    }];
}

- (void)_loadTree
{
    [self.dataSource removeAllObjects];
    
    NSMutableArray *array = [NSMutableArray array];
    [self.dataSource addObject:array];
    
    NSMutableArray *array1 = [NSMutableArray array];
    [self.dataSource addObject:array1];
    
    _tree = [NSMutableDictionary dictionary];
    _selectArray = [NSMutableArray array];
    
    [self showHintNotHide:@"加载中..."];
    
    WEAK_SELF
    [_conversation asyncGetTreeCompletion:^(id responseObject, HDError *error) {
        if (!error) {
            NSArray *json = responseObject;
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:json];
            [ud setObject:jsonData forKey:USERDEFAULTS_DEVICE_TREE];
            [ud synchronize];
            [weakSelf _analyzeTree:json];
            [weakSelf _loadData];
            [weakSelf _loadComment];
            _treeArray = [json copy];
            [weakSelf hideHud];
        } else {
            NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
            NSData *jsonData = [ud objectForKey:USERDEFAULTS_DEVICE_TREE];
            NSArray *json = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
            if (json) {
                [weakSelf _analyzeTree:json];
                [weakSelf _loadData];
                [weakSelf _loadComment];
                _treeArray = [json copy];
                [weakSelf hideHud];
            }
        }
    }];
}

- (void)_analyzeTree:(NSArray*)array
{
    if ([array isKindOfClass:[NSNull class]] || array == nil || [array count] == 0){
        return;
    }
    for (NSDictionary *dic in array) {
        TagNode *node = [[TagNode alloc] initWithDictionary:dic];
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

#pragma mark - EMChatHeaderTagViewDelegate

- (void)deleteTagNode:(TagNode *)node
{
    if ([_selectArray containsObject:node.Id]) {
        for (TagNode* tagNode in [self.dataSource objectAtIndex:0]) {
            if ([tagNode.Id isEqualToString:node.Id]) {
                [[self.dataSource objectAtIndex:0] removeObject:tagNode];
                break;
            }
        }
        [self.headerTagView setTagDatasource:[self.dataSource objectAtIndex:0]];
        [_selectArray removeObject:node.Id];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row ==0) {
        EMAddTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellType1"];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[EMAddTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellType1"];
            cell.backgroundColor = UIColor.whiteColor;
        }
        if (indexPath.section == 0) {
            cell.textLabel.text = @"添加会话标签";
            cell.textLabel.textColor = UIColor.grayColor;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = [_commentDic objectForKey:@"comment"];
            cell.textLabel.textColor = UIColor.grayColor;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    } else {
        EMAddTagCell *colorCell = [tableView dequeueReusableCellWithIdentifier:@"CellColor"];
        if (colorCell == nil) {
            colorCell = [[EMAddTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellColor"];
            colorCell.backgroundColor = UIColor.whiteColor;
        }
        
        [colorCell addSubview:self.headerTagView];
        colorCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return colorCell;
    }
}

/*
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row > 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *array = [self.dataSource objectAtIndex:indexPath.section];
        TagNode *node = [array objectAtIndex:indexPath.row];
        [array removeObjectAtIndex:indexPath.row];
        [_selectArray removeObject:node.Id];
        [self.tableView reloadData];
    }
}*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return _headerTagView.height + 5;
    }
    return DEFAULT_CHAT_CELLHEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [UIView new];
        view.backgroundColor = kTableViewHeaderAndFooterColor;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.left = 15;
        label.width = KScreenWidth - 20;
        label.height = 30;
        label.text = @"会话标签";
        label.textColor = RGBACOLOR(118, 118, 118, 1);
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
        return view;
    } else if (section == 1) {
        UIView *view = [UIView new];
        view.backgroundColor = kTableViewHeaderAndFooterColor;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.left = 15;
        label.width = KScreenWidth - 20;
        label.height = 30;
        label.text = @"文字备注";
        label.textColor = RGBACOLOR(118, 118, 118, 1);
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        SelectTagViewController *selectTagView = [[SelectTagViewController alloc] initWithStyle:UITableViewStylePlain tagId:@"0" treeArray:nil color:nil isSelectRoot:NO];
        selectTagView.title = @"选择会话标签";
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController pushViewController:selectTagView animated:NO];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        CommentEditViewController *edit = [[CommentEditViewController alloc] init];
        edit.comment = [_commentDic objectForKey:@"comment"];
        [self.navigationController pushViewController:edit animated:YES];
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
    [self _loadTree];
    [_slimeView endRefresh];
}

@end
