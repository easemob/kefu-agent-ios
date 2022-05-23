//
//  KFMSGTypeModel.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFMSGTypeItemModel : NSObject
@property (nonatomic, copy) NSArray *list;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSString *sendMenuMessageStr;

@end


@interface KFMSGTypeModel : NSObject

@property (nonatomic, copy) NSString *createdTime;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, copy) NSString *picurl;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *des;
@property (nonatomic, assign) NSInteger sendFrequencyStr ;
@property (nonatomic, strong) KFMSGTypeItemModel *itemModel;
@property (nonatomic,assign)CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
