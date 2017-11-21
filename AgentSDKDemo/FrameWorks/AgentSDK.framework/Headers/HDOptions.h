//
//  HDOptions.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDOptions : NSObject

/*
 *  控制台是否输出log, 默认为NO
 */
@property (nonatomic, assign) BOOL enableConsoleLog;

/*
 * 推送证书的名称
 */
@property (nonatomic, copy) NSString *apnsCertName;

/**
 * 客服服务器地址
 */
@property (nonatomic, copy) NSString *kefuRestAddress;

@end
