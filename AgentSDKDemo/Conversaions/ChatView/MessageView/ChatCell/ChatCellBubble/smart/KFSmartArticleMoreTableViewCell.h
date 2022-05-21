//
//  KFSmartArticleMoreTableViewCell.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/21.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFSmartArticleMoreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *readFullArticle;

- (void)setModel:(KFMSGTypeModel *)model;

@end

NS_ASSUME_NONNULL_END
