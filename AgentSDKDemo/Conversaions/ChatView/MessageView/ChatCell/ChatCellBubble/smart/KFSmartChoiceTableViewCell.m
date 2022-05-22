//
//  KFSmartChoiceTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartChoiceTableViewCell.h"
@interface KFSmartChoiceTableViewCell ()
{
    
    KFSmartModel *_model;
    
}
@end
@implementation KFSmartChoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.iconImage.image = [UIImage imageNamed:@"tabbar_icon_ongoing"];
    self.labelSend.font  = [UIFont systemFontOfSize:18];
     self.labelSend.textColor = [UIColor colorWithRed:75/255.0 green:131/255.0 blue:235/255.0 alpha:1];
    _knowledgeLabel.font = [UIFont systemFontOfSize:16];
    _knowledgeLabel.textAlignment = NSTextAlignmentCenter;
//        _knowledgeLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _knowledgeLabel.backgroundColor = [UIColor colorWithRed:168/255.0 green:178/255.0 blue:185/255.0 alpha:0.8];
    _knowledgeLabel.layer.cornerRadius = 5;
    _knowledgeLabel.layer.masksToBounds = YES;
    _knowledgeLabel.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *labelTapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSendClick)];

    [self.labelSend addGestureRecognizer:labelTapGestureRecognizer1];

    self.labelSend.userInteractionEnabled = YES; // 可以理解
    self.answerLabel.numberOfLines = 0;
    self.answerLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)labelSendClick{
    
    if (self.clickChoiceItemBlock) {
        
        self.clickChoiceItemBlock(_model, self);
    }
    
}
- (void)setModel:(KFSmartModel *)model{
    
    _model = model;
    self.labelSendNum.text = [NSString stringWithFormat:@"%ld",model.sendFrequencyStr] ;
    
    KFMSGTypeItemModel *itemModel = [KFMSGTypeItemModel yy_modelWithDictionary:[[model.ext valueForKey:@"msgtype"] valueForKey:@"choice"]];
                               
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    NSString *title = @"";
    NSString *headStr =itemModel.title;
    NSString *str = @"";

    for (int i = 0; i<itemModel.list.count; i++) {
        NSString * str = itemModel.list[i];
       
        title = [NSString stringWithFormat:@"%@\n%d %@",title, i+1 ,str];

        
    }
    
    model.answer = [NSString stringWithFormat:@"%@%@",headStr,title];
    
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
