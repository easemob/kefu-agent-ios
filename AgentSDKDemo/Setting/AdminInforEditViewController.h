//
//  AdminInforEditViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/1/21.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AdminInforEditViewControllerDelegate <NSObject>

- (void)saveParameter:(NSString *)value key:(NSString *)key;

@end

@interface AdminInforEditViewController : EMBaseViewController

@property (nonatomic, copy) NSString *editContent;

@property (weak, nonatomic) id<AdminInforEditViewControllerDelegate> delegate;

- (instancetype)initWithType:(int)type;

@end
