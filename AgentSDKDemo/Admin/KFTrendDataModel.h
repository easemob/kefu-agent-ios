//
//  KFSessionTrendModel.h
//  EMCSApp
//
//  Created by afanda on 5/9/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodayModel : NSObject

@property(nonatomic,strong) NSString *agentNiceName;
@property(nonatomic,copy) NSNumber *cnt_sc;
@property(nonatomic,copy) NSNumber *count;
@property(nonatomic,copy) NSString *key;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface ItemModel : NSObject

@property(nonatomic,assign) NSTimeInterval time;
@property(nonatomic,assign) NSInteger value;

@end

@interface TypeModel : NSObject

@property(nonatomic,copy) NSString *type;

@property(nonatomic,strong) NSMutableDictionary *valueDic;//{time:count}

@end

@interface KFTrendDataModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property(nonatomic,strong) NSArray <TypeModel *> *types;

@end
