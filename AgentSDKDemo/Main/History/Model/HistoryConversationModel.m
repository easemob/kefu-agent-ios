//
//  HistoryConversationModel.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "HistoryConversationModel.h"

@implementation HistoryConversationModel

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.agentUserNiceName = [dictionary safeStringValueForKey:@"agentUserNiceName"];
        self.summarys = [dictionary objectForKey:@"summarys"];
    }
    return self;
}

@end
