//
//  KFSmartImageTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartImageTableViewCell.h"
@interface KFSmartImageTableViewCell ()
{
    
    KFSmartModel *_model;
    
}
@end
@implementation KFSmartImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)labelSendClick{
    
    if (self.clickImageItemBlock) {
        
        _model.sendImage =self.image.image;
        self.clickImageItemBlock(_model, self.image.image);
    }
    
}
- (void)setModel:(KFSmartModel *)model{
    _model = model;
    NSString *kefuAddress = HDClient.sharedClient.option.kefuRestAddress;
    NSString *url = [NSString stringWithFormat:@"%@%@",kefuAddress,model.mediaFileUrl];
    [self.image sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"visitor_icon_imagebroken_big@2x.png"]];
   
    NSInteger  sendFrequencyNum = [[NSString stringWithFormat:@"%ld",model.sendFrequencyStr] integerValue];
      
      if (sendFrequencyNum > 0) {
          self.labelSendNum.text = [NSString stringWithFormat:@"%ld",model.sendFrequencyStr] ;
      }else{
          
          self.labelSendNum.text = @"" ;
      }
    
    if ([model.cooperationSource isEqualToString:@"knowledge"]) {
        self.knowledgeLabel.text = @"知识库";
    }else{
        self.knowledgeLabel.text =@"";
    }
    
}
@end
