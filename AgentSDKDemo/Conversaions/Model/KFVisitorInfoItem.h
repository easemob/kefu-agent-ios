//
//  KFVisitorInfoItem.h
//  EMCSApp
//
//  Created by afanda on 2/23/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSingleLineText @"TEXT_STRING"  //单行文本
#define kMultiLineText @"TEXTAREA_STRING"   //多行文本
#define kSelectLineMenu @"SELECT_STRING"    //多选
#define kNumber @"TEXT_NUMBER"   //数字
#define kDate @"DATE"       //日历


@interface ColumnType : NSObject
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *typeDescribe;
@property (nonatomic, copy) NSString *dateType;
@property (nonatomic, copy) NSString *componentType;
@end

@interface KFVisitorInfoItem : NSObject

@property (nonatomic, copy) NSString *columnName; //上传时用的这个
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, strong) ColumnType *columnType;
@property (nonatomic, assign) BOOL systemColumn;
@property (nonatomic, assign) BOOL searchable;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL must;
@property (nonatomic, assign) BOOL validate;
@property (nonatomic, assign) BOOL readonly;
@property (nonatomic, assign) BOOL allowMultivalued;
@property (nonatomic, copy) NSString *defaultValue;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, copy) NSString *columnDescribe;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, copy) NSString *columnStatus;
@property (nonatomic, strong) NSArray  *values;
@property (nonatomic, assign) CGFloat cellHeight;
@end
