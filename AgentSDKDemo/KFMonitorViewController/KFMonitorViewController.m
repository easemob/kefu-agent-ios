//
//  KFMonitorViewController.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/26.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "KFMonitorViewController.h"
#import "KFMonitorInfoView.h"
#import "HomeViewController.h"
#import "KFMonitorInstrumentModel.h"
#import "NSDate+Formatter.h"
#import <AgentSDK/AgentSDK.h>

@interface KFMonitorViewController () <KFMonitorInfoViewDelegate>
@property (nonatomic, strong) KFMonitorInfoView *monitorView;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation KFMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:UIColor.whiteColor];
    self.title = @"实时监控"; 
    [self setupBaseUI];
    [self updateRightItem];
    [self.view addSubview:self.monitorView];
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    self.monitorView.frame = frame;
    
    [self fetchMonitorInfo];
}

- (void)updateRightItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(fetchMonitorInfo)];
}


- (void)fetchMonitorInfo {
    [self updateAgentStatusDist];
    [self updateAgentLoad];
    [self updatehWaitCount];
    [self updateSessionTotalCount];
    [self updateVisterTotalCount];
    [self updateQualityTotalCount];
    [self updateConversationsWithType:HDObjectType_AgentType];
    [self updateRespnonseWithType:HDObjectType_AgentType];
    [self updateVistorWithType:HDObjectType_AgentType];
    [self updateListResponseWithType:HDObjectType_AgentType];
}

- (void)didSelectedItemIndex:(NSInteger)index type:(HDObjectType)aType {
    switch (index) {
        case 6:
            [self updateConversationsWithType:aType];
            break;
    
        case 7:
            [self updateRespnonseWithType:aType];
            break;
            
        case 8:
            [self updateVistorWithType:aType];
            break;
            
        case 9:
            [self updateListResponseWithType:aType];
            break;
        default:
            break;
    }
}

//客服状态分布
- (void)updateAgentStatusDist{
    [HDClient.sharedClient.monitorManager asyncFetchAgentStatusDistWithCompletion:^(HDAgentStatusDistCountModel *distModel, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSMutableArray *infos = [NSMutableArray array];
         [infos addObject:[[KFMonitorItemInfo alloc] initWithTitleName:@"在线"
                                                                 count:distModel.onlineCount
                                                                 color:@"#9ef14d"]];
         
         [infos addObject:[[KFMonitorItemInfo alloc] initWithTitleName:@"忙碌"
                                                                 count:distModel.busyCount
                                                                 color:@"#fb8b46"]];
         
         [infos addObject:[[KFMonitorItemInfo alloc] initWithTitleName:@"离开"
                                                                 count:distModel.leaveCount
                                                                 color:@"#5cbcf2"]];
         
         [infos addObject:[[KFMonitorItemInfo alloc] initWithTitleName:@"隐身"
                                                                 count:distModel.hiddenCount
                                                                 color:@"#fece53"]];
         
         [infos addObject:[[KFMonitorItemInfo alloc] initWithTitleName:@"离线"
                                                                 count:distModel.offlineCount
                                                                 color:@"#c6cacb"]];
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"客服状态分布"
                                                                                  type:KFMonitorInfoViewItem_ChartType
                                                                                 infos:infos];
         item.index = 0;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 客服负载情况
- (void)updateAgentLoad{
    [HDClient.sharedClient.monitorManager asyncFetchAgentLoadWithCompletion:^(HDAgentLoadCountModel *model, HDError *error)
     {
         if (error) {
             return ;
         }
         
         KFMonitorInstrumentModel *insModel = [[KFMonitorInstrumentModel alloc] initWithCurrentCount:model.processingCount
                                                                                            maxCount:model.totalCount];
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"客服负载情况"
                                                                                  type:KFMonitorInfoViewItem_InstrumentType
                                                                                 infos:@[insModel]];
         item.index = 1;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 访客排队情况
- (void)updatehWaitCount {
    [HDClient.sharedClient.monitorManager asyncFetchWaitCountWithCompletion:^(HDVisitorWaitCountModel *model, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSString *color = @"#9ef14d";
         NSMutableArray *infos = [NSMutableArray array];
         for (int i = 0; i < model.timestampAry.count; i++) {
             NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[model.timestampAry[i] longLongValue] / 1000];
             KFMonitorItemInfo *info = [[KFMonitorItemInfo alloc] initWithTitleName: [date monthDescription]
                                                                              count: [model.countAry[i] integerValue]
                                                                              color:color];
             [infos addObject:info];
         }
         
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"访客排队情况"
                                                                                  type:KFMonitorInfoViewItem_ChartType
                                                                                 infos:infos
                                                                          showInfoType:TitleType];
         
         item.index = 2;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 会话数
- (void)updateSessionTotalCount {
    [HDClient.sharedClient.monitorManager asyncFetchSessionTotalWithCompletion:^(HDAgentSessionCountModel *model, HDError *error)
     {
         
         if (error) {
             return ;
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_AgentType defineSelected:KFMonitorLabelModel_AgentType];
         NSMutableArray *ary = [NSMutableArray array];
         [ary addObject:@{@"新进会话数":@(model.newSessionCount)}];
         [ary addObject:@{@"进行中有效会话数":@(model.effectiveSessionCount)}];
         [ary addObject:@{@"进行中无效会话数":@(model.invalidSessionCount)}];
         [ary addObject:@{@"结束会话数":@(model.endSessionCount)}];
         
         labelModel.agents = ary;
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"会话数"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.suffixStr = @"条";
         item.index = 3;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 访客来源
- (void)updateVisterTotalCount {
    [HDClient.sharedClient.monitorManager asyncFetchVistorTotalWithCompletion:^(HDVisterSourceModel *model, HDError *error)
     {
         if (error) {
             return ;
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_AgentType defineSelected:KFMonitorLabelModel_AgentType];
         NSMutableArray *ary = [NSMutableArray array];
         [ary addObject:@{@"网页":@(model.webCount)}];
         [ary addObject:@{@"微信":@(model.weiXinCount)}];
         [ary addObject:@{@"微博":@(model.weiBoCount)}];
         [ary addObject:@{@"手机APP":@(model.phoneCount)}];
         
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"访客来源"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.suffixStr = @"个";
         item.index = 4;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 服务质量
- (void)updateQualityTotalCount {
    [HDClient.sharedClient.monitorManager asyncFetchQualityTotalWithCompletion:^(HDAgentQualityModel *model, HDError *error)
     {
         if (error) {
             return ;
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_AgentType defineSelected:KFMonitorLabelModel_AgentType];
         NSMutableArray *ary = [NSMutableArray array];
         
         [ary addObject:@{@"首次响应时长平均值":@(model.firstTime)}];
         [ary addObject:@{@"响应时长平均值":@(model.averageTime)}];
         [ary addObject:@{@"满意度":[NSNumber numberWithFloat:model.satisfaction]}];
         
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"服务质量"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.suffixStr = @"秒";
         item.index = 5;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 接起会话数
- (void)updateConversationsWithType:(HDObjectType)type {
    [HDClient.sharedClient.monitorManager
     asyncFetchServedConversationStartWithObjectType:type
     isTop:YES
     completion:^(NSArray *servedConversationModels, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSMutableArray *ary = [NSMutableArray array];
         for (HDAgentServedConversationModel *tmpModel in servedConversationModels) {
             [ary addObject:@{tmpModel.agentName:@(tmpModel.servedCount)}];
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_TeamsType
                                                                      defineSelected:(KFMonitorLabelModelType)type];
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"接起会话数"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.index = 6;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 平均首次响应时长
- (void)updateRespnonseWithType:(HDObjectType)type {
    [HDClient.sharedClient.monitorManager
     asyncFetchListFirstResponseWithObjectType:type
     isTop:YES
     completion:^(NSArray *averageFirstResponseTimeModels, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSMutableArray *ary = [NSMutableArray array];
         for (HDAverageFirstResponseTimeModel *tmpModel in averageFirstResponseTimeModels) {
             [ary addObject:@{tmpModel.agentName:@(tmpModel.seconds)}];
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_TeamsType
                                                                      defineSelected:(KFMonitorLabelModelType)type];
         
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"平均首次响应时长"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.suffixStr = @"秒";
         item.index = 7;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
         
     }];
}

// 满意度
- (void)updateVistorWithType:(HDObjectType)type {
    [HDClient.sharedClient.monitorManager
     asyncFetchListVistorMarkWithObjectType:type
     isTop:YES
     completion:^(NSArray *agnetSatisfactionEvaluationModels, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSMutableArray *ary = [NSMutableArray array];
         for (HDAgnetSatisfactionEvaluationModel *tmpModel in agnetSatisfactionEvaluationModels) {
             [ary addObject:@{tmpModel.agentName:[NSNumber numberWithFloat:tmpModel.averageScore]}];
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_TeamsType
                                                                      defineSelected:(KFMonitorLabelModelType)type];
         
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"满意度"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.index = 8;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}

// 平均响应时长
- (void)updateListResponseWithType:(HDObjectType)type {
    [HDClient.sharedClient.monitorManager
     asyncFetchListResponseWithObjectType:type
     isTop:YES
     completion:^(NSArray *agentMeanResponseTimeModels, HDError *error)
     {
         if (error) {
             return ;
         }
         
         NSMutableArray *ary = [NSMutableArray array];
         for (HDAgentMeanResponseTimeModel *tmpModel in agentMeanResponseTimeModels) {
             [ary addObject:@{tmpModel.agentName:[NSNumber numberWithInteger:tmpModel.seconds]}];
         }
         
         KFMonitorLabelModel *labelModel = [[KFMonitorLabelModel alloc] initWithType:KFMonitorLabelModel_TeamsType
                                                                      defineSelected:(KFMonitorLabelModelType)type];
         
         if (labelModel.selectedType == KFMonitorLabelModel_AgentType) {
             labelModel.agents = ary;
         }else {
             labelModel.teams = ary;
         }
         KFMonitorInfoViewItem *item = [KFMonitorInfoViewItem monitorInfoModelWithName:@"平均响应时长"
                                                                                  type:KFMonitorInfoViewItem_LabelType
                                                                                 infos:@[labelModel]
                                                                          showInfoType:TitleType];
         item.suffixStr = @"秒";
         item.index = 9;
         dispatch_async(dispatch_get_main_queue(), ^{
             self.items[item.index] = item;
             self.monitorView.items = self.items;
         });
     }];
}


- (void)backAction {
    [[HomeViewController HomeViewController] showLeftView];
}

- (void)setupBaseUI {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.view.backgroundColor = kTableViewBgColor;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (KFMonitorInfoView *)monitorView {
    if (!_monitorView) {
        _monitorView = [[KFMonitorInfoView alloc] initWithFrame:CGRectZero items:self.items];
        [_monitorView setBackgroundColor:UIColor.whiteColor];
        _monitorView.delegate = self;
    }
    
    return _monitorView;
}

- (NSMutableArray *)items {
    if(!_items) {
        _items = [self monitorItems].mutableCopy;
    }
    return _items;
}

- (NSArray *)monitorItems {
    NSMutableArray *ary = [NSMutableArray array];
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"客服状态分布"
                                                              type:KFMonitorInfoViewItem_ChartType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"客服负载情况"
                                                              type:KFMonitorInfoViewItem_InstrumentType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"访客排队情况"
                                                              type:KFMonitorInfoViewItem_ChartType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"会话数"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"访客来源"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"服务质量"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"接起会话数"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"平均首次响应时长"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"满意度"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    
    [ary addObject:[KFMonitorInfoViewItem monitorInfoModelWithName:@"平均响应时长"
                                                              type:KFMonitorInfoViewItem_LabelType
                                                             infos:nil]];
    return ary;
}
@end
