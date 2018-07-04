//
//  KFMonitorInfoViewItem.h
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/23.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "AAChartModel.h"
#import "KFMonitorLabelModel.h"
#import "KFMonitorInstrumentModel.h"

@interface KFMonitorItemInfo : NSObject
- (instancetype)initWithTitleName:(NSString *)aTitleName
                            count:(NSInteger)aCount
                            color:(NSString *)aColor;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *colorStr;
@property (nonatomic, assign, readonly) NSInteger count;

@end

typedef enum : NSUInteger {
    KFMonitorInfoViewItem_ChartType,
    KFMonitorInfoViewItem_LabelType,
    KFMonitorInfoViewItem_InstrumentType
} KFMonitorInfoViewItemType;

typedef enum : NSUInteger {
    TitleType,
    DetailType
} KFMonitorInfoViewItemShowInfoType;

@interface KFMonitorInfoViewItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *infos;
@property (nonatomic, strong) AAChartModel *chartModel; // 表格model，直接用的ChartView的。
@property (nonatomic, strong) KFMonitorLabelModel *lableModel;
@property (nonatomic, strong) KFMonitorInstrumentModel *insModel;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *suffixStr;
//@property (nonatomic, strong) 
@property (nonatomic, assign) KFMonitorInfoViewItemType type;
+ (KFMonitorInfoViewItem *)monitorInfoModelWithName:(NSString *)name
                                               type:(KFMonitorInfoViewItemType)aType
                                              infos:(NSArray *)aInfos;


+ (KFMonitorInfoViewItem *)monitorInfoModelWithName:(NSString *)name
                                               type:(KFMonitorInfoViewItemType)aType
                                              infos:(NSArray *)aInfos
                                       showInfoType:(KFMonitorInfoViewItemShowInfoType)infoType;
@end
