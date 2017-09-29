//
//  KFLeaveMsgModel.h
//  EMCSApp
//
//  Created by afanda_ on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFLeaveMsgAssignee;
@class KFLeaveMsgCreator;
@class KFLeaveMsgStatus;
@class KFLeaveMsgAttachmentModel;

//一条留言
@interface KFLeaveMsgModel : NSObject
@property(nonatomic,strong) KFLeaveMsgAssignee *assignee;   //被分配人
@property(nonatomic,strong) NSMutableArray<KFLeaveMsgAttachmentModel *> *attachments;    //附件
@property(nonatomic,copy) NSString *content;                //会话内容
@property(nonatomic,copy) NSString *created_at;             //留言创建时间
@property(nonatomic,strong) KFLeaveMsgCreator *creator;     //留言者
@property(nonatomic,assign) long ID;                        //留言id
@property(nonatomic,strong) KFLeaveMsgStatus *status;       //留言状态
@property(nonatomic,copy) NSString *subject;                //留言主题
@property(nonatomic,copy) NSString *updated_at;             //留言更新时间
@property(nonatomic,strong) NSNumber *version;              //留言index
@property(nonatomic,assign) CGFloat commentHeight;          //留言评论的高度
@end
//被分配者
@interface KFLeaveMsgAssignee : NSObject
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *username;
@end
//发起者
@interface KFLeaveMsgCreator : NSObject
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
@interface KFLeaveMsgStatus : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@end

//附件
@interface KFLeaveMsgAttachmentModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *type;
@end





