//
//  TransferViewController.h
//  EMCSApp
//
//  Created by EaseMob on 15/9/9.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXBaseViewController.h"


@protocol TransferViewControllerDelegate <NSObject>

- (void)conversationHasTransfered;

@end

@interface TransferViewController : DXBaseViewController

@property(nonatomic,assign) id<TransferViewControllerDelegate> delegate;

@property (nonatomic,strong) HDConversationManager* conversation;

@end
