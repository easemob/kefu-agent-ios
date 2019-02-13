//
//  EMEditViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/9.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMEditViewControllerDelegate <NSObject>

- (void)saveParameter:(NSString *)value key:(NSString *)key;

@end

@interface EMEditViewController : EMBaseViewController

@property (weak, nonatomic) id<EMEditViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *key;

@end
