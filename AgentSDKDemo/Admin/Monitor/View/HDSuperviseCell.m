//
//  HDSuperviseCell.m
//  AgentSDKDemo
//
//  Created by afanda on 12/5/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import "HDSuperviseCell.h"
#import "HDTipLabel.h"
#import "KFLineChart.h"
#import "KFStatuLabel.h"
#import "UIColor+KFColor.h"

#define kmargin 10

@interface HDSuperviseCell ()

@end

@implementation HDSuperviseCell
{
    HDGroupModel *_model;
    UILabel *_groupName;
    UIButton *_detail;
    HDTipLabel *_queueLabel;
    HDTipLabel *_receptionLabel;
    KFLineChart *_lineChart;
    NSMutableArray *_chartModels;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self initUI];
    }
    return self;
}

- (void)setModel:(HDGroupModel *)model {
    _model = model;
    _chartModels = [NSMutableArray arrayWithCapacity:0];
    _groupName.text = model.queue_name;
    _queueLabel.text = [NSString stringWithFormat:@"%ld人  正在排队",(long)model.session_wait_count];
    _receptionLabel.text = [NSString stringWithFormat:@"%ld人  当前接待/%ld人最大接待",
                            model.current_session_count,model.max_session_count];
    for (int i=0; i<5; i++) {
        KFLineChartModel *md = [KFLineChartModel new];
        md.status = i;
        if (i==0)  md.count = model.idle_count;
        if (i==1)  md.count = model.busy_count;
        if (i==2)  md.count = model.leave_count;
        if (i==3)  md.count = model.hidden_count;
        if (i==4)  md.count = model.offline_count;
        [_chartModels addObject:md];
    }
    _lineChart.models  = _chartModels;
}

- (void)layoutSubviews {
    _detail.frame = CGRectMake(self.width - 80, kmargin, 70, 20);
    _detail.imageEdgeInsets = UIEdgeInsetsMake(0, _detail.width-5, 0, 0);
    
    _lineChart.width = self.width-2*kmargin;
}

- (void)initUI {
    //技能组昵称
    _groupName = [[UILabel alloc] initWithFrame:CGRectMake(kmargin, kmargin, 150, 20)];
    _groupName.text = @"技能组";
    _groupName.font = [UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:_groupName];
    
    _detail = [UIButton buttonWithType:UIButtonTypeCustom];
    _detail.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_detail setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [_detail setTitleColor:[UIColor colorWithHexString:@"#15A2FC"] forState:UIControlStateNormal];
    [_detail setTitle:@"查看详情" forState:UIControlStateNormal];
    _detail.enabled = NO;
    [self.contentView addSubview:_detail];

    _queueLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_groupName.frame)+kmargin, 300, 20)];
    _queueLabel.imageName = @"line_up";
    _queueLabel.fontSize = 12.0;
    [self.contentView addSubview:_queueLabel];
    
    _receptionLabel = [[HDTipLabel alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_queueLabel.frame)+kmargin, 300, 20)];
    _receptionLabel.imageName = @"reception";
    _receptionLabel.fontSize = 12.0;
    [self.contentView addSubview:_receptionLabel];
    
    _lineChart = [[KFLineChart alloc] initWithFrame:CGRectMake(kmargin, CGRectGetMaxY(_receptionLabel.frame)+kmargin, self.width-2*kmargin, 50)];
    [self.contentView addSubview:_lineChart];
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
