//
//  KFVECHistoryDetailViewController.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/26.
//  Copyright © 2023 环信. All rights reserved.
//

#import "KFVECHistoryDetailViewController.h"
#import "CompileTableViewCell.h"
#import "KFVecHistoryDetailModel.h"
#import "KFVECVideoDetailViewController.h"
#import "Masonry.h"

@interface KFVECHistoryDetailViewController (){
    

}
@property (nonatomic, strong) UILabel *nicknameLabel;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) KFVecHistoryDetailModel * detailModel ;
@property (nonatomic, strong) HDVECVideoDetailModel * currentRecordModel ;


@end


@implementation KFVECHistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频详情";
    
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    self.tableView.backgroundColor = kTableViewHeaderAndFooterColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self loadData];
}




- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc ]init];
    }
    
    return  _dataArray;
}

- (UIView *)line
{
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.frame = CGRectMake(0, 0, KScreenWidth, 1.0);
        _line.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
        _line.top = 50 - _line.height;
    }
    return _line;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CompileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
        // Configure the cell...
        if (cell == nil) {
            cell = [[CompileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
            cell.backgroundColor = UIColor.whiteColor;
            cell.textLabel.textColor = UIColor.grayColor;
            CGRect frame  = cell.nickName.frame;
            
            frame.origin.x = CGRectGetMaxX(cell.title.frame);
            
            cell.nickName.frame = frame;
            
        }
        switch (indexPath.row) {
            case 0:
            {
                cell.title.text = @"渠道";
                cell.nickName.text = self.callModel.originType;
            }
                break;
            case 1:
            {
                cell.title.text = @"类型";
//                cell.nickName.text = self.callModel;
                
                if (self.callModel.callType == 0 ) {
                    cell.nickName.text = @"呼入";
                }else if(self.callModel.callType == 1 ){
                    
                    cell.nickName.text = @"呼出";
                }
                
                
            }
                break;
            case 2:
            {
                
                cell.title.text = @"技能组";
                
                NSDictionary * dic =  [self.callModel.queueSet firstObject];
                if ([[dic allKeys] containsObject:@"queueName"]) {
                    cell.nickName.text = [dic valueForKey:@"queueName"] ;
                }
            
            }
                break;
            case 3:
            {
                cell.title.text = @"发起时间";
                cell.nickName.text = self.callModel.createDatetime;
                
            }
                break;
            case 4:
            {
                cell.title.text = @"结束时间";
                cell.nickName.text = self.callModel.stopDatetime;
                
                
            }
                break;
            case 5:
            {
                cell.title.text = @"挂断方";
                
                if ([self.callModel.hangUpUserType isEqualToString:@"Visitor"] ) {
                    cell.nickName.text = @"访客";
                }else if([self.callModel.hangUpUserType isEqualToString:@"Agent"]){
                    cell.nickName.text = @"坐席";
                }
            }
                break;
            case 6:
            {
                cell.title.text = @"满意度";
                cell.nickName.text = self.callModel.enquiryDes;
                
            }
                break;
            case 7:
            {
                cell.title.text = @"视频文件";
                
                if (self.detailModel.recordDetails &&[self.detailModel.recordDetails isKindOfClass:[NSArray class]] ) {
                    
                    NSDictionary * dic = [self.detailModel.recordDetails firstObject];
                    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                        HDVECVideoDetailModel * model  = [HDVECVideoDetailModel yy_modelWithDictionary:dic];
                        if (model ) {
                        
                            if (model.playbackUrl&& [model.playbackUrl isKindOfClass:[NSString class]]) {
                                
                                if (model.playbackUrl.length > 0) {
                                    self.currentRecordModel = model;
                                    cell.nickName.text = @"查看";
                                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorBlueHX];
                                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                }
                            }
                        }
                    }
                }
            }
                break;
            case 8:
            {
                cell.title.text = @"插件";
                cell.nickName.text = self.callModel.techChannelName;
                
            }
                break;
            case 9:
            {
                cell.title.text = @"客服";
                NSDictionary * dic =  [self.callModel.agentUserSet firstObject];
                if ([[dic allKeys] containsObject:@"nicename"]) {
                    cell.nickName.text = [dic valueForKey:@"nicename"] ;
                }
                
            }
                break;
            case 10:
            {
                cell.title.text = @"接通时间";
                cell.nickName.text = self.callModel.videoStartDatetime;
                
            }
                break;
            case 11:
            {
                cell.title.text = @"视频时长";
        
                cell.nickName.text = [self timeFormatted:[self.callModel.videoDuration intValue]];
                
            }
                break;
            case 12:
            {
                cell.title.text = @"挂断原因";
                
                if ([self.callModel.hangUpReason isEqualToString:@"NORMAL"]) {
                    
                    cell.nickName.text = @"正常结束";
                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorBlueHX];
                    
                }else if([self.callModel.hangUpReason isEqualToString:@"RING_GIVE_UP"]){
                    
                    cell.nickName.text = @"振铃放弃";
                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorRed];
                    
                }else if([self.callModel.hangUpReason isEqualToString:@"AGENT_REJECT"]){
                    
                    cell.nickName.text = @"客服拒接";
                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorRed];
                    
                }else if([self.callModel.hangUpReason isEqualToString:@"VISITOR_REJECT"]){
                    
                    cell.nickName.text = @"访客拒接";
                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorRed];
                    
                }else if([self.callModel.hangUpReason isEqualToString:@"CALLBACK_CANCEL"]){
                    
                    cell.nickName.text = @"振铃放弃";
                    cell.nickName.textColor = [[HDAppSkin mainSkin] contentColorRed];
                    
                }
                
                
            }
                break;
            default:
                break;
        }
        return cell;
    }
    
   
    return nil;
}

- (NSString *)timeFormatted:(int)totalSeconds
{

    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = kTableViewHeaderAndFooterColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            return;
        }

        KFVECVideoDetailViewController * vc = [[KFVECVideoDetailViewController alloc] init];
        vc.currentModel = self.currentRecordModel;
        [self.navigationController pushViewController:vc animated:YES];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark private




- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.dataArray.count > 0) {
        
    }
}



- (void)loadData
{
    WEAK_SELF
    [[HDClient sharedClient].vecCallManager vec_getCallVideoDetailWithRtcSessionId:self.callModel.rtcSessionId Completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        if (error == nil) {
            if (responseObject&& [responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dic = responseObject;
            
                if ([[dic allKeys] containsObject:@"entities"]) {
                    
                    NSArray * array =  [dic objectForKey:@"entities"];
                    
                    NSDictionary * entities = [array firstObject];
                    
                   weakSelf.detailModel  = [KFVecHistoryDetailModel yy_modelWithDictionary:entities];
                    
                    if (weakSelf.detailModel) {
                        
                        hd_dispatch_main_async_safe(^(){
                            [weakSelf.tableView reloadData];
                        });
                    }
                }
            }
        }
    }];
}


@end

