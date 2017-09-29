//
//  KFLeftViewController.h
//  EMCSApp
//
//  Created by afanda on 5/15/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LeftMenuViewDelegate <NSObject>
@optional
- (void)menuClickWithIndex:(NSInteger)index;

- (void)adminMenuClickWithIndex:(NSInteger)index;

- (void)onlineStatusClick:(UIView*)view;
@end

@interface KFLeftViewController : UIViewController
@property (nonatomic, weak) id<LeftMenuViewDelegate> leftDelegate;

- (void)refreshUnreadView:(NSInteger)badgeNumber;

- (void)switchAdminView;
@end
