//
//  KFMonitorInfoViewItem.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/23.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInfoViewItem.h"

@implementation KFMonitorItemInfo
- (instancetype)initWithTitleName:(NSString *)aTitleName
                            count:(NSInteger)aCount
                            color:(NSString *)aColor {
    if (self = [super init]) {
        _title = aTitleName;
        _count = aCount;
        _colorStr = aColor;
    }
    
    return self;
}
@end

@interface KFMonitorInfoViewItem()
@end

@implementation KFMonitorInfoViewItem

+ (KFMonitorInfoViewItem *)monitorInfoModelWithName:(NSString *)name
                                               type:(KFMonitorInfoViewItemType)aType
                                              infos:(NSArray *)aInfos {
    return  [self monitorInfoModelWithName:name type:aType infos:aInfos showInfoType:DetailType];
}

+ (KFMonitorInfoViewItem *)monitorInfoModelWithName:(NSString *)name
                                               type:(KFMonitorInfoViewItemType)aType
                                              infos:(NSArray *)aInfos
                                       showInfoType:(KFMonitorInfoViewItemShowInfoType)infoType{
    
    KFMonitorInfoViewItem *ret = [[KFMonitorInfoViewItem alloc] init];
    ret.suffixStr = @"";
    ret.type = aType;
    ret.infos = aInfos;
    ret.name = name;
    // 图表类型
    switch (aType) {
        case KFMonitorInfoViewItem_ChartType:
        {
            NSMutableArray *series = [NSMutableArray array];
            NSMutableArray *titles = [NSMutableArray array];
            NSMutableArray *colors = [NSMutableArray array];
            for (int i = 0; i < aInfos.count; i++) {
                KFMonitorItemInfo *info = aInfos[i];
                [titles addObject:info.title];
                NSMutableArray *placeholderAry = [NSMutableArray array];
                for (int j = 0; j < i ; j++) {
                    [placeholderAry addObject:@""];
                }
                [placeholderAry addObject:@(info.count)];
                AASeriesElement *elmnent = AAObject(AASeriesElement).dataSet(placeholderAry);

                
                elmnent.nameSet(info.title);
                [series addObject:elmnent];
                if (info.colorStr) {
                    [colors addObject:info.colorStr];
                }
            }
            ret.chartModel = AAObject(AAChartModel)
            .chartTypeSet(AAChartTypeColumn)
            .yAxisVisibleSet(true)
            .yAxisTitleSet(@"")
            .colorsThemeSet(colors)
            .backgroundColorSet(@"#ffffff")
            .seriesSet(series)
            .stackingSet(AAChartStackingTypeNormal);
            ret.chartModel.categories = titles;
            ret.chartModel.xAxisVisible = YES;
            ret.chartModel.title = name;
            ret.chartModel.xAxisLabelsEnabledSet((infoType == TitleType) ? YES : NO);
            ret.chartModel.yAxisTickInterval = @1;
            ret.chartModel.yAxisMin = 0;
            ret.chartModel.xAxisLabelsFontSize = @9;
            if (infoType == DetailType) {
                ret.chartModel.xAxisTickInterval = @1;
                ret.chartModel.legendEnabled = YES;
            }else {
                ret.chartModel.xAxisTickInterval = @6;
                ret.chartModel.legendEnabled = NO;
            }
            ret.chartModel.yAxisLabelsEnabled = YES;
        }
            break;
        case KFMonitorInfoViewItem_LabelType:
        {
            
        }
            break;
        case KFMonitorInfoViewItem_InstrumentType:{
            
        }
            break;
            
        default:
            break;
    }

    return ret;
}

@end
