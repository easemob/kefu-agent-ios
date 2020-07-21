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
    _numLabel.textColor = UIColor.grayColor;
    _timeLabel.text = [self formatDate:leaveMessage.createDate];
    _timeLabel.textColor = UIColor.grayColor;
    _subjectLabel.text = leaveMessage.subject;
    _subjectLabel.textColor = UIColor.grayColor;
    if (leaveMessage.creator) {
        _customerLabel.text = [NSString stringWithFormat:@"%@:%@",leaveMessage.creator.nickname, leaveMessage.content];
    } else {
        _customerLabel.text = @"";
    }
    _customerLabel.textColor = UIColor.grayColor;
    _typeLabel.text = [self stringFromType:leaveMessage.type];
    _typeLabel.textColor = UIColor.grayColor;
}

- (NSString *)stringFromType:(HLeaveMessageType)aType {
    NSString *typeName = @"";
    switch (aType) {
        case HLeaveMessageType_untreated:
        {
            typeName = @"未处理";
        }
            break;
        case HLeaveMessageType_processing:
        {
            typeName = @"处理中";
        }
            break;
        case HLeaveMessageType_resolved:
        {
            typeName = @"已解决";
        }
            break;
            
        default:
            break;
    }
    return typeName;
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
