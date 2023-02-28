//
//  HLeaveMessageComment.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/25.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLeaveMessage.h"

@class HLeaveMessageCommentAttachment;
@interface HLeaveMessageComment : NSObject
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) HLeaveMessageCreator *creator;
@property (nonatomic, strong) NSString *createDate;
@property (nonatomic, strong) NSArray *attachments;
@end

@interface HLeaveMessageCommentAttachment : NSObject
@property (nonatomic, strong) NSString * attachmentName;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * url;

@end
