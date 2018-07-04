//
//  KFWarningViewController.m
//  AgentSDKDemo
//
//  Created by afanda on 12/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFWarningViewController.h"
#import "KFWarningCell.h"

@interface KFWarningViewController ()

@end

@implementation KFWarningViewController
{
    NSMutableArray *_models;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [KFManager sharedInstance].curViewController = self;
    [KFManager sharedInstance].needShowSuperviseTip = NO;
    [kNotiCenter postNotificationName:KFSuperviseNoti object:@(YES)];
    self.title = @"告警记录";
    [self loadData];
}

- (void)loadData {
    _models = [NSMutableArray arrayWithCapacity:0];
    [self.dataSource removeAllObjects];
    [self showHintNotHide:@""];
    [[KFHttpManager sharedInstance] asyncGetWarningsWithPath:kGetWarnings pageIndex:0 pageSize:100 completion:^(id responseObject, NSError *error) {
        [self hideHud];
        if (error == nil) {
            for (NSDictionary *dic in responseObject) {
                KFWarningModel *model = [KFWarningModel yy_modelWithJSON:dic];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *war = @"warning";
    KFWarningCell *cell = [tableView dequeueReusableCellWithIdentifier:war];
    if (cell == nil) {
        cell = [[KFWarningCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:war];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)backAction {
    [super backAction];
     [KFManager sharedInstance].curViewController = nil;
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
