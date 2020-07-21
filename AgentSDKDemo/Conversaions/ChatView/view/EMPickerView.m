//
//  EMPickerView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMPickerView.h"

@interface EMPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    CGFloat _topHeight;
}

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation EMPickerView

- (instancetype)initWithDataSource:(NSArray *)dataSource
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        [self setDataSource:dataSource];

    }
    return self;
}

- (instancetype)initWithDataSource:(NSArray *)dataSource topHeight:(CGFloat)height
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        _topHeight = height;
        [self setDataSource:dataSource];
        
    }
    return self;
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self showPickerview];
    [_pickView reloadAllComponents];
}

#pragma mark-----pickerview
- (void)showPickerview
{
    [self setUpPickViewWithTag:1000];
}


- (void)saveStatus:(id)sender{
    NSString *value =[_dataSource objectAtIndex:[_pickView selectedRowInComponent:0]];
    if (_delegate && [_delegate respondsToSelector:@selector(savePickerWithValue:index:)]) {
        [_delegate savePickerWithValue:value index:[_pickView selectedRowInComponent:0]];
    }
    [self removeFromSuperview];
}

- (void)cancleSaveBtn:(id)sender{
    [self removeFromSuperview];
}

- (void)setUpPickViewWithTag:(NSInteger)tag{
    if (_pickerView == nil) {
        _pickerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _pickerView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        _pickerView.tag = tag;
        
        _pickView = [[UIPickerView alloc]init];
        _pickView.delegate = self;
        _pickView.dataSource = self;
        _pickView.backgroundColor = [UIColor whiteColor];
        _pickView.tag = tag + 1;
        
        _pickView.top = CGRectGetMaxY(self.frame) - _pickView.height - 64 + _topHeight;
        _pickView.width = KScreenWidth;
        [_pickerView addSubview:_pickView];
        
        UIView *btnback = [[UIView alloc]initWithFrame:CGRectMake(0, _pickView.top - 48, KScreenWidth, 48)];
        btnback.backgroundColor = [UIColor whiteColor];
        [_pickerView addSubview:btnback];
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(btnback.frame) - 1, KScreenWidth, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = 0.3;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleSaveBtn:)];
        [_pickerView addGestureRecognizer:tap];
        
        UIButton *save = [[UIButton alloc]initWithFrame:CGRectMake(KScreenWidth-80, 6.5, 70, 32)];
        [save setTitle:@"保存" forState:UIControlStateNormal];
        [save addTarget:self action:@selector(saveStatus:) forControlEvents:UIControlEventTouchUpInside];
        [save.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        save.backgroundColor = [UIColor clearColor];
        [save setTitleColor:RGBACOLOR(41, 169, 234, 1) forState:UIControlStateNormal];
        [btnback addSubview:save];
    }
    _pickerView.hidden = NO;
    [self addSubview:_pickerView];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataSource count];
}

#pragma mark -UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0, 0,0,0);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    }
    if (component == 0) {
        if ([[_dataSource objectAtIndex:row] isKindOfClass:[NSDictionary class]]) {
            pickerLabel.text =  [[_dataSource objectAtIndex:row] valueForKey:@"key"];
        } else if ([[_dataSource objectAtIndex:row] isKindOfClass:[NSString class]]){
            pickerLabel.text =  [_dataSource objectAtIndex:row];
        }
    } else {
    }
    pickerLabel.textColor = UIColor.grayColor;
    return pickerLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        [pickerView reloadAllComponents];
    }
}

- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows) {
            if(tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0) {
        UIView *frontView = [viewsArray objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        if([nextResponder isKindOfClass:[UIViewController class]]) {
            activityViewController = nextResponder;
        }
        else {
            activityViewController = window.rootViewController;
        }
    }
    return activityViewController;
}

@end
