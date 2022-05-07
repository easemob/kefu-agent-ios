//
//  KFSwitchTypeButton.h
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/3/21.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFSwitchTypeButton : UIControl
@property (nonatomic, assign) BOOL isAdminType;
- (instancetype)initWithNomalImage:(UIImage *)aNomalImage
                         nomalText:(NSString *)aNomalText
                     selectedImage:(UIImage *)aSelectImage
                      selectedText:(NSString *)aSelectText;

- (void)showUnreadTip:(BOOL)isShow;

@end
