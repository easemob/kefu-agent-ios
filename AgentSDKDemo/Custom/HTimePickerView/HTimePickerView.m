

#import "HTimePickerView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ScreenHeight UIScreen.mainScreen.bounds.size.height
#define ScreenWidth UIScreen.mainScreen.bounds.size.width

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

@interface HTimePickerView()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSInteger yearRange;
    NSInteger dayRange;
    NSInteger startYear;
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    NSInteger selectedHour;
    NSInteger selectedMinute;
    NSInteger selectedSecond;
    NSCalendar *calendar;
    //左边退出按钮
    UIButton *cancelButton;
    //右边的确定按钮
    UIButton *chooseButton;
}
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UIView *contentV;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation HTimePickerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBA(0, 0, 0, 0.5);
        self.alpha = 0;
        
        UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 320)];
        contentV.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentV];
        self.contentV = contentV;
        
        self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 320)];
        self.pickerView.backgroundColor = [UIColor whiteColor]
        ;
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        
        [contentV addSubview:self.pickerView];
        //盛放按钮的View
        UIView *upVeiw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        upVeiw.backgroundColor = [UIColor whiteColor];
        [contentV addSubview:upVeiw];
        //左边的取消按钮
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(12, 0, 40, 40);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor clearColor];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelButton setTitleColor:UIColorFromRGB(0x0d8bf5) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [upVeiw addSubview:cancelButton];
        
        //右边的确定按钮
        chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 52, 0, 40, 40);
        [chooseButton setTitle:@"确定" forState:UIControlStateNormal];
        chooseButton.backgroundColor = [UIColor clearColor];
        chooseButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [chooseButton setTitleColor:UIColorFromRGB(0x0d8bf5) forState:UIControlStateNormal];
        [chooseButton addTarget:self action:@selector(configButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [upVeiw addSubview:chooseButton];
        
        self.titleL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelButton.frame), 0, ScreenWidth-104, 40)];
        [upVeiw addSubview:_titleL];
        _titleL.textColor = UIColorFromRGB(0x3f4548);
        _titleL.font = [UIFont systemFontOfSize:13];
        _titleL.textAlignment = NSTextAlignmentCenter;
        
        //分割线
        UIView *splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth, 0.5)];
        splitView.backgroundColor = UIColorFromRGB(0xe6e6e6);
        [upVeiw addSubview:splitView];
        
        
        NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        comps = [calendar0 components:unitFlags fromDate:[NSDate date]];
        NSInteger year=[comps year];
        
        startYear=year-10;
        yearRange=20;
        [self setCurrentDate:[NSDate date]];
    }
    return self;
}

#pragma mark -- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}

//确定每一列返回的东西
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            return yearRange;
        }
            break;
        case 1:
        {
            return 12;
        }
            break;
        case 2:
        {
            return dayRange;
        }
            break;
        case 3:
        {
            return 24;
        }
            break;
        case 4:
        {
            return 60;
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}

#pragma mark -- UIPickerViewDelegate
//默认时间的处理
-(void)setCurrentDate:(NSDate *)currentDate
{
    //获取当前时间
    NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    comps = [calendar0 components:unitFlags fromDate:currentDate];
    NSInteger year=[comps year];
    NSInteger month=[comps month];
    NSInteger day=[comps day];
    NSInteger hour=[comps hour];
    NSInteger minute=[comps minute];
    
    selectedYear=year;
    selectedMonth=month;
    selectedDay=day;
    selectedHour=hour;
    selectedMinute=minute;
    
    dayRange=[self isAllDay:year andMonth:month];
    
    [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
    [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
    [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
    [self.pickerView selectRow:hour inComponent:3 animated:NO];
    [self.pickerView selectRow:minute inComponent:4 animated:NO];
    
    [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
    [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
    [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
    [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
    [self pickerView:self.pickerView didSelectRow:minute inComponent:4];
    
    [self.pickerView reloadAllComponents];
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*component/6.0, 0,ScreenWidth/6.0, 30)];
    label.font=[UIFont systemFontOfSize:15.0];
    label.tag=component*100+row;
    label.textAlignment=NSTextAlignmentCenter;
    switch (component) {
        case 0:
        {
            label.text=[NSString stringWithFormat:@"%ld年",(long)(startYear + row)];
        }
            break;
        case 1:
        {
            label.text=[NSString stringWithFormat:@"%ld月",(long)row+1];
        }
            break;
        case 2:
        {
            
            label.text=[NSString stringWithFormat:@"%ld日",(long)row+1];
        }
            break;
        case 3:
        {
            label.textAlignment=NSTextAlignmentRight;
            label.text=[NSString stringWithFormat:@"%ld时",(long)row];
        }
            break;
        case 4:
        {
            label.textAlignment=NSTextAlignmentRight;
            label.text=[NSString stringWithFormat:@"%ld分",(long)row];
        }
            break;
        case 5:
        {
            label.textAlignment=NSTextAlignmentRight;
            label.text=[NSString stringWithFormat:@"%ld秒",(long)row];
        }
            break;
            
        default:
            break;
    }
    return label;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return ([UIScreen mainScreen].bounds.size.width-40)/5;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}
// 监听picker的滑动
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    comps = [calendar0 components:unitFlags fromDate:[NSDate date]];
    NSInteger year=[comps year];
    NSInteger month=[comps month];
    NSInteger day=[comps day];
    NSInteger hour=[comps hour];
    NSInteger minute=[comps minute];
    switch (component) {
        case 0:
        {
            selectedYear=startYear + row;
            if (selectedYear >= year) {
                selectedYear = year;
                [self.pickerView selectRow:year-startYear inComponent:0 animated:YES];
                if (selectedMonth > month) {
                    selectedMonth = month;
                    [self.pickerView selectRow:month-1 inComponent:1 animated:YES];
                }
                if (selectedMonth == month && selectedDay > day) {
                    selectedDay = day;
                    [self.pickerView selectRow:day-1 inComponent:2 animated:YES];
                }
                if (selectedMonth == month && selectedDay == day && selectedHour > hour) {
                    selectedHour = hour;
                    [self.pickerView selectRow:hour inComponent:3 animated:YES];
                }
                if (selectedMonth == month && selectedDay == day && selectedHour == hour &&selectedMinute > minute) {
                    selectedMinute = minute;
                    [self.pickerView selectRow:minute inComponent:4 animated:YES];
                }
            }
            dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
            [self.pickerView reloadComponent:2];
        }
            break;
        case 1:
        {
            selectedMonth=row+1;
            if (selectedYear == year && selectedMonth >= month) {
                selectedMonth = month;
                [self.pickerView selectRow:month-1 inComponent:1 animated:YES];
                if (selectedDay > day) {
                    selectedDay = day;
                    [self.pickerView selectRow:day-1 inComponent:2 animated:YES];
                }
                if (selectedDay == day && selectedHour > hour) {
                    selectedHour = hour;
                    [self.pickerView selectRow:hour inComponent:3 animated:YES];
                }
                if (selectedDay == day && selectedHour == hour && selectedMinute > minute) {
                    selectedMinute = minute;
                    [self.pickerView selectRow:minute inComponent:4 animated:YES];
                }
            }
            dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
            [self.pickerView reloadComponent:2];
        }
            break;
        case 2:
        {
            selectedDay=row+1;
            if (selectedYear == year && selectedMonth == month && selectedDay >= day) {
                selectedDay = day;
                [self.pickerView selectRow:day-1 inComponent:2 animated:YES];
                if (selectedHour > hour) {
                    selectedHour = hour;
                    [self.pickerView selectRow:hour inComponent:3 animated:YES];
                }
                if (selectedHour == hour && selectedMinute > minute) {
                    selectedMinute = minute;
                    [self.pickerView selectRow:minute inComponent:4 animated:YES];
                }
            }
        }
            break;
        case 3:
        {
            selectedHour=row;
            if (selectedYear == year && selectedMonth == month && selectedDay == day && selectedHour >= hour) {
                selectedHour = hour;
                [self.pickerView selectRow:hour inComponent:3 animated:YES];
                if (selectedMinute > minute) {
                    selectedMinute = minute;
                    [self.pickerView selectRow:minute inComponent:4 animated:YES];
                }
            }
        }
            break;
        case 4:
        {
            selectedMinute=row;
            if (selectedYear == year && selectedMonth == month && selectedDay == day && selectedHour == hour && selectedMinute > minute) {
                selectedMinute = minute;
                [self.pickerView selectRow:minute inComponent:4 animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
    
    _string =[NSString stringWithFormat:@"%ld%.2ld%.2ld%.2ld%.2ld",selectedYear,selectedMonth,selectedDay,selectedHour,selectedMinute];
}

#pragma mark -- show and hidden
- (void)showDateTimePickerView{
    [self setCurrentDate:[NSDate date]];
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        _contentV.frame = CGRectMake(0, ScreenHeight - 320, ScreenWidth, 320);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)hideDateTimePickerView{
    
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0;
        _contentV.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 320);
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
    
}
#pragma mark - private
//取消的隐藏
- (void)cancelButtonClick
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickCancelDateTimePickerView)]) {
        [self.delegate didClickCancelDateTimePickerView];
    }
    
    [self hideDateTimePickerView];
    
}

//确认的隐藏
-(void)configButtonClick
{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickFinishDateTimePickerView:)]) {
        NSString *dateStr = _string;
        if (self.formatter) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
            NSDate *date = [dateFormatter dateFromString:dateStr];
            dateStr = [self.formatter stringFromDate:date];
        }
        [self.delegate didClickFinishDateTimePickerView:dateStr];
    }
    
    [self hideDateTimePickerView];
}

-(NSInteger)isAllDay:(NSInteger)year andMonth:(NSInteger)month
{
    int day=0;
    switch(month)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            day=31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            day=30;
            break;
        case 2:
        {
            if(((year%4==0)&&(year%100!=0))||(year%400==0))
            {
                day=29;
                break;
            }
            else
            {
                day=28;
                break;
            }
        }
        default:
            break;
    }
    return day;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideDateTimePickerView];
}

@end
