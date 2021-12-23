//
//  AdminHomeViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/6/29.
//  Copyright © 2016年 easemob. All rights reserved.
//

#pragma mark - 管理员
//今日会话总数
#define API_GET_TOTAL_SESSION_TODAY @"daas/internal/session/today/total"

//处理中会话
#define API_GET_PROCESSING_SESSION @"daas/internal/session/today/processing"

//在线客服数
#define API_GET_ONLINECUSTOMER @"daas/internal/agent/online"

//今日消息数
#define API_GET_TOTALMESSAGES_TODAY @"daas/internal/message/today/total"

//会话量趋势
#define API_GET_SESSION_TREND @"daas/internal/session/trend"

//消息量趋势
#define API_GET_MESSAGE_TREND @"daas/internal/message/trend"

//今日客服新进会话数tenantId
#define API_GET_NEWSESSION_TODAY @"daas/internal/agent/kpi/session/today"

typedef NS_ENUM(NSUInteger, CardType) {
    CardTypeSessionToday=39,
    CardTypeProcessSession,
    CardTypeCustomersOnline,
    CardTypeMessagesToday
};

@interface DataCard : UIView
- (instancetype)initWithFrame:(CGRect)frame cardType:(CardType)cardType;

- (void)updateCount:(NSString *)count;
@end

@implementation DataCard
{
    UILabel *_countLabel;
}

- (instancetype)initWithFrame:(CGRect)frame cardType:(CardType)cardType {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.width-10, self.height*2/5)];
        _countLabel.text = @"0";
        _countLabel.font = [UIFont boldSystemFontOfSize:26];
        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_countLabel.frame)+2, self.width-10, 15)];
        tip.font = [UIFont systemFontOfSize:12];
        tip.textColor = [UIColor grayColor];
        NSString *tips = @"";
        UIColor *textColor = nil;
        if (cardType == CardTypeSessionToday) {
            textColor = RGBACOLOR(110, 171, 34, 1);
            tips = @"今日新会话数";
        }
        if (cardType == CardTypeProcessSession) {
            textColor = RGBACOLOR(88, 89, 21, 1);
            tips = @"处理中会话数";
        }
        if (cardType == CardTypeCustomersOnline) {
            textColor = RGBACOLOR(253, 95, 21, 1);
            tips = @"在线客服数";
        }
        if (cardType == CardTypeMessagesToday) {
            textColor = RGBACOLOR(27, 158, 230, 1);
            tips = @"今日消息数";
        }
        tip.text = tips;
        tip.textColor = textColor;
        _countLabel.textColor = textColor;
        [self addSubview:_countLabel];
        [self addSubview:tip];
        self.layer.borderWidth = 0.5;
        self.tag = cardType;
        self.layer.borderColor = [UIColor grayColor].CGColor;
    }
    return self;
}

- (void)updateCount:(NSString *)count {
    _countLabel.text = count;
}

@end

#import "AdminHomeViewController.h"
#import "KFScreenViewController.h"
#import "KFTrendDataModel.h"
#import "AAChartView.h"
#import "SRRefreshView.h"

@interface AdminHomeViewController () <KFScreenViewControllerDelegate,SRRefreshDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *backView;
@property (nonatomic, strong) SRRefreshView *slimeView;
@end

@implementation AdminHomeViewController

{
    AAChartView *_chartSession; //会话量趋势
    AAChartView *_chartMessage; //消息量趋势
    AAChartView *_chartNewSessionToday;//浸提客服新近会话数
    NSArray*_colors;
    
    TrendDataType _currentChartType;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initOption];
    [self setupUI];
    [self loadData];
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
- (void)loadData {
    [self loadDataToday];
    [self loadDataSessions];
    [self loadDataMessages];
    [self loadNewSessionToday];
}

- (void)loadDataToday {
    //今日会话总数
    NSString *pathSessionCount = API_GET_TOTAL_SESSION_TODAY;
    [[KFHttpManager sharedInstance] asyncGetCountWithPath:pathSessionCount parameters:nil completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSString class]]) {
                DataCard *view = [_backView viewWithTag:CardTypeSessionToday];
                [view updateCount:responseObject];
            }
        }
    }];
    //处理中的会话
    NSString *pathProcessing = API_GET_PROCESSING_SESSION;
    [[KFHttpManager sharedInstance] asyncGetCountWithPath:pathProcessing parameters:nil completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSString class]]) {
                DataCard *view = [_backView viewWithTag:CardTypeProcessSession];
                [view updateCount:responseObject];
            }
        }
    }];
    //在线客服
    NSString *pathOnline = API_GET_ONLINECUSTOMER;
    [[KFHttpManager sharedInstance] asyncGetCountWithPath:pathOnline parameters:nil completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSString class]]) {
                DataCard *view = [_backView viewWithTag:CardTypeCustomersOnline];
                [view updateCount:responseObject];
            }
        }
    }];

    //今日消息数
    NSString *pathMessages = API_GET_TOTALMESSAGES_TODAY;
    [[KFHttpManager sharedInstance] asyncGetCountWithPath:pathMessages parameters:nil completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            if ([responseObject isKindOfClass:[NSString class]]) {
                DataCard *view = [_backView viewWithTag:CardTypeMessagesToday];
                [view updateCount:responseObject];
            }
        }
    }];
}

- (void)submitOptions:(KFScreenOption *)option {
    if (_currentChartType == TrendDataTypeSession) {
        [self loadDataSessions];
    } else {
        [self loadDataMessages];
    }
}


- (void)loadDataSessions {
    KFScreenOption *option = [KFScreenOption shareInstance];
    NSDictionary *para = @{
                           @"beginDateTime":@(option.sessionOption.beginTimeInterval*1000),
                           @"endDateTime":@(option.sessionOption.endTimeInterval*1000),
                           @"dateInterval":option.sessionOption.displayPa
                           };
    [[KFHttpManager sharedInstance] asyncGetSessionTrendWithPath:API_GET_SESSION_TREND parameters:para completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            NSDictionary *dict = responseObject;
            KFTrendDataModel *model = [[KFTrendDataModel alloc] initWithDictionary:dict];
            [self reloadTrendData:model trendDataType:TrendDataTypeSession];
        }
    }];
}


- (void)loadDataMessages {
    KFScreenOption *option = [KFScreenOption shareInstance];
    NSDictionary *para = @{
                           @"beginDateTime":@(option.messageOption.beginTimeInterval*1000),
                           @"endDateTime":@(option.messageOption.endTimeInterval*1000),
                           @"dateInterval":option.messageOption.displayPa
                           };
    [[KFHttpManager sharedInstance] asyncGetMessageTrendWithPath:API_GET_MESSAGE_TREND parameters:para completion:^(id responseObject, NSError *error) {
        if (error == nil) {
            NSDictionary *dict = responseObject;
            KFTrendDataModel *model = [[KFTrendDataModel alloc] initWithDictionary:dict];
            [self reloadTrendData:model trendDataType:TrendDataTypeMessage];
        }
    }];
}

- (void)loadNewSessionToday {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [[KFHttpManager sharedInstance] aysncGetNewSessionTodayWithPath:API_GET_NEWSESSION_TODAY completion:^(id responseObject, NSError *error) {
        if (nil == error) {
            NSArray *response = responseObject;
            if ([response isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in response) {
                    TodayModel *model = [[TodayModel alloc] initWithDictionary:dic];
                    [models addObject:model];
                }
                [self reloadNewSessionData:models];
            }
        }
    }];
}

- (void)reloadNewSessionData:(NSArray <TodayModel *> *)src {
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:0];
    for (TodayModel *model in src) {
        [categories addObject:model.agentNiceName];
        [dataSource addObject:@[model.count]];
    }
    AAChartModel *chartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"今日客服新进会话报表")
    .yAxisTitleSet(@"")
    .categoriesSet(categories)
    .seriesSet(@[
               AAObject(AASeriesElement)
               .nameSet(@"新进会话")
               .dataSet(dataSource)
               ]
)
    ;
    chartModel.dataLabelEnabled = YES;
    [_chartNewSessionToday aa_drawChartWithChartModel:chartModel];//图表视图对象调用图表模型对象,绘制最终图形
//    [_chartNewSessionToday aa_refreshChartWithChartModel:chartModel];//更新 AAChartModel 数据之后,刷新图表
}



- (void)reloadTrendData:(KFTrendDataModel *)model trendDataType:(TrendDataType)type{
    
    NSInteger dayNum = model.types.count;  //元素的数目
    NSMutableDictionary *rstDic = [NSMutableDictionary dictionary];
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<dayNum; i++) {
        TypeModel *type = model.types[i];
        NSDictionary *dict = type.valueDic;
        [rstDic addEntriesFromDictionary:dict];
    }
    NSArray *timeIn = [self sortArray:rstDic.allKeys];
    for (int i=0; i<dayNum; i++) {
        TypeModel *type = model.types[i];
        NSDictionary *dict = type.valueDic;
        NSMutableArray *marr = [NSMutableArray arrayWithCapacity:0];
        for (int j=0; j<timeIn.count; j++) {
            NSString *key = timeIn[j];
            NSNumber *numObj = [dict objectForKey:key];
            if (numObj) {
                [marr addObject:numObj];
            } else {
                [marr addObject:@0];
            }
        }
        [dataSource addObject:AAObject(AASeriesElement)
         .nameSet([self getStandardName:type.type])
         .dataSet(marr.copy)];
    }
    NSMutableArray *mr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *time in timeIn) {
        [mr addObject:[self timeWithTimeIntervalString:time trendType:type]];
    }
    AAChartModel *chartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .yAxisTitleSet(@"")
    .categoriesSet(mr)
    .seriesSet(dataSource)
    ;
    chartModel.dataLabelEnabled = YES;
    if (type == TrendDataTypeSession) {
        [_chartSession aa_drawChartWithChartModel:chartModel];//图表视图对象调用图表模型对象,绘制最终图形
//        [_chartSession aa_refreshChartWithChartModel:chartModel];//更新 AAChartModel 数据之后,刷新图表
    }
    if (type == TrendDataTypeMessage) {
        [_chartMessage aa_drawChartWithChartModel:chartModel];//图表视图对象调用图表模型对象,绘制最终图形
//        [_chartMessage aa_refreshChartWithChartModel:chartModel];//更新 AAChartModel 数据之后,刷新图表
    }
   

}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString trendType:(TrendDataType )type
{
    NSString *display = @"日";
    KFScreenOption *option = [KFScreenOption shareInstance];
    if (type == TrendDataTypeSession) {
        display = option.sessionOption.display;
    } else {
        display = option.messageOption.display;
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    if ([display isEqualToString:@"周"]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitWeekOfYear;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        return [NSString stringWithFormat:@"wk%ld/%ld",(long)comps.weekOfYear,(long)comps.year];
    } else if ([display isEqualToString:@"月"]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        return [NSString stringWithFormat:@"%d/%d",(int)comps.month,(int)comps.year];
    } else {
        // 格式化时间
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone localTimeZone];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"MM-dd"];
        // 毫秒值转化为秒
        NSString * dateString = [formatter stringFromDate:date];
        return dateString;
    }
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone localTimeZone];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString * dateString = [formatter stringFromDate:date];
    return dateString;
}
- (NSString *)getStandardName:(NSString *)lite {
    NSString *rst = lite;
    if ([lite isEqualToString:@"app"]) {
        rst = @"手机APP";
    }
    if ([lite isEqualToString:@"webim"]) {
        rst = @"网页";
    }
    if ([lite isEqualToString:@"weixin"]) {
        rst = @"微信";
    }
    if ([lite isEqualToString:@"weibo"]) {
        rst = @"微博";
    }
    if ([lite isEqualToString:@"phone"]) {
        rst = @"呼叫中心";
    }
    return rst;
}


#pragma mark - action

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeftView" object:nil];
}

//private
- (UIScrollView *)backView {
    if (_backView == nil) {
        _backView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _backView.delegate = self;
        _backView.backgroundColor = kTableViewHeaderAndFooterColor;
    }
    return _backView;
}

- (void)loadDataTodayWithAni:(UIButton *)sender {
    [UIView animateWithDuration:1.0f animations:^{
       sender.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        sender.transform = CGAffineTransformMakeRotation(M_PI*2);
    }];
    [self loadDataToday];
}


- (void)setupUI {
    [self.view addSubview:self.backView];
    _colors = @[[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor cyanColor],[UIColor blueColor],[UIColor purpleColor]];
    self.title = @"首页";
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, KScreenWidth, 40)];
    title.text = @"今日数据";
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor whiteColor];
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:15];
    [_backView addSubview:title];
    UIButton *update = [UIButton buttonWithType:UIButtonTypeCustom];
    [update setImage:[UIImage imageNamed:@"update"] forState:UIControlStateNormal];
    update.frame = CGRectMake(KScreenWidth-60, 20, 40, 40);
    [update addTarget:self action:@selector(loadDataTodayWithAni:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:update];
    for (int i=0; i<4; i++) {
        DataCard *card = [[DataCard alloc] initWithFrame:CGRectMake(i%2*KScreenWidth/2-1, i/2*80+60, KScreenWidth/2, 80) cardType:i+CardTypeSessionToday];
        [_backView addSubview:card];
    }

    //会话量趋势
    UILabel *trendLabelSession = [[UILabel alloc] initWithFrame:CGRectMake(-1, 260, KScreenWidth+2, 40)];
    trendLabelSession.textAlignment = NSTextAlignmentCenter;
    trendLabelSession.backgroundColor = [UIColor whiteColor];
    trendLabelSession.layer.borderWidth = 1;
    trendLabelSession.layer.borderColor = [UIColor grayColor].CGColor;
    trendLabelSession.font = [UIFont systemFontOfSize:14];
    trendLabelSession.text = @"会话量趋势";
    UIButton *choose = [UIButton buttonWithType:UIButtonTypeCustom];
    choose.frame = CGRectMake(trendLabelSession.width-60, CGRectGetMinY(trendLabelSession.frame)+5, 30, 30);
    choose.tag = TrendDataTypeSession;
    [choose setImage:[UIImage imageNamed:@"shai"] forState:UIControlStateNormal];
    [choose addTarget:self action:@selector(setOption:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:trendLabelSession];
    [_backView addSubview:choose];
    
    _chartSession = [self chartViewWithFrame:CGRectMake(0, CGRectGetMaxY(trendLabelSession.frame), KScreenWidth, 300)];
    [_backView addSubview:_chartSession];

    //消息量趋势
    UILabel *trendLabelMessage = [[UILabel alloc] initWithFrame:CGRectMake(-1, CGRectGetMaxY(_chartSession.frame)+20, KScreenWidth+2, 40)];
    trendLabelMessage.textAlignment = NSTextAlignmentCenter;
    trendLabelMessage.backgroundColor = [UIColor whiteColor];
    trendLabelMessage.layer.borderWidth = 1;
    trendLabelMessage.layer.borderColor = [UIColor grayColor].CGColor;
    trendLabelMessage.font = [UIFont systemFontOfSize:14];
    trendLabelMessage.text = @"消息量趋势";
    UIButton *messageChoose = [UIButton buttonWithType:UIButtonTypeCustom];
    messageChoose.frame = CGRectMake(trendLabelSession.width-60, CGRectGetMinY(trendLabelMessage.frame)+5, 30, 30);
    [messageChoose setImage:[UIImage imageNamed:@"shai"] forState:UIControlStateNormal];
    [messageChoose addTarget:self action:@selector(setOption:) forControlEvents:UIControlEventTouchUpInside];
    messageChoose.tag = TrendDataTypeMessage;
    [_backView addSubview:trendLabelMessage];
    [_backView addSubview:messageChoose];
    _chartMessage = [self chartViewWithFrame:CGRectMake(0, CGRectGetMaxY(trendLabelMessage.frame), KScreenWidth, 300)];
    [_backView addSubview:_chartMessage];
    //浸提客服新进会话数报表
    _chartNewSessionToday = [self chartViewWithFrame:CGRectMake(0, CGRectGetMaxY(_chartMessage.frame)+20, KScreenWidth, 300)];
    [_backView addSubview:_chartNewSessionToday];
    
    _backView.contentSize = CGSizeMake(KScreenWidth, CGRectGetMaxY(_chartNewSessionToday.frame)+80);
    [_backView addSubview:self.slimeView];
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
    [self loadData];
    [_slimeView endRefresh];
}

//设置会话量趋势的选项
- (void)setOption:(UIButton *)sender {
    KFScreenViewController *screenVC = [[KFScreenViewController alloc] initWithType:sender.tag];
    screenVC.delegate = self;
    _currentChartType = sender.tag;
    [self.navigationController pushViewController:screenVC animated:YES];
}

- (void)initOption {
    KFScreenOption *option = [KFScreenOption shareInstance];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *firstDay;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDay interval:nil forDate:[NSDate date]];
    NSDateComponents *lastDateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay fromDate:firstDay];
    NSUInteger dayNumberOfMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]].length;
    NSInteger day = [lastDateComponents day];
    [lastDateComponents setDay:day+dayNumberOfMonth-1];
    [lastDateComponents setHour:23];
    [lastDateComponents setMinute:59];
    NSDate *lastDay = [calendar dateFromComponents:lastDateComponents];
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    option.sessionOption.beginTimeDate = firstDay;
    option.sessionOption.endTimeDate = lastDay;
    option.sessionOption.beginTimeString = [formatter stringFromDate:firstDay];
    option.sessionOption.endTimeString = [formatter stringFromDate:lastDay];
    option.sessionOption.beginTimeInterval = [firstDay timeIntervalSince1970];
    option.sessionOption.endTimeInterval = [lastDay timeIntervalSince1970];
    option.sessionOption.display = @"日";
    option.sessionOption.displayPa = @"1d";
    option.messageOption.beginTimeDate = firstDay;
    option.messageOption.endTimeDate = lastDay;
    option.messageOption.beginTimeString = [formatter stringFromDate:firstDay];
    option.messageOption.endTimeString = [formatter stringFromDate:lastDay];
    option.messageOption.beginTimeInterval = [firstDay timeIntervalSince1970];
    option.messageOption.endTimeInterval = [lastDay timeIntervalSince1970];
    option.messageOption.display = @"日";
    option.messageOption.displayPa = @"1d";
}

- (AAChartView *)chartViewWithFrame:(CGRect)frame {
    AAChartView *chartView = [[AAChartView alloc] initWithFrame:frame];
    [chartView setScrollEnabled:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    return chartView;
}


//数组排序
- (NSArray *)sortArray:(NSArray *)srcArr {
    NSArray *desArr = [srcArr sortedArrayUsingSelector:@selector(compare:)];
    return desArr;
}



@end
