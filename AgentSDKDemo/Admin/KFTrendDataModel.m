//
//  KFSessionTrendModel.m
//  EMCSApp
//
//  Created by afanda on 5/9/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFTrendDataModel.h"

@implementation TodayModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _agentNiceName = [dictionary objectForKey:@"agentNiceName"];
        _cnt_sc = [dictionary objectForKey:@"cnt_sc"];
        _count = [dictionary objectForKey:@"count"];
        _key = [dictionary objectForKey:@"key"];
    }
    return self;
}

@end

@implementation ItemModel

@end

@implementation TypeModel

- (NSMutableDictionary *)valueDic {
    if (_valueDic == nil) {
        _valueDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _valueDic;
}

@end

@implementation KFTrendDataModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSMutableArray *src = [NSMutableArray arrayWithCapacity:0];
        NSArray *arr = [dictionary objectForKey:@"result"];
        for (NSDictionary *dic in arr) {
            TypeModel *type = [[TypeModel alloc] init];
            type.type = [dic valueForKey:@"type"];
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *itemDic in (NSArray *)[dic valueForKey:@"value"]) {
                
                [type.valueDic setValue:[itemDic valueForKey:@"value"] forKey:[NSString stringWithFormat:@"%@",[itemDic valueForKey:@"time"]]];
                
                ItemModel *item = [[ItemModel alloc] init];
                item.time = [[itemDic valueForKey:@"time"] doubleValue];
                item.value = [[itemDic valueForKey:@"value"] integerValue];
                [items addObject:item];
            }
            [src addObject:type];
            self.types = src;
        }
    }
    return self;
}

@end
