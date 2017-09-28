//
//  JNGroupViewController.h
//  EMCSApp
//  技能组
//
//  Created by EaseMob on 15/12/29.
//  Copyright © 2015年 easemob. All rights reserved.
//

#import "DXTableViewController.h"

@protocol JNGroupViewDelegate <NSObject>

- (void)popToRoot;

@end

@interface JNGroupViewController : DXTableViewController

@property (nonatomic,strong) NSString* serviceSessionId;

@property (nonatomic,weak) id<JNGroupViewDelegate> delegate;

@end
