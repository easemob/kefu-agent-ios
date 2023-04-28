//
//  KFSmartArticleTableViewCell.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol KFSmartArticleTableViewCellDelegate<NSObject>
- (void)didChangeCell:(NSArray * )items;
@end


typedef void(^ClickArticleItemBlock)(KFSmartModel *model,id cell);
@interface KFSmartArticleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (weak, nonatomic) IBOutlet UIView *contentAnswerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *knowledgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelCopy;
@property (weak, nonatomic) IBOutlet UILabel *labelCopyNum;
@property (weak, nonatomic) IBOutlet UILabel *labelSendNum;
@property (weak, nonatomic) IBOutlet UILabel *labelSend;
@property(nonatomic,copy) ClickArticleItemBlock clickArticleItemBlock;
@property (nonatomic,assign) id<KFSmartArticleTableViewCellDelegate> delegate;

- (void)setModel:(KFSmartModel *)model;
@end

NS_ASSUME_NONNULL_END
