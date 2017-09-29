//
//  EMPromptBoxView.h
//  EMCSApp
//
//  Created by EaseMob on 16/6/15.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMPromptBoxViewDelegate <NSObject>

- (void)didSelectPromptBoxViewWithPhrase:(NSString*)phrase;

@end

@interface EMPromptBoxView : UIView

@property (nonatomic, weak) id<EMPromptBoxViewDelegate> delegate;

- (void)searchText:(NSString *)searchText;

@end
