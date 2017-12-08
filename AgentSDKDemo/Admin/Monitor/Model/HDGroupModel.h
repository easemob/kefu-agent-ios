//
//  HDGroupModel.h
//  AgentSDKDemo
//
//  Created by afanda on 12/5/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDGroupModel : NSObject

@property(nonatomic,assign) NSString *queue_id;

@property(nonatomic,copy) NSString *queue_name;

@property(nonatomic,assign) NSInteger busy_count;

@property(nonatomic,assign) NSInteger current_session_count;

@property(nonatomic,assign) NSInteger hidden_count;

@property(nonatomic,assign) NSInteger idle_count;

@property(nonatomic,assign) NSInteger leave_count;

@property(nonatomic,assign) NSInteger max_session_count;

@property(nonatomic,assign) NSInteger offline_count;

@property(nonatomic,assign) NSInteger session_wait_count;

@end
