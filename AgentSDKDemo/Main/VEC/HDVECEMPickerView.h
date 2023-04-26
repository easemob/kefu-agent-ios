//
//  HDVECEMPickerView.h
//  AgentSDKDemo
//
//  Created by easemob on 2023/4/24.
//  Copyright © 2023 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, HDEMPickerViewType) {
    HDEMPickerViewTypeCEC, //  CEC
    HDEMPickerViewTypeVEC, //  VEC
};
@interface EMPickerModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) HDEMPickerViewType pickerViewType;

@end
@protocol VECEMPickerSaveDelegate <NSObject>

- (void)savePickerWithValue:(NSString *)value index:(NSInteger)index;

- (void)saveVECPickerWithValue:(NSString *)value index:(NSInteger)index;

- (void)saveCECPickerWithValue:(NSString *)value index:(NSInteger)index;

@end

@interface HDVECEMPickerView : UIView
@property (nonatomic, weak) id<VECEMPickerSaveDelegate> delegate;

@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIPickerView *pickView;


- (instancetype)initWithDataSource:(NSArray<EMPickerModel *>*)dataSource;

- (instancetype)initWithDataSource:(NSArray<EMPickerModel *>*)dataSource topHeight:(CGFloat)height;

- (void)setDataSource:(NSArray<EMPickerModel *>*)dataSource;
@end

NS_ASSUME_NONNULL_END
