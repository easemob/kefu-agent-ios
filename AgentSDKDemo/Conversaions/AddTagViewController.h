//
//  AddTagViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/1/6.
//  Copyright © 2016年 easemob. All rights reserved.
//


#import "DXBaseViewController.h"

@protocol AddTagViewDelegate <NSObject>

- (void)saveAndEndChat;

@end

@interface AddTagViewController : DXBaseViewController

@property (nonatomic, strong) NSString *serviceSessionId;
@property (nonatomic, assign) BOOL saveAndEnd;

@property (nonatomic, weak) id<AddTagViewDelegate> delegate;

@end

@interface TagNode : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *tenantId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) NSInteger color;
@property (nonatomic, copy) NSString *createDateTime;
@property (nonatomic, copy) NSString *lastUpdateDateTime;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, copy) NSArray *children;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (UIColor*)tagNodeColor;

@end

@interface TagNodeTableViewCell : UITableViewCell

@property (nonatomic, copy) UIColor *color;

@property (nonatomic, strong) UIView *circleView;

@end
