//
//  KFSmartTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartTableViewCell.h"
@interface KFSmartTableViewCell()
{
    KFMSGTypeModel *_model;
}
@end
@implementation KFSmartTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];

    [_clickLabel addGestureRecognizer:labelTapGestureRecognizer];

    _clickLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击//
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)labelClick{
    
    //跳转 url
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_model.url]];
    
    
    
}

- (void)setModel:(KFMSGTypeModel *)model{
    
    _model = model;
    self.titleLabel.text = model.title;
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.picurl] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big@2x.png"]];
    
    self.detailLabel.text = model.digest;
    
}


@end
