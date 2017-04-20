//
//  UIAlertView+AlertBlock.h
//  EMCSApp
//
//  Created by EaseMob on 15/5/7.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock) (NSInteger buttonIndex);

@interface UIAlertView (AlertBlock)

- (void)showAlertViewWithCompleteBlock:(CompleteBlock)block;

@end
