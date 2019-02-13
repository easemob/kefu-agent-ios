//
//  KFArrowButtonView.h
//  AgentSDKDemo
//
//  Created by afanda on 12/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFArrowButtonViewDelegate <NSObject>

- (void)arrowButtonClicked:(UIButton *)btn;

@end

@interface KFArrowButtonView : UIView
@property (nonatomic, copy) NSString *normalText;
@property (nonatomic, copy) NSString *selectedText;

@property (nonatomic, assign) id <KFArrowButtonViewDelegate>delegate;
@end
