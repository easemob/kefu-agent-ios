//
//  KFMonitorDetailViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFMonitorDetailViewController.h"
#import "KFArrowButtonView.h"
#import "KFDetailModel.h"
#import "KFMonitorDetailCell.h"

@interface KFMonitorDetailViewController () 

@end

@implementation KFMonitorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"现场管理-%@",_groupName];
    [self loadData];
}

- (void)loadData {
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    NSString *path = [NSString stringWithFormat:kMonitorDetail,_queueId];
    [self showHintNotHide:@""];
    [[KFHttpManager sharedInstance] asyncGetMonitorDetailWithPath:path completion:^(id responseObject, NSError *error) {
        [self hideHud];
        if (error == nil) {
            for (NSDictionary *dic in responseObject) {
                KFDetailModel *detail = [KFDetailModel yy_modelWithJSON:dic];
                [self.dataSource addObject:detail];
            }
            self.dataSource = [self sortArray:self.dataSource.copy isSort:NO].mutableCopy;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KFMonitorDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monitor"];
    if (cell == nil) {
        cell = [[KFMonitorDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monitor"];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.head;
}

- (NSArray *)sortArray:(NSArray *)array isSort:(BOOL)isSort {
    NSArray *arr =[array sortedArrayUsingComparator:^NSComparisonResult(KFDetailModel *obj1,KFDetailModel *obj2) {
        if (isSort) {
            return obj1.kfState < obj2.kfState;
        } else {
            return obj1.kfState > obj2.kfState;
        }
    }];
    return arr;
}

//UI
- (KFArrowButtonView *)head {
    if (_head == nil) {
        _head = [[KFArrowButtonView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _head.delegate = self;
        _head.normalText = @"客服状态排序";
        _head.selectedText = @"客服状态排序";
    }
    return _head;
}


- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
