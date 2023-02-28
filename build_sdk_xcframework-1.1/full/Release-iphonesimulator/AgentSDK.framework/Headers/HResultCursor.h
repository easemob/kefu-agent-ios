//
//  HResultCursor.h
//  AgentSDK
//
//  Created by 杜洁鹏 on 2018/6/14.
//  Copyright © 2018年 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HResultCursor : NSObject
@property (nonatomic, assign) BOOL isFirst;             // 是否是第一页
@property (nonatomic, assign) BOOL isLast;              // 是否是最后一页
@property (nonatomic, assign) NSInteger totalPages;     // 总页数
@property (nonatomic, assign) NSInteger pageSize;       // 每页的元素个数
@property (nonatomic, assign) NSInteger totalElements;  // 总元素个数
@property (nonatomic, assign) NSInteger pageNum;        // 当前页码
@property (nonatomic, strong) NSArray *elements;        // 当前页数元素
@end
