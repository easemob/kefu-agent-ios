//
//  KFLeaveMsgDetailHeadView.m
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFLeaveMsgDetailHeadView.h"
#define kMargin 10
#define kHeight 120
#define kBoldFont [UIFont systemFontOfSize:18]
#define kFigureFont [UIFont systemFontOfSize:12]

CGFloat rowHeight;
@interface KFLeaveMsgDetailHeadView () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation KFLeaveMsgDetailHeadView
{
    HLeaveMessage *_model;
    NSInteger       _row;
    CGFloat         _height;
    NSArray       *_modelHeights;
}
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.rowHeight = 40;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (instancetype)initWithModel:(HLeaveMessage *)model dataSource:(NSMutableArray *)dataSource heights:(NSArray *)heights{
    
    CGFloat height = 0;
    for (NSNumber *heightObj in heights) {
        height += [heightObj floatValue];
    }
    
    if (self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, height)]) {
        _model = model;
        _height = height;
        _modelHeights = heights;
        self.dataSource = dataSource;
        [self setup];
    }
    return self;
}

- (instancetype)initWithModel:(HLeaveMessage *)model dataSource:(NSMutableArray *)dataSource height:(CGFloat)height{
    if (self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, height)]) {
        _model = model;
         _height = height;
        self.dataSource = dataSource;
        [self setup];
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _tapTableview();
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = _dataSource[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    return cell;
}
- (void)setup {
    [self addSubview:self.tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    if (_modelHeights[indexPath.row]) {
        height = [_modelHeights[indexPath.row] floatValue];
    }
    return height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
