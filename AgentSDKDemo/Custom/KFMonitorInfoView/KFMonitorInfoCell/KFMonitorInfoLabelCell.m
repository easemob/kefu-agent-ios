//
//  KFMonitorInfoLabelCell.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInfoLabelCell.h"
#import "KFMonitorLabelModel.h"
#import "RadioButton.h"

#define kMonitorInfoLabelStartCount 200001
@interface KFMonitorInfoLabelCell() <UITableViewDelegate, UITableViewDataSource>{
    KFMonitorLabelModel *_model;
    NSMutableArray *_btnArys;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *itemContorl;
@property (nonatomic, strong) UIView *headView;
@end

@implementation KFMonitorInfoLabelCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tableView];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[self configureTheConstraintArrayWithItem:self.tableView toItem:self]];
    }
    return self;
}

- (void)setItem:(KFMonitorInfoViewItem *)item {
    _item = item;
    _model = (KFMonitorLabelModel *)_item.infos.firstObject;
    if (_model.type == KFMonitorLabelModel_TeamsType) {
        self.tableView.tableHeaderView = self.headView;
        if (_model.selectedType == KFMonitorLabelModel_AgentType) {
            [_btnArys[0] setSelected:YES];
        }else {
            [_btnArys[1] setSelected:YES];
        }
    }else {
        self.tableView.tableHeaderView = nil;
    }
    
    [self.tableView reloadData];
}

- (void)onRadioButtonValueChanged:(UIButton *)btn {
    if (_delegate) {
        [_delegate didSelectedType:(btn.tag % 2) itemIndex:self.item.index];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.selectedType == KFMonitorLabelModel_AgentType ? _model.agents.count : _model.teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = UIColor.grayColor;
        cell.backgroundColor = UIColor.whiteColor;
    }
    
    NSArray *ary = _model.selectedType == KFMonitorLabelModel_AgentType ? _model.agents : _model.teams;
    NSDictionary *dic = ary[indexPath.row];
    cell.textLabel.text = dic.allKeys.firstObject;
    if ([dic.allKeys.firstObject isEqualToString:@"满意度"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",dic[dic.allKeys.firstObject],@"分"];
    }else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",dic[dic.allKeys.firstObject],_item.suffixStr];
    }
    
    return cell;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        _btnArys = [NSMutableArray array];
        CGRect btnRect = CGRectMake(20, 10, 100, 30);
        int i = 1000000;
        for (NSString * optionTitle in @[@"客服", @"技能组"]) {
            RadioButton* btn = [[RadioButton alloc] initWithFrame:btnRect];
            btn.tag = i;
            [btn addTarget:self action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventTouchUpInside];
            btnRect.origin.x += btnRect.origin.x + btnRect.size.width + 1;
            [btn setTitle:optionTitle forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [btn setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
            [_headView addSubview:btn];
            [_btnArys addObject:btn];
            i++;
        }
        [_btnArys[0] setGroupButtons:_btnArys]; // 把按钮放进群组中
        [_btnArys[0] setSelected:YES]; // 初始化第一个按钮为选中状态
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height - 1, [UIScreen mainScreen].bounds.size.width, 1)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.alpha = 0.5;
        [_headView addSubview:lineView];
    }
    
    return _headView;
}

- (UISegmentedControl *)itemContorl {
    if (!_itemContorl) {
        _itemContorl = [[UISegmentedControl alloc] initWithItems:@[@"Agent",@"items"]];
    }
    
    return _itemContorl;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}


@end
