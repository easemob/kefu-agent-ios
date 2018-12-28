//
//  KFFileCache.h
//  EMCSApp
//
//  Created by afanda on 9/7/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFFileCache : NSObject

singleton_interface(KFFileCache)

@property(nonatomic,copy) NSString *basePath;


/**
 缓存文件[语音、文件]

 @param url 语音url
 */
- (void)storeFileWithRemoteUrl:(NSString *)url
                    completion:(void(^)(id responseObject, NSString *path, NSError *error))completion;


/**
 将文件移动到
 */
- (void)moveItemAtPath:(NSString *)srcPath toCachePath:(NSString *)name;


/**
 文件的本地路径

 @param url remoteUrl
 */
- (NSString *)filePathFromDiskCacheForKey:(NSString *)url;


/**
 通过url拿到uuid

 @param urlStr url
 @return uuid
 */
- (NSString *)uuidWithUrlStr:(NSString *)urlStr;

/**
 通过url拿到存放地址
 */
- (NSString *)fileFullPathWithUrlStr:(NSString *)urlStr;

/**
 key为file的url
 */
- (NSData *)fileFromMemoryCacheForKey:(NSString *)key;

- (BOOL)isExistFile:(NSString *)path;


@end
