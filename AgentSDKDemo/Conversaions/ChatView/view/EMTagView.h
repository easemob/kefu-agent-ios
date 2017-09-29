//
//  EMTagView.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagNode;
@protocol TagNodeDelegate <NSObject>

- (void)deleteWithTagNode:(TagNode*)tagNode;

@end

@interface EMTagView : UIView

@property (nonatomic, weak) id<TagNodeDelegate> delegate;

- (instancetype)initWithRootNode:(TagNode*)rootNode childNode:(TagNode*)childNode;

- (instancetype)initWithRootNode:(TagNode*)rootNode childNode:(TagNode*)childNode edit:(BOOL)edit;

- (void)setWithRootNode:(TagNode*)rootNode childNode:(TagNode*)childNode;

@end
