//
//  LeaveMsgInputView.h
//  EMCSApp
//
//  Created by EaseMob on 16/9/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeaveMsgInputViewDelegate <NSObject>

- (void)didChangeFrameToHeight:(CGFloat)toHeight;

- (void)didSendText:(NSString *)text attachments:(NSArray*)attachments;

- (void)didSelectImageWithPicker:(UIImagePickerController*)imagePicker;

@end

@interface LeaveMsgInputView : UIView

@property (nonatomic, weak) id<LeaveMsgInputViewDelegate> delegate;

- (void)resetAttachmentButton;

@end
