//
//  KFMonitorInstrumentView.m
//  UICollectionViewTest
//
//  Created by 杜洁鹏 on 2018/3/26.
//  Copyright © 2018年 杜洁鹏. All rights reserved.
//

#import "KFMonitorInstrumentView.h"

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define kRadius 150
#define kPinLong 135
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]


@implementation KFMonitorInstrumentPin

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:UIColor.clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawPin];
    [self drawLittleCircle];
}

- (void)drawPin {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height / 2)];
    [path addLineToPoint:CGPointMake(self.frame.size.width / 2, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width / 2 + 12, self.frame.size.height / 2)];
    [path addLineToPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height)];
    [path closePath];
    // 设置颜色
    CAShapeLayer *layers = [CAShapeLayer layer];
    layers.lineWidth = 2;
    layers.fillColor = UIColorFromHex(0x303F9F).CGColor;
    layers.path = path.CGPath;
    [self.layer addSublayer:layers];
}

- (void)drawLittleCircle {
    CGFloat startAngel = (-M_PI * 180);
    CGFloat endAngel   = (M_PI * 180);
    CGPoint point = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:point
                                                            radius:2
                                                        startAngle:startAngel
                                                          endAngle:endAngel
                                                         clockwise:YES];
    CAShapeLayer *perLayer = [CAShapeLayer layer];
    perLayer.path = tickPath.CGPath;
    [self.layer addSublayer:perLayer];
    
    CAShapeLayer *layers = [CAShapeLayer layer];
    layers.lineWidth = 2;
    layers.fillColor = [UIColor whiteColor].CGColor;
    layers.path = tickPath.CGPath;
    [self.layer addSublayer:layers];
}

@end

@interface KFMonitorInstrumentView()
@property (nonatomic, strong) KFMonitorInstrumentPin *pinView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation KFMonitorInstrumentView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString *)aName
                 currentCount:(NSInteger)currCount
                     maxCount:(NSInteger)aMaxCount {
    if (self = [super initWithFrame:frame]) {
        _currCount = currCount;
        _maxCount = aMaxCount;
        self.backgroundColor = [UIColor whiteColor];
        [self.textLabel setText:aName];
        [self.textLabel sizeToFit];
        [self addSubview:self.textLabel];
        [self addSubview:self.detailLabel];
        CGFloat textX = (self.frame.size.width - self.textLabel.width) / 2;
        CGFloat textY = (self.frame.size.height - self.textLabel.frame.size.height - kRadius) / 2 ;
        CGRect textFrame = CGRectMake(textX, textY, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.textLabel.frame = textFrame;
        [self addSubview:self.pinView];
    }
    
    return self;
}

- (void)updateCurrentCount:(NSInteger)aCurrCount maxCount:(NSInteger)aMaxCount {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _currCount = aCurrCount;
        _maxCount = aMaxCount;
        [self setupDetailLabel];
        CGAffineTransform transform = CGAffineTransformMakeRotation((float)_currCount / (float)_maxCount * M_PI);
        [UIView animateWithDuration:0.5f animations:^{
            self.pinView.transform = CGAffineTransformIdentity;
            self.pinView.transform = transform;
        }];
    });
}

- (void)setupDetailLabel {
    NSString *curStr = [NSString stringWithFormat:@"%d", (int)_currCount];
    NSString *maxStr = [NSString stringWithFormat:@"%d", (int)_maxCount];
    self.detailLabel.text = [NSString stringWithFormat:@"%@/%@", curStr, maxStr];
    [self.detailLabel sizeToFit];
    CGFloat dlX = (self.frame.size.width - self.detailLabel.frame.size.width) / 2;
    CGFloat dlY = self.frame.size.height / 2 + 20;
    self.detailLabel.frame = CGRectMake(dlX, dlY, self.detailLabel.frame.size.width, self.detailLabel.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGPoint centers = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self drawCircleWithCenter:centers];
    
}

- (void)addCalculateTextPositonWithArcCenter:(CGPoint)center
                                       Angle:(CGFloat)angel
                                      radius:(CGFloat)radius
                                        text:(NSString *)text
{
    CGFloat x = radius * cosf(angel);
    CGFloat y = -radius * sinf(angel);
    
    CGPoint point = CGPointMake(center.x + x, center.y - y);
    UILabel *textLabel      = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 5, point.y - 5, 14, 14)];
    textLabel.text          = text;
    textLabel.textColor     = UIColorFromHex(0x3F51B5);
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.font = [UIFont systemFontOfSize:8];
    [textLabel sizeToFit];
    [self addSubview:textLabel];
}

// 画弧
- (void)drawCircleWithCenter:(CGPoint)aCenterPoint {
    CGFloat perAngle = M_PI / 100;
    for (int i = 0; i< 101; i++) {
        CGFloat startAngel = (-M_PI + perAngle * i);
        CGFloat endAngel   = startAngel + perAngle / 5;
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:aCenterPoint
                                                                radius:kRadius
                                                            startAngle:startAngel
                                                              endAngle:endAngel
                                                             clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        if (i % 10 == 0) {
            perLayer.strokeColor = UIColorFromHex(0x3F51B5).CGColor;
            perLayer.lineWidth   = 10.f;

            /* 添加刻度值，目前这里加会导致写死，暂时不添加
            [self addCalculateTextPositonWithArcCenter:aCenterPoint Angle:endAngel
                                                radius:kRadius - 15
                                                  text:[NSString stringWithFormat:@"%d",i]];
             */
  
        }else{
            perLayer.strokeColor = [UIColor colorWithRed:0.22 green:0.66 blue:0.87 alpha:1.0].CGColor;
            perLayer.lineWidth   = 5;
        }
        perLayer.path = tickPath.CGPath;
        [self.layer addSublayer:perLayer];
    }
}

- (KFMonitorInstrumentPin *)pinView {
    if (!_pinView) {
        CGRect frame = CGRectMake((self.frame.size.width - kPinLong * 2) / 2  , self.frame.size.height / 2 - 5, kPinLong * 2, 12);
        _pinView = [[KFMonitorInstrumentPin alloc] initWithFrame:frame];
    }
    
    return _pinView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [_textLabel setTextColor:UIColorFromHex(0x3F51B5)];
        [_textLabel setBackgroundColor:UIColor.clearColor];
    }
    return _textLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setTextColor:UIColorFromHex(0x3F51B5)];
        [_detailLabel setBackgroundColor:UIColor.clearColor];
    }
    
    return _detailLabel;
}

@end
