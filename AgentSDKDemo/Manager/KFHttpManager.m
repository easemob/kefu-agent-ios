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

- (NSString *)kefuRestAddress{
    HDClient *client = [HDClient sharedClient];
    NSString *kefuRest = nil;
    SEL selector = NSSelectorFromString(@"kefuRestAddress");
    if ([client respondsToSelector:selector]) {
        IMP imp = [client methodForSelector:selector];
        NSString *(*func)(id, SEL) = (void *)imp;
        kefuRest = func(client, selector);
    }
    return kefuRest;
}

    
- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super initWithBaseURL:[NSURL URLWithString:[self kefuRestAddress]]];
        _instance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _instance.requestSerializer = [AFJSONRequestSerializer serializer];
        _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _instance.requestSerializer.timeoutInterval = 30.f;
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/javascript", @"application/json", @"text/json", @"text/html", @"text/plain", @"charset=utf-8", nil];
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

- (void)asyncGetCountWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSError *))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dic setObject:@((long)([[NSDate date] timeIntervalSince1970]*1000)) forKey:@"_"];
    [self GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            id result = nil;
            result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}

- (void)asyncGetSessionTrendWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSError *))completion {
    [self asyncGetTrendDataWithUrl:path parameters:parameters completion:completion];
}

- (void)asyncGetMessageTrendWithPath:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSError *))completion {
     [self asyncGetTrendDataWithUrl:path parameters:parameters completion:completion];
}

- (void)aysncGetNewSessionTodayWithPath:(NSString *)path completion:(void (^)(id, NSError *))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@((long)([[NSDate date] timeIntervalSince1970]*1000)) forKey:@"_"];
    [self GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            id result = nil;
            if ([responseObject isKindOfClass:[NSData class]]) {
                result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            } else {
                result = responseObject;
            }
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}

- (void)asyncGetTrendDataWithUrl:(NSString *)url  parameters:(NSDictionary *)parameters completion:(void (^)(id, NSError *))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dic setValue:[HDClient sharedClient].currentAgentUser.tenantId forKey:@"tenantId"];
    NSString *path = [NSString stringWithFormat:url,[HDClient sharedClient].currentAgentUser.tenantId];
    [dic setObject:@((long)([[NSDate date] timeIntervalSince1970]*1000)) forKey:@"_"];
    [self  GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            id result = nil;
            if ([responseObject isKindOfClass:[NSData class]]) {
                result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            } else {
                result = responseObject;
            }
            completion(result, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}

- (void)asyncGetAgentQueuesWithPath:(NSString *)path completion:(void (^)(id, NSError *))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@((long)([[NSDate date] timeIntervalSince1970]*1000)) forKey:@"_"];
    [self GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            [self requestSuccess:responseObject completion:completion];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}


- (void)asyncGetMonitorDetailWithPath:(NSString *)path completion:(void (^)(id, NSError *))completion {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:@((long)([[NSDate date] timeIntervalSince1970]*1000)) forKey:@"_"];
    [self GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            [self requestSuccess:responseObject completion:completion];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}

- (void)asyncGetWarningsWithPath:(NSString *)path pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize completion:(void (^)(id, NSError *))completion {
    NSDictionary *par = @{
                          @"page":@(pageIndex),
                          @"size":@(pageSize)
                          };
    [self GET:path parameters:par success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            [self requestSuccess:responseObject completion:completion];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self requestFailed:task error:error completion:completion];
    }];
}

- (void)requestSuccess:(id)responseObject completion:(void(^)(id  ,NSError *))completion {
    id result = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
    }
    if ([result isKindOfClass:[NSDictionary class]]) {
        if ([[result objectForKey:@"status"] isEqualToString:@"OK"]) {
            completion([result objectForKey:@"entities"],nil);
        } else {
            NSString *er = [result objectForKey:@"errorDescription"];
            NSError *error = [NSError errorWithDomain:er code:200 userInfo:nil];
            completion(nil,error);
        }
    }
}

- (void)requestFailed:(NSURLSessionDataTask *)task error:(NSError *)error completion:(void(^)(id  ,NSError *))completion {
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)task.response;
    NSInteger statusCode = [urlResponse statusCode];
    if (statusCode == 401) {
        [[KFManager sharedInstance] userAccountNeedRelogin:HDAutoLogoutReasonDefaule];
    }
    if (completion) {
        completion(nil, error);
    }
}

@end
