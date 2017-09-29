//
//  KFBaseViewController.h
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFUserModel.h"

@interface KFBaseViewController : UIViewController
- (BOOL)testRegisterParametersWithDic:(NSDictionary *)dic;
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) KFUserModel *userModel;
@end
