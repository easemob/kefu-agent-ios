//
//  EMPromptBoxView.m
//  EMCSApp
//
//  Created by EaseMob on 16/6/15.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMPromptBoxView.h"
#import "QuickReplyModel.h"
#import "RealtimeSearchUtil.h"

@interface EMPromptBoxView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *resultSource;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *searchText;

@end

@implementation EMPromptBoxView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
        if ([ud objectForKey:USERDEFAULTS_QUICK_REPLY]) {
            [self loadReplyFromLocal];
        } else {
            [self loadReplyFromServer];
        }
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tableView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
}

- (UITableView*)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.userInteractionEnabled = YES;
    }
    return _tableView;
}

- (NSMutableArray*)resultSource
{
    if (_resultSource == nil) {
        _resultSource = [NSMutableArray array];
    }
    return _resultSource;
}

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)loadReplyFromServer
{
    
    [[HDClient sharedClient].chatManager getQuickReplyCompletion:^(id responseObject, HDError *error) {
        if (error == nil) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSData *arrData = [NSKeyedArchiver archivedDataWithRootObject:responseObject];
            [ud setObject:arrData forKey:USERDEFAULTS_QUICK_REPLY];
            [ud synchronize];
            [self loadReplyFromLocal];
        }
    }];

}

- (void)loadReplyFromLocal
{
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSData *data = [ud objectForKey:USERDEFAULTS_QUICK_REPLY];
    NSArray *entities = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([entities isKindOfClass:[NSArray class]]) {
        [self.dataSource removeAllObjects];
        for (NSDictionary *dic in entities) {
            QuickReplyMessageModel *model = [[QuickReplyMessageModel alloc] initWithDictionary:dic];
            [self loadSubReplyFromModel:model];
        }
    }
}

- (void)loadSubReplyFromModel:(QuickReplyMessageModel*)model
{
    if (model == nil) {
        return;
    }
    if (model.children && [model.children isKindOfClass:[NSArray class]]) {
        for (NSDictionary *temp in model.children) {
            QuickReplyMessageModel *subModel = [[QuickReplyMessageModel alloc] initWithDictionary:temp];
            if (subModel.leaf) {
                [self.dataSource addObject:subModel];
            } else {
                [self loadSubReplyFromModel:subModel];
            }
        }
    }
}

#pragma mark - public

- (void)searchText:(NSString *)searchText
{
    _searchText = searchText;
    if (searchText == nil || searchText.length == 0) {
        [self.resultSource removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    WEAK_SELF
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(phrase) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([results count] == 1) {
                    weakSelf.tableView.top = 50.f;
                } else {
                    weakSelf.tableView.top = 0;
                }
                [weakSelf.resultSource removeAllObjects];
                [weakSelf.resultSource addObjectsFromArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.resultSource count] == 0) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    if ([self.resultSource count] > 5) {
        return 5;
    }
    
    return [self.resultSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeGroup"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellTypeGroup"];
    }
    QuickReplyMessageModel *model = [self.resultSource objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:model.phrase];
    if (_searchText.length > 0) {
        NSRange range = [model.phrase rangeOfString:_searchText options:NSCaseInsensitiveSearch];
        [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(41, 169, 234, 1) range:range];
        if (range.location + range.length <= str.length && range.location > 5) {
            NSRange relpaceRange = NSMakeRange(0, range.location - 5);
            [str replaceCharactersInRange:relpaceRange withString:@"..."];
        }
    }
    cell.textLabel.attributedText = str;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPromptBoxViewWithPhrase:)]) {
        QuickReplyMessageModel *model = [self.resultSource objectAtIndex:indexPath.row];
        [self.delegate didSelectPromptBoxViewWithPhrase:model.phrase];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

@end
