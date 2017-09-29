//
//  NSObject+KFAdd.h
//  EMCSApp
//
//  Created by afanda on 16/11/2.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KFAdd)
- (NSMutableDictionary *)dicFromModel;
- (BOOL)isSupportRecord;
- (BOOL)isPermission; //是否询问过权限
@end
