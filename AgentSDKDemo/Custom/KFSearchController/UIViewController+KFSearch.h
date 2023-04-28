//
//  UIViewController+KFSearch.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2020/6/2.
//  Copyright © 2020 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFSearchController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (KFSearch)
@property (nonatomic, strong) UIButton *searchButton;

@property (nonatomic, strong) KFSearchController *resultController;

@property (nonatomic, strong) UINavigationController *resultNavigationController;

- (void)enableSearchController;

- (void)disableSearchController;

- (void)cancelSearch:(nullable void(^)())aCompletion;


@end

NS_ASSUME_NONNULL_END
