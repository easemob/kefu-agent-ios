//
//  KFMonitorLabelModel.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/25.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorLabelModel.h"

@implementation KFMonitorLabelModel
- (instancetype)initWithType:(KFMonitorLabelModelType)aType
              defineSelected:(KFMonitorLabelModelType)aSelectedType {
    if (self = [super init]) {
        _type = aType;
        _selectedType = aSelectedType;
    }
    return self;
}

- (NSArray *)aryFromSelected{
    if (_selectedType == KFMonitorLabelModel_AgentType) {
        return self.agents;
    } else {
        return self.teams;
    }
}

@end
