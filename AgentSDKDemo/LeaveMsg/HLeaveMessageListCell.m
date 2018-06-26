//
//  HLeaveMessageListCell.m
//  AgentSDKDemo
//
//  Created by 杜洁鹏 on 2018/6/13.
//  Copyright © 2018年 环信. All rights reserved.
//

#import "HLeaveMessageListCell.h"

@interface HLeaveMessageListCell()
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end

@implementation HLeaveMessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setLeaveMessage:(HLeaveMessage *)leaveMessage {
    _leaveMessage = leaveMessage;
    _numLabel.text = [NSString stringWithFormat:@"No.%@",leaveMessage.leaveMessageId];
    _timeLabel.text = [self formatDate:leaveMessage.createDate];
    _subjectLabel.text = leaveMessage.subject;
    if (leaveMessage.assignee) {
        _customerLabel.text = [NSString stringWithFormat:@"分配:%@",leaveMessage.assignee.nickname];
    } else {
        _customerLabel.text = @"分配:未分配";
    }
    _typeLabel.text = [self stringFromType:leaveMessage.type];
}

- (NSString *)stringFromType:(HLeaveMessageType)aType {
    return @"";
}

- (NSString *)formatDate:(NSString *)time
{
    if (time.length > 0) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
        NSDate *date = [format dateFromString:time];
        return [date minuteDescription];
    }
    return @"";
}

@end
