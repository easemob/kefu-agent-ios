//
//  KFMonitorLabelModel.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    KFMonitorLabelModel_AgentType,
    KFMonitorLabelModel_TeamsType
} KFMonitorLabelModelType;

@interface KFMonitorLabelModel : NSObject
- (instancetype)initWithType:(KFMonitorLabelModelType)aType
              defineSelected:(KFMonitorLabelModelType)aSelectedType;

@property (nonatomic, assign) KFMonitorLabelModelType type;
@property (nonatomic, assign) KFMonitorLabelModelType selectedType;
@property (nonatomic, strong) NSArray *agents;
@property (nonatomic, strong) NSArray *teams;
@end
