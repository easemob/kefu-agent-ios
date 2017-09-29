//
//  KFVisitorInfoItem.h
//  EMCSApp
//
//  Created by afanda on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, HDColumnType) {
    HDColumnTypeSingleText = 1, //单行文本
    HDColumnTypeMultiText, //多行文本
    HDColumnTypeMultiSelected,//多选
    HDColumnTypeNumber, //数字
    HDColumnTypeDate //日期
};

@interface HDVisitorInfoItem : NSObject

@property(nonatomic,copy) NSString *columnName; //上传时用的这个
@property(nonatomic,assign) NSInteger score;
@property(nonatomic,copy) NSString *displayName;
@property(nonatomic,assign) HDColumnType columnType;
@property(nonatomic,assign) BOOL systemColumn;
@property(nonatomic,assign) BOOL searchable;
@property(nonatomic,assign) BOOL visible;
@property(nonatomic,assign) BOOL must;
@property(nonatomic,assign) BOOL validate;
@property(nonatomic,assign) BOOL readonly;
@property(nonatomic,assign) BOOL allowMultivalued;
@property(nonatomic,copy) NSString *defaultValue;
@property(nonatomic,assign) NSInteger maxLength;
@property(nonatomic,copy) NSString *columnDescribe;
@property(nonatomic,strong) NSArray *options;
@property(nonatomic,assign) BOOL columnEnable;
@property(nonatomic,strong) NSArray  *values;
@property(nonatomic,assign) CGFloat cellHeight;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface HDVisitorInfo : NSObject

@property(nonatomic,copy) NSString *customerId;

@property(nonatomic,copy) NSMutableArray <HDVisitorInfoItem *> *items;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
