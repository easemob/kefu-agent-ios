//
//  KFWarningCell.m
//  AgentSDKDemo
//
//  Created by afanda on 12/8/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFWarningCell.h"

#define kmargin 10

@implementation KFWarningCell
{
    UILabel *_timeLabel;
    UILabel *_levelLabel;
    UILabel *_tipLabel;
    UILabel *_idLabel;
    UILabel *_nikeNameLabel;
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self initUI];
    }
    return self;
}

- (void)setModel:(KFWarningModel *)model {
    _timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:model.alarmDateTime/1000] dateDescription];
    if (model.superviseLevel == 1) {
        _levelLabel.text = @"一级告警";
    } else if (model.superviseLevel == 2) {
        _levelLabel.text = @"二级告警";
    } else if (model.superviseLevel == 3) {
        _levelLabel.text = @"三级告警";
    }
    _tipLabel.text = model.ruleName;
    _idLabel.text = model.visitorName;
    _nikeNameLabel.text = model.agentName;
}

- (void)layoutSubviews {
    _nikeNameLabel.frame = CGRectMake(self.width-100, CGRectGetMaxY(_tipLabel.frame)+kmargin, 90, 20);
    _levelLabel.frame = CGRectMake(self.width-90, kmargin, 80, 20);
    _idLabel.width = self.width - 2 * kmargin -100;
}

- (void)initUI {
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kmargin, kmargin, 200, 20)];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_timeLabel];
    
    _levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _levelLabel.font = [UIFont systemFontOfSize:14];
    _levelLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_levelLabel];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_timeLabel.frame)+ kmargin, 200, 20)];
    _tipLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_tipLabel];
    
    _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_tipLabel.frame)+ kmargin, 0, 20)];
    _idLabel.lineBreakMode = NSLineBreakByClipping;
    _idLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_idLabel];
    
    _nikeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tipLabel.frame)+kmargin, 100, 20)];
    _nikeNameLabel.textAlignment = NSTextAlignmentRight;
    _nikeNameLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_nikeNameLabel];
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
