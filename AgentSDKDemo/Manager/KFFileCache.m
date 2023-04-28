//
//  KFFileCache.m
//  EMCSApp
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "KFFileCache.h"

@implementation KFFileCache
{
    NSFileManager *_fm;
}

singleton_implementation(KFFileCache)

- (instancetype)init {
    self = [super init];
    if (self) {
        _fm = [NSFileManager defaultManager];
       [self createBaseDir];
    }
    return self;
}

- (NSString *)basePth {
    if (_basePath == nil) {
        [self createBaseDir];
    }
    return _basePath;
}


- (void)storeVoiceWithRemoteUrl:(NSString *)url {
    if ([self isExistFile:[self fileFullPathWithUrlStr:url]]) {
        return;
    }
    [[KFHttpManager sharedInstance] asyncDownLoadFileWithFilePath:url completion:^(id responseObject, NSString *path, NSError *error) {
        
    }];
}


- (void)storeFileWithRemoteUrl:(NSString *)url completion:(void (^)(id, NSString * , NSError *))completion{
    if ([self isExistFile:[self fileFullPathWithUrlStr:url]]) {
        NSString *path = [self filePathFromDiskCacheForKey:url];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (completion) {
            completion(data, path, nil);
        }
        return;
    }
    [[KFHttpManager sharedInstance] asyncDownLoadFileWithFilePath:url completion:^(id responseObject, NSString *path,  NSError *error) {
        if (completion) {
            NSError *nerror = nil;
            if (error != nil) {
                nerror = [NSError errorWithDomain:error.description code:error.code userInfo:nil];
            }
            completion(responseObject, path, nerror);
        }
    }];
}

- (void)moveItemAtPath:(NSString *)srcPath toCachePath:(NSString *)name {
    NSString *desPath = [_basePath stringByAppendingPathComponent:name];
    NSError *error;
     [_fm moveItemAtURL:[NSURL fileURLWithPath:srcPath] toURL:[NSURL fileURLWithPath:desPath] error:&error];
    NSLog(@"move error %@",error);
}



- (NSString *)filePathFromDiskCacheForKey:(NSString *)url {
    if ([self isExistFile:[self fileFullPathWithUrlStr:url]]) {
        return [self fileFullPathWithUrlStr:url];
    }
    return nil;
}

- (NSString *)uuidWithUrlStr:(NSString *)urlStr {
    if ([urlStr containsString:@"/"]) {
        NSArray *arr = [urlStr componentsSeparatedByString:@"/"];
        return [arr lastObject];
    }
    return nil;
}

- (NSString *)fileFullPathWithUrlStr:(NSString *)urlStr {
    return [_basePath stringByAppendingPathComponent:[self uuidWithUrlStr:urlStr]];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    NSString *fullPath = [self fileFullPathWithUrlStr:key];
    UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
    return image;
}

- (NSData *)fileFromMemoryCacheForKey:(NSString *)key {
    NSString *fullPath = [self fileFullPathWithUrlStr:key];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return data;
}


//private
- (void)createBaseDir {
    NSString *homeDir = NSHomeDirectory();
    NSString *libDir = [homeDir stringByAppendingPathComponent:@"Library"];
    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL isCreate = NO;
    if (![fm fileExistsAtPath:dbDirectoryPath isDirectory:&isDirectory]) {
        isCreate = [fm createDirectoryAtPath:dbDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        if (!isCreate) {
            dbDirectoryPath = nil;
        }
    }
    _basePath = dbDirectoryPath;
}

- (BOOL)isExistFile:(NSString *)path {
    if ([_fm fileExistsAtPath:path]) {
       return YES;
    }
    return NO;
}

@end
