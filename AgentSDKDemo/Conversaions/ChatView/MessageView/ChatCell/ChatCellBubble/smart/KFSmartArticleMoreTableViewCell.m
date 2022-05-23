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
    UITapGestureRecognizer *labelTapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSendClick)];

    [self addGestureRecognizer:labelTapGestureRecognizer1];

    self.userInteractionEnabled = YES; // 可以理解
    
    
    self.answerLabel.verticalAlignment = VerticalAlignmentTop;
    _answerLabel.verticalAlignment = VerticalAlignmentTop;
//        _answerLabel.backgroundColor = [UIColor redColor];
    _answerLabel.textAlignment=NSTextAlignmentLeft;
    _answerLabel.numberOfLines = 0;
    _answerLabel.lineBreakMode =NSLineBreakByTruncatingTail;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)labelSendClick{
    
    if (self.clickAtricleModorItemBlock) {
        
        self.clickAtricleModorItemBlock(_model, self);
    }
    
}

- (void)setModel:(KFMSGTypeModel *)model{
    
    _model = model;
    
    self.answerLabel.text = model.title;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.picurl] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big@2x.png"]];
    
    self.detailLabel.text = model.digest;
    
    
}
@end
