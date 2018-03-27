//
//  KFMonitorInfoView.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/22.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInfoView.h"
#import "KFMonitorInfoChartViewCell.h"
#import "KFMonitorInfoLabelCell.h"
#import "KFMonitorInfoCell.h"
#import "KFMonitorInfoInstrumentCell.h"

#define kItemsViewHeight 44
#define kTargetStartFlag 10001

#define kUnSelectedColor [UIColor lightGrayColor]
#define kSelectedColor [UIColor whiteColor]

static NSString *const chartCellId = @"ChartCell";
static NSString *const labelCellId = @"labelCell";
static NSString *const instrumentCellId = @"instrumentCell";

@interface KFMonitorInfoView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, KFMonitorInfoLabelCellDelegate>
{
    CGRect _selfFrame;
    int _selectFlag;
}

@property (nonatomic, strong) UIScrollView *titleScroll;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@end

@implementation KFMonitorInfoView

- (instancetype)initWithFrame:(CGRect)aFrame items:(NSArray *)aItems {
    if (self = [super initWithFrame:aFrame]) {
        self.items = [aItems mutableCopy];
        [self registerCustomCell];
        [self setupUI];
    }
    return self;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
    [self.collectionView reloadData];
}

- (void)updateCorrentShowItem:(KFMonitorInfoViewItem *)item {
    self.items[_selectFlag - kTargetStartFlag] = item;
    [self.collectionView reloadData];
}

- (void)registerCustomCell {
    [self.collectionView registerClass:[KFMonitorInfoChartViewCell class]
            forCellWithReuseIdentifier:chartCellId];
    
    [self.collectionView registerClass:[KFMonitorInfoLabelCell class]
            forCellWithReuseIdentifier:labelCellId];

    [self.collectionView registerClass:[KFMonitorInfoInstrumentCell class]
            forCellWithReuseIdentifier:instrumentCellId];
    
}

- (void)setupUI {
    [self addSubview:self.collectionView];
    [self addSubview:self.titleScroll];
    [self setupTitleScroll];
}

- (void)setupTitleScroll {
    float flagX = 0;
    for (int i = 0; i < self.items.count; i++) {
        KFMonitorInfoViewItem *item = self.items[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTag:kTargetStartFlag + i];
        [btn setTitle:item.name forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setTitleColor:kUnSelectedColor forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.frame = CGRectMake(flagX, 0, btn.frame.size.width + 40, kItemsViewHeight);
        flagX += btn.frame.size.width;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleScroll addSubview:btn];
    }
    [self.titleScroll addSubview:self.lineView];
    [self.titleScroll setContentSize:CGSizeMake(flagX, kItemsViewHeight)];
    _selectFlag = kTargetStartFlag;
}

- (void)btnAction:(UIButton *)btn {
    [self selectedButtonWithFlag:(int)btn.tag];
    // todo actions
}

- (void)selectedButtonWithFlag:(int)selectedFlag{
    if (_selectFlag != 0) {
        UIButton *unSelectedBtn = (UIButton *)[self.titleScroll viewWithTag:_selectFlag];
        [unSelectedBtn setTitleColor:kUnSelectedColor forState:UIControlStateNormal];
    }
    
    UIButton *selectedBtn = (UIButton *)[self.titleScroll viewWithTag:selectedFlag];
    
    CGFloat offset = selectedBtn.center.x - self.titleScroll.bounds.size.width * 0.5;
    CGFloat maxOffset = self.titleScroll.contentSize.width - selectedBtn.bounds.size.width - self.titleScroll.bounds.size.width;
    if (offset < 0) {
        offset = 0;
    }else if(offset > maxOffset + selectedBtn.bounds.size.width){
        offset = maxOffset + selectedBtn.bounds.size.width;
    }
    
    CGPoint titPoint = CGPointMake(offset , 0);
    [self.titleScroll setContentOffset:titPoint animated:YES];
    
    [selectedBtn setTitleColor:kSelectedColor forState:UIControlStateNormal];
    [UIView animateWithDuration:0.1 animations:^{
        self.lineView.frame = CGRectMake(selectedBtn.frame.origin.x, kItemsViewHeight - 3, selectedBtn.frame.size.width, 3);
    }];
    
    CGPoint collectionPoint = CGPointMake((selectedFlag - kTargetStartFlag) * self.collectionView.frame.size.width, 0);
    [self.collectionView setContentOffset:collectionPoint animated:YES];
    
    _selectFlag = selectedFlag;
    _currentShowItem = self.items[_selectFlag - kTargetStartFlag];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleScroll.frame = CGRectMake(0, 0, self.frame.size.width, kItemsViewHeight);
    self.collectionView.frame = CGRectMake(0, kItemsViewHeight, self.frame.size.width, self.frame.size.height - kItemsViewHeight);
    [self selectedButtonWithFlag:_selectFlag];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KFMonitorInfoViewItem *item = self.items[indexPath.row];
    KFMonitorInfoCell *cell = nil;
    switch (item.type) {
        case KFMonitorInfoViewItem_ChartType:{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:chartCellId forIndexPath:indexPath];
            [(KFMonitorInfoChartViewCell *)cell setItem:item];
        }
            break;
        case KFMonitorInfoViewItem_LabelType:{
             cell = [collectionView dequeueReusableCellWithReuseIdentifier:labelCellId forIndexPath:indexPath];
            [(KFMonitorInfoLabelCell *)cell setItem:item];
            [(KFMonitorInfoLabelCell *)cell setDelegate:self];
        }
            break;
        case KFMonitorInfoViewItem_InstrumentType:{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:instrumentCellId forIndexPath:indexPath];
            [(KFMonitorInfoInstrumentCell *)cell setItem:item];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    int flag = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
    [self selectedButtonWithFlag:(kTargetStartFlag + flag)];
    // todo actions
}

- (void)didSelectedType:(NSInteger)aType itemIndex:(NSInteger)index {
    if (_delegate) {
        [_delegate didSelectedItemIndex:index type:aType];
    }
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBounces:NO];
    }
    
    return _collectionView;
}

- (UIScrollView *)titleScroll {
    if (!_titleScroll) {
        _titleScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [_titleScroll setBackgroundColor:[UIColor redColor]];
        [_titleScroll setShowsVerticalScrollIndicator:NO];
        [_titleScroll setShowsHorizontalScrollIndicator:NO];
        [_titleScroll setBackgroundColor:[UIColor blackColor]];
    }
    return _titleScroll;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:[UIColor whiteColor]];
    }
    return _lineView;
}

@end
