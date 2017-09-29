//
//  CompileTableViewCell.m
//  EMCSApp
//
//  Created by EaseMob on 16/1/20.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "CompileTableViewCell.h"


@implementation CompileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self CompileCell];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.width = CGRectGetHeight(self.frame);
    self.imageView.height = CGRectGetHeight(self.frame);
    self.imageView.left = CGRectGetWidth(self.frame) - 100;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    //上分割线，
    //    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 230, 231, 1).CGColor);
    //    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 0.5));
    //下分割线
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(70, rect.size.height - 0.5, rect.size.width - 60, 0.5f));
}

- (void)CompileCell{
    CGFloat X = 10;
    NSInteger Height = 50;
    _title = [[UILabel alloc]initWithFrame:CGRectMake(X, (Height-30)/2, KScreenWidth/5-10, 30)];
    _title.backgroundColor = [UIColor clearColor];
    _title.font = [UIFont systemFontOfSize:15.f];
    _title.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:_title];
    
    _nextimage = [[UIImageView alloc]init];
    _nextimage.backgroundColor = [UIColor clearColor];
    [self addSubview:_nextimage];
    
    _nickName = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth/5, (Height-30)/2,kVisitorInfomationContentWidth, 30)];
    _nickName.backgroundColor = [UIColor clearColor];
    _nickName.textAlignment = NSTextAlignmentLeft;
    _nickName.textColor = RGBACOLOR(26, 26, 26, 1);
    _nickName.font = [UIFont systemFontOfSize:17.f];
    _nickName.numberOfLines = 0;
    [self addSubview:_nickName];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setModel:(HDVisitorInfoItem *)model {
    _title.text = model.displayName;
    if (model.values.count>0) {
        if (model.columnType == HDColumnTypeDate) {
            _nickName.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",model.values[0]]];
        } else if (model.columnType == HDColumnTypeNumber) {
             NSNumber *value = model.values[0];
            if ([value integerValue] == 0) {
                _nickName.textColor = [UIColor lightGrayColor];
                _nickName.text = model.columnDescribe;
            } else {
                _nickName.textColor = [UIColor blackColor];
                _nickName.text = [NSString stringWithFormat:@"%@",value];
            }
        } else {
            NSString *value = model.values[0];
            if (value.length == 0) {
                _nickName.textColor = [UIColor lightGrayColor];
                _nickName.text = model.columnDescribe;
            } else {
                if (model.columnType == HDColumnTypeMultiText) {
                    CGFloat height = 30;
                    NSDictionary *att = @{ NSFontAttributeName: [UIFont systemFontOfSize:17.0]};
                    CGRect rect = [value boundingRectWithSize:CGSizeMake(kVisitorInfomationContentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin |
                                   NSStringDrawingUsesFontLeading attributes:att context:nil];
                    height = rect.size.height;
                    _nickName.height = height;
                }
                _nickName.text = value;
            }
        }
    } else {
        _nickName.textColor = [UIColor lightGrayColor];
        NSString *placeHolder = model.columnDescribe;
        if (![placeHolder isKindOfClass:[NSNull class]] && placeHolder!=nil) {
            _nickName.text = placeHolder;
        } else {
            if (model.columnType == HDColumnTypeMultiSelected) {
                _nickName.text = @"请选择";
            }
        }
    }
    if (model.readonly) {
        _nickName.textColor = [UIColor lightGrayColor];
    }
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
