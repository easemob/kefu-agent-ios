//
//  QuickReplySubViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/16.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "DXTableViewController.h"

@protocol QuickReplySubViewDelegate <NSObject>

- (void)clickQuickReplyMessage:(NSString*)message;

@end


@protocol QuickReplySelfSubViewDelegate <NSObject>

- (void)clickQuickReplyMessage:(NSString*)message;

@end

@class QuickReplyMessageModel;
@interface QuickReplySubViewController : DXTableViewController

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) QuickReplyMessageModel *quickReplyModel;

@property (weak, nonatomic) id<QuickReplySubViewDelegate> delegate;

@property (weak, nonatomic) id<QuickReplySelfSubViewDelegate> selfDelegate;

@end
