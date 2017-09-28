//
//  HDWaitManager.h
//  AgentSDK
//
//  Created by afanda on 5/19/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDWaitUser.h"

@interface HDWaitManager : NSObject


/**
 待接入的总数
 在调用获取待加入队列时更新
 */
@property(nonatomic,assign) NSInteger waitUsersNum;
/**
 获取待接入队列
 
 @param pageIndex 第几页
 @param pageSize 每页数据个数
 @param parameters 预留参数，暂传nil
 @param completion 请求完成的回调【error == nil,为请求成功】
 */
- (void)asyncGetWaitQueuesWithPage:(NSInteger)pageIndex
                          pageSize:(NSInteger)pageSize
                        parameters:(NSDictionary *)parameters
                        completion:(void(^)(NSArray <HDWaitUser *> *waitUsers,HDError *error))completion;


/**
 接入待接入的会话

 @param userId 对方userId
 @param completion 完成回调
 */
- (void)asyncFetchUserWaitQueuesWithUserId:(NSString*)userId
                                completion:(void (^)(id responseObject, HDError *error))completion;

//筛选会话
- (void)asyncScreenWaitQueuesWithParameters:(NSDictionary *)parameters
                                 completion:(void(^)(NSArray <HDWaitUser *> *users ,HDError *errror))completion;

@end
