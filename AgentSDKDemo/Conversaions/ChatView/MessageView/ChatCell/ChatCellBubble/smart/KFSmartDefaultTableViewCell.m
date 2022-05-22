//
//  KFSmartDefaultTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartDefaultTableViewCell.h"
@interface KFSmartDefaultTableViewCell ()
{
    
    KFSmartModel *_model;
    
}
@end
@implementation KFSmartDefaultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.iconImage.image = [UIImage imageNamed:@"tabbar_icon_ongoing"];
   self.labelSend.font =  self.labelCopy.font = [UIFont systemFontOfSize:18];
    self.labelSend.textColor= self.labelCopy.textColor = [UIColor colorWithRed:75/255.0 green:131/255.0 blue:235/255.0 alpha:1];

    _knowledgeLabel.font = [UIFont systemFontOfSize:16];
    _knowledgeLabel.textAlignment = NSTextAlignmentCenter;
//        _knowledgeLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _knowledgeLabel.backgroundColor = [UIColor colorWithRed:168/255.0 green:178/255.0 blue:185/255.0 alpha:0.8];
    _knowledgeLabel.layer.cornerRadius = 5;
    _knowledgeLabel.layer.masksToBounds = YES;
    _knowledgeLabel.textColor = [UIColor whiteColor];
    
    
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelCopyClick)];

    [self.labelCopy addGestureRecognizer:labelTapGestureRecognizer];

    self.labelCopy.userInteractionEnabled = YES; // 可以理解为设置label可被点击//
    
    UITapGestureRecognizer *labelTapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSendClick)];

    [self.labelSend addGestureRecognizer:labelTapGestureRecognizer1];

    self.labelSend.userInteractionEnabled = YES; // 可以理解
}
-(void)labelCopyClick{
    
    if (self.clickDefaultCopyItemBlock) {
        
        self.clickDefaultCopyItemBlock(_model, self);
    }
    
}

-(void)labelSendClick{
    
    if (self.clickDefaultSendItemBlock) {
        
        self.clickDefaultSendItemBlock(_model, self);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(KFSmartModel *)model{
    _model = model;
    self.answerLabel.text = model.answer;
    
    self.labelCopyNum.text =  [NSString stringWithFormat:@"%ld",model.quoteFrequencyStr] ;
    self.labelSendNum.text = [NSString stringWithFormat:@"%ld",model.sendFrequencyStr] ;
    
    if ([model.cooperationSource isEqualToString:@"knowledge"]) {
        self.knowledgeLabel.text = @"知识库";
    }else{
        self.knowledgeLabel.text =@"";
    }
    
}
@end
