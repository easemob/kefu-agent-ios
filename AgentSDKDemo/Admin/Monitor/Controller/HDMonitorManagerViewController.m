//
//  HDMonitorManagerViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 12/4/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDMonitorManagerViewController.h"
#import "HomeViewController.h"
#import "HDGroupModel.h"
#import "KFArrowButtonView.h"
#import "KFMonitorDetailViewController.h"

@interface HDMonitorManagerViewController ()

@end

@implementation HDMonitorManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"现场管理";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    [self.timer fire];
}


- (void)loadData {
    [self showHintNotHide:@""];
    [[KFHttpManager sharedInstance] asyncGetAgentQueuesWithPath:kGetAgentGroup completion:^(id responseObject, NSError *error) {
        [self hideHud];
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
        if (error == nil) {
            for (NSDictionary *dic in responseObject) {
                HDGroupModel *group = [HDGroupModel yy_modelWithJSON:dic];
                [self.dataSource addObject:group];
            }
            self.dataSource = [self sortArray:self.dataSource.copy isSort:NO].mutableCopy;
        }
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDMonitorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monitor"];
    if (cell == nil) {
        cell = [[HDMonitorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"monitor"];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"didSelectRowAtIndexPath");
    HDGroupModel *model = [self.dataSource objectAtIndex:indexPath.row];
    KFMonitorDetailViewController *detailVC = [[KFMonitorDetailViewController alloc] init];
    detailVC.queueId = model.queue_id;
    detailVC.groupName = model.queue_name;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.head;
}

- (void)dealloc {
    NSLog(@"dealloc func:%s",__func__);
}

- (NSArray *)sortArray:(NSArray *)array isSort:(BOOL)isSort {
    NSArray *arr =[array sortedArrayUsingComparator:^NSComparisonResult(HDGroupModel *obj1,HDGroupModel *obj2) {
        if (isSort) {
            return obj1.session_wait_count > obj2.session_wait_count;
        } else {
            return obj1.session_wait_count < obj2.session_wait_count;
        }
        
    }];
    return arr;
}

- (KFArrowButtonView *)head {
    if (_head == nil) {
        _head = [[KFArrowButtonView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _head.delegate = self;
        _head.normalText = @"排队人数由高到低";
        _head.selectedText = @"排队人数由低到高";
    }
    return _head;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
