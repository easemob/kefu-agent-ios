//
//  KFLeaveMsgListCell.m
//  EMCSApp
//
//  Created by afanda on 16/11/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "KFLeaveMsgListCell.h"
#import "NSDate+Formatter.h"

#define kLabelTop 9.f
@interface KFLeaveMsgListCell ()
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *taskLabel;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation KFLeaveMsgListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _numberLabel.frame = CGRectMake(10, kLabelTop, self.width - 111, 16);
    _contentLabel.frame = CGRectMake(10, CGRectGetMaxY(_numberLabel.frame) + 10, self.width - 111, 12);
    _statusLabel.frame = CGRectMake(10, CGRectGetMaxY(_contentLabel.frame) + 10, self.width - 111, 12);
    _timeLabel.frame = CGRectMake(self.frame.size.width - 150, kLabelTop, 140, 12);
    _taskLabel.frame = CGRectMake(self.frame.size.width - 150, CGRectGetMaxY(_contentLabel.frame) + 10, 140, 12);
    _lineView.frame = CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1);
}

- (void)setModel:(HDLeaveMessage *)model {
    _model = model;
    _numberLabel.text = [NSString stringWithFormat:@"No.%@",model.ID];
    _timeLabel.text = [self formatDate:model.created_at];
    _contentLabel.text = model.content;
    if (_model.assignee) {
        _statusLabel.text = [NSString stringWithFormat:@"分配:%@",_model.assignee.name];
    } else {
        _statusLabel.text = @"分配:未分配";
    }
    _taskLabel.text = _model.status.name;
}

- (NSString*)formatDate:(NSString*)time
{
    if (time.length > 0) {
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
        NSDate *date = [format dateFromString:time];
        return [date minuteDescription];
    }
    return @"";
}

- (void)initUI {
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, kLabelTop, self.width - 111, 16)];
    _numberLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.font = [UIFont systemFontOfSize:16.0];
    _numberLabel.textColor = RGBACOLOR(0x1a, 0x1a, 0x1a, 1);
    [self.contentView addSubview:_numberLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_numberLabel.frame) + 10, self.width - 111, 12)];
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.font = [UIFont systemFontOfSize:12.0];
    _contentLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    [self.contentView addSubview:_contentLabel];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_contentLabel.frame) + 10, self.width - 111, 12)];
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.font = [UIFont systemFontOfSize:12.0];
    _statusLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    [self.contentView addSubview:_statusLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 111, kLabelTop, 100, 12)];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_timeLabel];
    
    _taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 111, CGRectGetMaxY(_contentLabel.frame) + 10, 100, 12)];
    _taskLabel.textAlignment = NSTextAlignmentRight;
    _taskLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _taskLabel.backgroundColor = [UIColor clearColor];
    _taskLabel.font = [UIFont systemFontOfSize:12.0];
    _taskLabel.textColor = RGBACOLOR(0x99, 0x99, 0x99, 1);
    [self.contentView addSubview:_taskLabel];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, CGRectGetWidth(self.frame), 1)];
    _lineView.backgroundColor = RGBACOLOR(0xe5, 0xe5, 0xe5, 1);
    [self.contentView addSubview:_lineView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
