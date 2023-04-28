//
//  KFVideoDetailViewController.h
//  AgentSDKDemo
//
//  Created by houli on 2022/2/23.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDVECVideoDetailModel.h"
NS_ASSUME_NONNULL_BEGIN
#ifdef DEBUG // 输出日志 (格式: [编译时间] [文件名] [方法名] [行号] [输出内容])
#define NSLog(FORMAT, ...) fprintf(stderr,"------- 🎈🎈 -------\n编译时间:%s\n文件名:%s\n方法名:%s\n行号:%d\n打印信息:%s\n\n", \
__TIME__, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
__func__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(FORMAT, ...) nil
#endif
@interface KFVECVideoDetailViewController : UIViewController
@property (nonatomic, strong) HDVECVideoDetailModel * currentModel;
@end

NS_ASSUME_NONNULL_END
