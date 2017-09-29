//
//  KFHttpManager.m
//  EMCSApp
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFHttpManager.h"
#import "KFFileCache.h"

@implementation KFHttpManager

singleton_implementation(KFHttpManager);

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        _instance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _instance.requestSerializer.timeoutInterval = 30.f;
        _instance.operationQueue.maxConcurrentOperationCount = 5;
    });
    return _instance;
}

- (NSURLSessionDownloadTask *)asyncDownLoadFileWithFilePath:(NSString *)urlPath completion:(void (^)(id, NSError *))completion {
    NSURLSessionDownloadTask *task = nil;
    NSData *data =  [[KFFileCache sharedInstance] fileFromMemoryCacheForKey:urlPath];
    if (data) {
        if (completion) {
            completion(data, nil);
            return task;
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlPath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    task = [[KFHttpManager sharedInstance] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *fullPath = [[KFFileCache sharedInstance] fileFullPathWithUrlStr:urlPath];
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            if (completion) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *fileData =[NSData dataWithContentsOfFile:[filePath path]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(fileData, nil);;
                    });
                });
            }
        } else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
    [task resume];
    return task;
}

@end
