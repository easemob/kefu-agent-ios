//
//  HSearchResultsViewController.m
//  EMCSApp
//
//  Created by afanda on 8/16/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "HSearchResultsViewController.h"
#import "DXTableViewCellTypeConversation.h"
@interface HSearchResultsViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation HSearchResultsViewController

- (UITableView *)resultsTableView {
    if (!_resultsTableView) {
        _resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _resultsTableView.delegate = self;
        _resultsTableView.dataSource = self;
        _resultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _resultsTableView.tableFooterView = [UIView new];
    }
    return _resultsTableView;
}

- (NSMutableArray *)resultsSource {
    if (_resultsSource == nil) {
        _resultsSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultsSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kTableViewBgColor;
    [self.view addSubview:self.resultsTableView];
//    self.view.backgroundColor = [UIColor redColor];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultsSource.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DXTableViewCellTypeConversation *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTypeConversation"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[DXTableViewCellTypeConversation alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversation"];
        cell.rightUtilityButtons = nil;
    }
    
    if ([self.resultsSource count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellTypeConversationCustom"];
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.text = @"没有会话";
        cell.textLabel.textColor = UIColor.grayColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    HDConversation *model =  [self.resultsSource objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[HDConversation class]]) {
        [cell setModel:model];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
