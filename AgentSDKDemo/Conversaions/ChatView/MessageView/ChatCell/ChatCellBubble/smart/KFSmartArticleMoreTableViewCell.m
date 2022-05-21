//
//  KFSmartArticleMoreTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/21.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartArticleMoreTableViewCell.h"
@interface KFSmartArticleMoreTableViewCell()
{
    
    KFMSGTypeModel *_model;
    
}
@end
@implementation KFSmartArticleMoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(KFMSGTypeModel *)model{
    
    _model = model;
    
    self.answerLabel.text = model.title;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.picurl] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big@2x.png"]];
    
    self.detailLabel.text = model.digest;
    
    
}
@end
