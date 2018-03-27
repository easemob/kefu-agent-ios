//
//  KFSuperviseDetailCell.m
//  AgentSDKDemo
//
//  Created by afanda on 12/7/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "KFSuperviseDetailCell.h"
#import "HDTipLabel.h"
#import "UIColor+KFColor.h"

#define kmargin 10

@implementation KFSuperviseDetailCell
{
    KFDetailModel *_model;
    UIButton *_stateBtn;
    UILabel *_nickName;
    HDTipLabel *_receptionLabel;
    HDTipLabel *_endLabel;
    HDTipLabel *_avgTimeLabel;
    HDTipLabel *_firstLoginLabel;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)setModel:(KFDetailModel *)model {
    _model = model;
    _nickName.text = model.nickname;
    
    [_stateBtn setImage:[self getUIImageWithState:model.kfState] forState:UIControlStateNormal];
    [_stateBtn setTitle:[self getTitleWithState:model.kfState] forState:UIControlStateNormal];;
    
    _receptionLabel.text = [NSString stringWithFormat:@"%ld人  当前接待/%ld人最大接待",model.current_session_count,model.max_session_count];

    
    _endLabel.text = [NSString stringWithFormat:@"%d条  已结束会话",(int)model.session_terminal_count];
    
    _avgTimeLabel.text = [NSString stringWithFormat:@"%d  平均会话时长",model.avg_session_time];
   
    _firstLoginLabel.text = [NSString stringWithFormat:@"%@  今天首次登陆",model.first_login_time_of_today];
}

- (UIImage *)getUIImageWithState:(HDAgentLoginStatus)state {
    NSString *imageName = @"";
    switch (state) {
        case HDAgentLoginStatusOnline:{
            imageName = @"state_green";
            break;
        }
        case HDAgentLoginStatusBusy: {
            imageName = @"state_red";
            break;
        }
        case HDAgentLoginStatusLeave: {
            imageName = @"state_blue";
            break;
        }
        case HDAgentLoginStatusHidden: {
            imageName = @"state_yellow";
            break;
        }
        case HDAgentLoginStatusOffline: {
            imageName = @"state_gray";
            break;
        }
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (NSString *)getTitleWithState:(HDAgentLoginStatus)state {
    NSString *title = @"";
    switch (state) {
        case HDAgentLoginStatusOnline:{
            title = @"空闲";
            break;
        }
        case HDAgentLoginStatusBusy: {
            title = @"忙碌";
            break;
        }
        case HDAgentLoginStatusLeave: {
            title = @"离开";
            break;
        }
        case HDAgentLoginStatusHidden: {
            title = @"隐身";
            break;
        }
        case HDAgentLoginStatusOffline: {
            title = @"离线";
            break;
        }
        default:
            break;
    }
    return title;
}

- (void)initUI {
    //技能组昵称
    _nickName = [[UILabel alloc] initWithFrame:CGRectMake(kmargin, kmargin, 150, 20)];
    _nickName.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:_nickName];
    
    _stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _stateBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_stateBtn setTitleColor:[UIColor colorWithHexString:@"#4D4D4D"] forState:UIControlStateNormal];
    [self.contentView addSubview:_stateBtn];
    
    _receptionLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_nickName.frame)+kmargin, 300, 20)];
    _receptionLabel.imageName = @"reception";
    _receptionLabel.fontSize = 12.0;
    [self.contentView addSubview:_receptionLabel];
    
    _endLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_receptionLabel.frame)+kmargin, 300, 20)];
    _endLabel.imageName = @"stop";
    _endLabel.fontSize = 12.0;
    [self.contentView addSubview:_endLabel];
    
    _avgTimeLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_endLabel.frame)+kmargin, 300, 20)];
    _avgTimeLabel.imageName = @"average_time";
    _avgTimeLabel.fontSize = 12.0;
    [self.contentView addSubview:_avgTimeLabel];
    
    _firstLoginLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_avgTimeLabel.frame)+kmargin, 300, 20)];
    _firstLoginLabel.imageName = @"first_login";
    _firstLoginLabel.fontSize = 12.0;
    [self.contentView addSubview:_firstLoginLabel];
    
}

- (void)layoutSubviews {
    _stateBtn.frame = CGRectMake(self.width-60, kmargin, 50, 20);
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
