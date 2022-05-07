//
//  SingletonDefine.h
//  EMCSApp
//
//  Created by afanda on 7/10/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#ifndef SingletonDefine_h
#define SingletonDefine_h
//interface
#define singleton_interface(className) \
+ (className *)sharedInstance;

//implementation
#define singleton_implementation(className) \
static className *_instance; \
+ (id)allocWithZone:(NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
    return _instance; \
} \
+ (className *)sharedInstance \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [[self alloc] init]; \
    }); \
    return _instance; \
}

#endif /* SingletonDefine_h */
