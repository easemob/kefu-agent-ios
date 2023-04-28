//
//  HDVECSessionHistoryCell.m
//  AgentSDKDemo
//
//  Created by easemob on 2023/2/16.
//  Copyright © 2023 环信. All rights reserved.
//

#import "HDVECSessionHistoryCell.h"

@implementation HDVECSessionHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.visitorName.textColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(HDVECSessionHistoryModel *)model{
    
    
    self.visitorName.text = [model.visitorUser objectForKey:@"username"];
    self.rtcSessionId.text = model.rtcSessionId;
    
    
    
}
@end
