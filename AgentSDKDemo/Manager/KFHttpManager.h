//
//  KFHttpManager.h
//  EMCSApp
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface KFHttpManager : AFHTTPSessionManager
singleton_interface(KFHttpManager)
/**
 下载文件

 @param urlPath 文件的url
 @param completion 返回文件的NSData
 @return
 */
- (NSURLSessionDownloadTask *)asyncDownLoadFileWithFilePath:(NSString*)urlPath
                                                       completion:(void(^)(id responseObject,NSError *error))completion;




@end
