//
//  KFPatternModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/18.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFPatternModel : NSObject
@property (nonatomic, assign) NSInteger  sendPattern;

@property (nonatomic, copy) NSString *sendPatternName;

@property (nonatomic, assign) NSInteger answerMatchPattern;

@property (nonatomic, copy) NSString *answerMatchPatternName;
@end

NS_ASSUME_NONNULL_END
