//
//  KFLineChart.h
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFStatuLabel.h"

@interface KFLineChartModel :NSObject

@property (nonatomic, assign) HDAgentLoginStatus status;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) CGFloat percentage;

@end

@interface KFLineChart : UIView

@property (nonatomic, copy) NSArray *models;

@end
