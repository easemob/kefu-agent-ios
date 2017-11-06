//
//  ReminderView.m
//  AgentSDKDemo
//
//  Created by afanda on 11/1/17.
//  Copyright © 2017 环信. All rights reserved.
//

#define Margin 20
#define TipHeight 200

#import "ReminderView.h"

@implementation ReminderView

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self setSubViews:dictionary];
    }
    return self;
}

- (void)setSubViews:(NSDictionary *)dic {
    UIView *tipView = [[UIView alloc] init];
    tipView.width = self.width - Margin*2;
    tipView.height = TipHeight;
    tipView.layer.cornerRadius = 5;
    tipView.layer.masksToBounds = YES;
    tipView.center = self.center;
    tipView.backgroundColor = [UIColor whiteColor];
    [self addSubview:tipView];
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(Margin, Margin, 150, 20)];
    label.text = @"租户到期提醒";
    label.font = [UIFont systemFontOfSize:18];
    [tipView addSubview:label];
    NSString *tipString = @"";
    NSString *str1 = [dic valueForKey:@"tenantId"];
    NSString *str2 = @"";
    NSString *status = [dic valueForKey:@"status"];
    if ([status isEqualToString:@"Disable"]) {
        str2 = @"已过期";
    } else if ([status isEqualToString:@"Enable"]){
        str2 = @"正常";
    } else {
        str2 = @"异常";
    }
    NSString *str3 = @"0";
//    if ([status isEqualToString:@"正常"]) {
    NSTimeInterval leftTime = [[dic valueForKey:@"agreementExpireTime"] floatValue]/1000 - [[NSDate date] timeIntervalSince1970];
    NSInteger day = leftTime/60/60/24;
    if (leftTime<0) {
        day = 0;
    }
    str3 = [NSString stringWithFormat:@"%ld",day];
    NSTimeInterval expireTime = [[dic valueForKey:@"agreementExpireTime"] floatValue];
    NSString *str4 = [self dateFormatWith:expireTime];
    tipString = [NSString stringWithFormat:@"您的租户ID: %@\n您的租户状态: %@\n剩余天数: %@\n到期时间: %@",str1,str2,str3,str4];
    UILabel *m = [[UILabel alloc] initWithFrame:CGRectMake(Margin, CGRectGetMaxY(label.frame)+Margin, tipView.width - 2*Margin, TipHeight-CGRectGetMaxY(label.frame)-4*Margin)];
    m.text = tipString;
    m.font = [UIFont systemFontOfSize:15];
    m.numberOfLines = 0;
    [tipView addSubview:m];
    
    UIButton *ok = [UIButton buttonWithType:UIButtonTypeCustom];
    ok.frame = CGRectMake(tipView.width - 80, tipView.height - 50, 60, 40);
    [ok setTitle:@"确定" forState:UIControlStateNormal];
    [ok setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(reLogin) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:ok];
    
}

- (void)reLogin {
    [[HDClient sharedClient] logoutCompletion:^(HDError *error) {
        [[KFManager sharedInstance] showLoginViewController];
    }];
}

- (NSString *)dateFormatWith:(NSTimeInterval)timeInterval {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    return [format stringFromDate:date];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
