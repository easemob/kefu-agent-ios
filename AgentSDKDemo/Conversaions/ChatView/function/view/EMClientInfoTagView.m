//
//  EMClientInfoTagView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/17.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMClientInfoTagView.h"
#define kEMClientViewDefaultHeight 36.f
#define kEMClientViewDefaultFont 17.f

@interface EMClientInfoTagView ()
{
    HDUserTag *_model;
    NSString *_visitorUserId;
}

@property (nonatomic, strong) UIButton *tagButton;

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation EMClientInfoTagView

- (instancetype)initWithUserTagModel:(HDUserTag*)model visitorUserId:(NSString *)visitorUserId;
{
    self = [super init];
    if (self) {
        _model = model;
        _visitorUserId = visitorUserId;
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.f;
        CGSize size = [self makeLabelSize:model.tagName];
        if (size.width > KScreenWidth - 20) {
            size.width = KScreenWidth - 20;
        }
        [self setFrame:CGRectMake(0, 0, size.width, kEMClientViewDefaultHeight)];
        [self addSubview:self.tagButton];
    }
    return self;
}

- (UIButton *)tagButton
{
    if (_tagButton == nil ) {
        _tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tagButton setTitle:_model.tagName forState:UIControlStateNormal];
        _tagButton.selected = _model.checked;
        _tagButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_tagButton addTarget:self action:@selector(filterButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        [_tagButton setBackgroundImage:[[UIImage imageNamed:@"button_gray"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateNormal];
//        [_tagButton setBackgroundImage:[[UIImage imageNamed:@"button_blue"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateSelected];
//        [_tagButton setBackgroundImage:[[UIImage imageNamed:@"button_blue"] stretchableImageWithLeftCapWidth:10 topCapHeight:5] forState:UIControlStateHighlighted];
        [_tagButton setBackgroundColor:[UIColor clearColor]];
        _tagButton.frame = CGRectMake(13.f, 0, self.width - 13.f, kEMClientViewDefaultHeight);
    }
    return _tagButton;
}

- (NSMutableArray*)points
{
    if (_points == nil) {
        _points = [NSMutableArray array];
        
        CGPoint one = CGPointMake(0, kEMClientViewDefaultHeight/2);
        NSValue *value = nil;
        value = [NSValue valueWithBytes:&one objCType:@encode(CGPoint)];
        [_points addObject:value];
        
        CGPoint two = CGPointMake(13.f, 0);
        value = [NSValue valueWithBytes:&two objCType:@encode(CGPoint)];
        [_points addObject:value];
        
        CGPoint three = CGPointMake(self.width, 0);
        value = [NSValue valueWithBytes:&three objCType:@encode(CGPoint)];
        [_points addObject:value];
        
        CGPoint four = CGPointMake(self.width, kEMClientViewDefaultHeight);
        value = [NSValue valueWithBytes:&four objCType:@encode(CGPoint)];
        [_points addObject:value];
        
        CGPoint five = CGPointMake(13.f, kEMClientViewDefaultHeight);
        value = [NSValue valueWithBytes:&five objCType:@encode(CGPoint)];
        [_points addObject:value];
        
        CGPoint six = CGPointMake(0, kEMClientViewDefaultHeight/2);
        value = [NSValue valueWithBytes:&six objCType:@encode(CGPoint)];
        [_points addObject:value];
        
    }
    return _points;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.tagButton.selected) {
        CGContextSetStrokeColorWithColor(context, RGBACOLOR(41, 169, 234, 1).CGColor);
        CGContextSetFillColorWithColor(context, RGBACOLOR(41, 169, 234, 1).CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, RGBACOLOR(230, 234, 242, 1).CGColor);
        CGContextSetFillColorWithColor(context, RGBACOLOR(230, 234, 242, 1).CGColor);
    }
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.0);
    
    for(int idx = 0; idx < self.points.count; idx++) {
        CGPoint point;
        [[self.points objectAtIndex:idx] getValue:&point];//Edited
        if(idx == 0) {
            // move to the first point
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }
    CGContextFillPath(context);
    CGContextStrokePath(context);
}

- (CGSize)makeLabelSize:(NSString *)text
{
    CGSize textBlockMinSize = {CGFLOAT_MAX, kEMClientViewDefaultHeight};
    CGSize retSize;
    retSize = [text boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{
                                           NSFontAttributeName:[UIFont systemFontOfSize:kEMClientViewDefaultFont],
                                           }
                                 context:nil].size;
    retSize.width += 26.f;
    return retSize;
}

#pragma mark - Action

- (void)filterButtonAction
{
    _model.checked = !_model.checked;
    WEAK_SELF
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"修改标签" toView:nil];
    __weak MBProgressHUD *weakHud = hud;
    [[HDClient sharedClient].setManager updateVisitorUserTagWithUserTag:_model completion:^(id responseObject, HDError *error) {
        if (error == nil) {
            weakSelf.tagButton.selected = !weakSelf.tagButton.selected;
            [weakSelf setNeedsDisplay];
//            [weakHud setLabelText:@"修改用户标签成功"];
            weakHud.label.text =@"修改用户标签成功";
            [weakHud hideAnimated:YES afterDelay:0.5];
        } else {
            NSLog(@"error:%@",error);
            weakHud.label.text =@"修改用户标签失败";
//            [weakHud setLabelText:@"修改用户标签失败"];
        }
    }];

}

@end
