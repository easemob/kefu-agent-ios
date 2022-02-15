//
//  HDAgoraCallOptions.m
//  HelpDeskLite
//
//  Created by houli on 2022/1/6.
//  Copyright © 2022 hyphenate. All rights reserved.
//

#import "HDAgoraCallOptions.h"

@implementation HDAgoraCallOptions
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (NSUInteger)uid{
    
    if (_uid> 0) {
        
        return  _uid;
    }
    
    return 0;
    
}
@end
