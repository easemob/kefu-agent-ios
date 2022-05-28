//
//  KFSmartArticleMoreTableViewCell.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/21.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDVideoVerticalAlignmentLabel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickAtricleModorItemBlock)(KFMSGTypeModel *model,id cell);
@interface KFSmartArticleMoreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HDVideoVerticalAlignmentLabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *readFullArticle;
@property (weak, nonatomic) IBOutlet HDVideoVerticalAlignmentLabel *fTitleLabel;
@property(nonatomic,copy) ClickAtricleModorItemBlock clickAtricleModorItemBlock;

- (void)setModel:(KFMSGTypeModel *)model;

@end

NS_ASSUME_NONNULL_END
