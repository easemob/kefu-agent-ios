

#import <UIKit/UIKit.h>

@protocol HTimePickerViewDelegate <NSObject>
@optional
/**
 * 确定按钮
 */
-(void)didClickFinishDateTimePickerView:(NSString *)date;
/**
 * 取消按钮
 */
-(void)didClickCancelDateTimePickerView;

@end


@interface HTimePickerView : UIView

@property (nonatomic, strong) NSDateFormatter *formatter;
/**
 * 设置当前时间
 */
@property(nonatomic, strong)NSDate *currentDate;
/**
 * 设置中心标题文字
 */
@property(nonatomic, strong)UILabel *titleL;

@property(nonatomic, strong)id<HTimePickerViewDelegate>delegate;

/**
 * 隐藏
 */
- (void)hideDateTimePickerView;

/**
 * 显示
 */
- (void)showDateTimePickerView;

@end
