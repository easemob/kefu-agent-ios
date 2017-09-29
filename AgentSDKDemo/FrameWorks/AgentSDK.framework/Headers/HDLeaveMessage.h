//
//  HDLeaveMessage.h
//  AgentSDK
//
//  Created by afanda on 8/14/17.
//  Copyright © 2017 环信. All rights reserved.
//
/**
 一条留言
 */
@class HDAssignee;
@class HDCreator;
@class HDStatus;
@class HDAttachment;

#import <Foundation/Foundation.h>

@interface HDBase : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface HDLeaveMessage : HDBase
@property(nonatomic,strong) HDAssignee *assignee;   //被分配人
@property(nonatomic,strong) NSMutableArray<HDAttachment *> *attachments;    //附件
@property(nonatomic,copy) NSString *content;                //会话内容
@property(nonatomic,copy) NSString *created_at;             //留言创建时间
@property(nonatomic,strong) HDCreator *creator;     //留言者
@property(nonatomic,copy) NSString *ID;      //留言id
@property(nonatomic,strong) HDStatus *status;       //留言状态
@property(nonatomic,copy) NSString *subject;                //留言主题
@property(nonatomic,copy) NSString *updated_at;             //留言更新时间
@property(nonatomic,strong) NSNumber *version;              //留言index
//ext
@property(nonatomic,assign) CGFloat commentHeight;          //留言评论的高度

@end

//被分配者
@interface HDAssignee : HDBase

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property(nonatomic,copy) NSString *phone;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *username;


@end
//发起者
@interface HDCreator : HDBase
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *qq;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *username;


@end

//状态
@interface HDStatus : HDBase
@property(nonatomic,strong) NSString *code;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;


@end

//附件
@interface HDAttachment : HDBase
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *type;


@end
