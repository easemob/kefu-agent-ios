//
//  EMChatHeaderTagView.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagNode;
@protocol EMChatHeaderTagViewDelegate <NSObject>

- (void)deleteTagNode:(TagNode*)node;

@end

@interface EMChatHeaderTagView : UIView

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, weak) id<EMChatHeaderTagViewDelegate> delegate;

- (instancetype)initWithSessionId:(NSString*)serviceSessionId edit:(BOOL)edit;

- (void)setTagDatasource:(NSArray*)datasource;

- (void)refreshHeaderView;

@end
