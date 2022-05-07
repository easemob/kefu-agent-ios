//
//  NotiDetailViewController.h
//  EMCSApp
//
//  Created by afanda on 3/28/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EMNotifyModel.h"

@interface VisitorModel : NSObject
@property (nonatomic, copy) NSString *createDateTime;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *nicename;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *techChannelType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *username;
@end

@interface NotiDetailViewController : UIViewController

@property (nonatomic, strong) HDNotifyModel *model;
@end
