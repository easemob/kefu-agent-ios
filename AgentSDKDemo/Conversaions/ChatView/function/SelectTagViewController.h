//
//  SelectTagViewController.h
//  EMCSApp
//
//  Created by EaseMob on 16/1/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "DXTableViewController.h"

@interface SelectTagViewController : DXTableViewController

@property(nonatomic,strong) HDConversationManager *conversation;

- (instancetype)initWithStyle:(UITableViewStyle)style
                        tagId:(NSString*)tagId
                    treeArray:(NSArray*)treeArray
                        color:(UIColor*)color
                 isSelectRoot:(BOOL)isSelect;

@end
