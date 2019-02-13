//
//  KFBaseViewController.m
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFBaseViewController.h"
#import "KFTestParameters.h"

@interface KFBaseViewController () <UITableViewDelegate>
//@property (nonatomic, assign) CGFloat space;
@end

@implementation KFBaseViewController

- (KFUserModel *)userModel {
    if (!_userModel) {
        _userModel = [[KFUserModel alloc] init];
    }
    return _userModel;
}

- (BOOL)testRegisterParametersWithDic:(NSDictionary *)dic {
    KFTestParameters *test = [KFTestParameters new];
    NSString *errorMsg = [test testParametersWithDictionary:dic];
    if (errorMsg) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
- (UITableView *)tableView {
    if (!_tableView) {
        Class  cls =NSClassFromString(@"KFLeaveMsgDetailViewController");
        UITableViewStyle style=UITableViewStylePlain;
        if (cls == [self class]) {
            style = UITableViewStyleGrouped;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight+20) style:style];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.view addSubview:self.tableView];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setNav {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"shai_icon_backCopy"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    NSLog(@"dealloc -- %s",__func__);
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
