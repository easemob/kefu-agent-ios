//
//  KFPromptView.h
//  EMCSApp
//
//  Created by afanda on 16/11/1.
//  Copyright © 2016年 easemob. All rights reserved.
//

//提示窗口
#import <UIKit/UIKit.h>

@interface KFPromptView : UIView
+ (instancetype)shareKFPromptView;
-(void)showTipWithTitle:(NSString *)title;

@end
