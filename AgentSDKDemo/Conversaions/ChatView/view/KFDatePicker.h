//
//  KFDatePicker.h
//  EMCSApp
//
//  Created by __阿彤木_ on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFDatePickerDelegate <NSObject>

- (void)dateClicked:(UIDatePicker *)datePicker;

@end


@interface KFDatePicker : UIView

@property(nonatomic,assign) id<KFDatePickerDelegate> delegate;

@end
