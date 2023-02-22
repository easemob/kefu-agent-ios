//
//  HDVECSessionHistoryViewController.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import "HDVECSessionHistoryViewController.h"
#import "HDVECSessionHistoryCell.h"
#import "HDVECAgoraCallManager.h"
#import "HDVECSessionHistoryModel.h"

#import "HDVECSessionHistoryDetailViewController.h"
@interface HDVECSessionHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation HDVECSessionHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.headView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.size.width, self.view.size.height-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(HDVECSessionHistoryCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(HDVECSessionHistoryCell.class)];
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 44;
//    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    //初始化数据
    [self initData];
    
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
  
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    
    self.navigationController.navigationBarHidden = NO;
    
    
}
- (void)initData{

    //调用 视频记录接口
    // 获取视频记录
    NSDictionary *dicHistory = [[HDVECAgoraCallManager shareInstance] vec_getSessionhistoryParameteData];
    [[HDVECAgoraCallManager shareInstance] vec_getRtcSessionhistoryParameteData:dicHistory completion:^(id  _Nonnull responseObject, HDError * _Nonnull error) {

        if (error == nil) {
            
            if (responseObject&& [responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dic = responseObject;
                [self.dataArray removeAllObjects];
                if ([[dic allKeys] containsObject:@"entities"]) {
                   
                   NSArray * array = [NSArray yy_modelArrayWithClass:[HDVECSessionHistoryModel class] json:[dic objectForKey:@"entities"] ];
                    
                    [self.dataArray  addObjectsFromArray:array];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       // UI更新代码
                        [self.tableView reloadData];
                    
                    });
                    
                   
                    
                }
                
            }
            
            
        }
        NSLog(@"=======%@",responseObject);
        
    }];
}
#pragma mark - event
//- (void)dismissViewController{
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//}




#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  66;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HDVECSessionHistoryCell";
    HDVECSessionHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setModel:[self.dataArray objectAtIndex:indexPath.row]];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HDVECSessionHistoryModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    HDVECSessionHistoryDetailViewController * vc = [[HDVECSessionHistoryDetailViewController alloc] init];
    vc.rtcSessionId = model.rtcSessionId;
    vc.window=self.window;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}
#pragma mark - UITableViewDelegate



#pragma mark - lazy
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

-(UIView *)headView{
    
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _headView.backgroundColor = [UIColor grayColor];
        
        UILabel * label = [[UILabel alloc] init];
        label.text = @"视频记录";
        label.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.offset(24);
            make.leading.offset(32);
            make.trailing.offset(0);
            make.bottom.offset(0);
        }];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [closeBtn.titleLabel setTextColor:[UIColor redColor]];
        [_headView addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(24);
            make.leading.offset(20);
            make.width.height.offset(32);
            
        }];
        [closeBtn addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    return _headView;
}
-(void)doClose:(UIButton *)sender{
    
    [self.view removeAllSubviews];
    self.view = nil;
    self.navigationController.navigationBarHidden = NO;
    
    [self.window removeAllSubviews];
    self.window= nil;
    if (self.vectestHangUpCallback) {
        
        self.vectestHangUpCallback();
    }
}
@end
