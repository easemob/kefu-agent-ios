//
//  KFIframeMoreViewController.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/3/2.
//  Copyright © 2023 环信. All rights reserved.
//

#import "KFIframeMoreViewController.h"
#import "KFWKWebViewController.h"

@interface KFIframeMoreViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation KFIframeMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifer = @"KFIframeMoreViewController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;//设置cell点击效果
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    KFIframeModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = model.iframeTabTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KFIframeModel *model = [self.dataArray objectAtIndex:indexPath.row];
    KFWKWebViewController *webView = [[KFWKWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"https:%@",model.iframeUrl]];
    webView.delegate = self;
    webView.iframeModel = model;
    webView.conversation = self.conversation;
    [self.navigationController pushViewController:webView animated:YES];
    
}

@end
