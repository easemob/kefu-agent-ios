//
//  MediaFileModel.h
//  EMCSApp
//
//  Created by EaseMob on 15/4/20.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEDIA_UUID @"uuid"
#define MEDIA_URL @"url"
#define MEDIA_CONTENTTYPE @"contentType"
#define MEDIA_FILENAME @"fileName"
#define MEDIA_LENGTH @"contentLength"

@interface HDMediaFile : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileName;
@property (assign, nonatomic) NSInteger contentLength;

@property (nonatomic, assign) NSInteger duration; //audio

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
