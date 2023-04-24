//
//  EMPickerView.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMPickerSaveDelegate <NSObject>

- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index;

- (void)saveVECPickerWithValue:(NSString *)value index:(NSInteger)index;

- (void)saveCECPickerWithValue:(NSString *)value index:(NSInteger)index;

@end


typedef NS_ENUM(NSInteger, HDEMPickerViewType) {
    HDEMPickerViewTypeCEC, //  CEC
    HDEMPickerViewTypeVEC, //  VEC
};

@interface EMPickerView : UIView

@property (nonatomic, weak) id<EMPickerSaveDelegate> delegate;

@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, assign) HDEMPickerViewType pickerViewType;

- (instancetype)initWithDataSource:(NSArray*)dataSource;

- (instancetype)initWithDataSource:(NSArray*)dataSource topHeight:(CGFloat)height;

- (void)setDataSource:(NSArray*)dataSource;

@end
