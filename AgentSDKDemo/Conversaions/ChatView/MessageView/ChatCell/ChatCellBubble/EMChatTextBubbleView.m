/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <CoreText/CoreText.h>
#import "EMChatTextBubbleView.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "EmotionEscape.h"
#import "NSString+Escape.h"

#define kHref @"href"

NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";

@interface EMChatTextBubbleView ()
{
    NSDataDetector *_detector;
    NSArray *_urlMatches;
}

@end

@implementation EMChatTextBubbleView
{
    HDTextMessageBody *_body;
    HDMessage *_model;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.lineBreakMode = [[self class] textLabelLineBreakModel];
        _textLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.textColor = RGBACOLOR(0x09, 0x09, 0x09, 1);
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.multipleTouchEnabled = NO;
        [self addSubview:_textLabel];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
//    CGRect frame = self.bounds;
//    frame.size.width -= BUBBLE_ARROW_WIDTH;
//    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
//    if (self.model.isSender) {
//        frame.origin.x = BUBBLE_VIEW_PADDING;
//    }else{
//        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
//    }
//    frame.origin.y = BUBBLE_VIEW_PADDING;
//    [self.textLabel setFrame:frame];
    
    CGRect frame = self.frame;
        if (self.model.isSender) {
            frame.origin.x = BUBBLE_VIEW_PADDING;
        }else{
            frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
        }
    frame.origin.y = BUBBLE_VIEW_PADDING;
    frame.size.width = self.model.textSize.width;
    frame.size.height = self.model.textSize.height + 10;
    self.textLabel.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(_model.textSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, _model.textSize.height + 2 * BUBBLE_VIEW_PADDING);
}

#pragma mark - setter

- (void)setModel:(HDMessage *)model
{
    [super setModel:model];
    _model = model;
    _body = (HDTextMessageBody *)model.nBody;
    NSAttributedString *attributedString = model.att;
    [_textLabel setAttributedText:attributedString];
    __weak __typeof(self) weakSelf = self;
    _textLabel.tag = 1990;
    _textLabel.highlightTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YYLabel *label = (YYLabel *)containerView;
        [weakSelf yyLabelLinkDidClicked:label range:range];
    };
}



- (void)yyLabelLinkDidClicked:(YYLabel *)yyLabel range:(NSRange)range {
    NSAttributedString *text = yyLabel.textLayout.text;
    YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location longestEffectiveRange:nil inRange:range];
    NSDictionary *userInfo = highlight.userInfo;
    NSURL *url = [userInfo objectForKey:@"url"];
    [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{KMESSAGEKEY:self.model, @"url":[url absoluteString]}];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return NO;
}

#pragma mark - public

+ (NSAttributedString *)getAttributedString:(HDMessage *)message {
    NSMutableAttributedString *attributedString = nil;
    NSString *text = ((HDTextMessageBody *)message.nBody).text;
    if ([text containsString:kHref]) { //包含特殊链接
        text = [NSString htmlToString:text];
        attributedString = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        if (message.isSender) {
            [attributedString yy_setColor:[UIColor whiteColor] range:NSMakeRange(0, attributedString.length)];
        } else {
            [attributedString yy_setColor:[UIColor blackColor] range:NSMakeRange(0, attributedString.length)];
        }
        [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            if ([attrs objectForKey:@"NSLink"]) {
                YYTextHighlight *highlight = [YYTextHighlight new];
                YYTextBorder *highlightBorder = [YYTextBorder new];
                highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
                highlightBorder.cornerRadius = 2;
                highlightBorder.fillColor = [UIColor lightGrayColor];
                [highlight setBackgroundBorder:highlightBorder];
                [highlight setUserInfo:@{@"url":[attrs objectForKey:@"NSLink"]}];
                [attributedString yy_setTextHighlight:highlight range:range];
                [attributedString yy_setColor:[UIColor blueColor] range:range];
                YYTextDecoration *under = [YYTextDecoration new];
                under.color = [UIColor redColor];
                [attributedString yy_setTextUnderline:under range:range];
            }
        }];
    } else {
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        if (message.isSender) {
            [attributedString yy_setColor:[UIColor whiteColor] range:NSMakeRange(0, attributedString.length)];
        } else {
            [attributedString yy_setColor:[UIColor blackColor] range:NSMakeRange(0, attributedString.length)];
        }
    }
    NSDataDetector * detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:0
                                           range:NSMakeRange(0, [attributedString.string length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSRange range = [match range];
            YYTextHighlight *highlight = [YYTextHighlight new];
            YYTextBorder *highlightBorder = [YYTextBorder new];
            highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
            highlightBorder.cornerRadius = 3;
            highlightBorder.fillColor = [UIColor lightGrayColor];
            [highlight setBackgroundBorder:highlightBorder];
            [highlight setUserInfo:@{@"url":[match URL]}];
            [attributedString yy_setTextHighlight:highlight range:range];
            [attributedString yy_setColor:[UIColor blueColor] range:range];
            YYTextDecoration *under = [YYTextDecoration new];
            under.color = [UIColor blueColor];
            [attributedString yy_setTextUnderline:under range:range];
        }
    }
    
    [[EmotionEscape sharedInstance] yyEmotionStringFromString:attributedString fontSize:LABEL_FONT_SIZE];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[[self class] lineSpacing]];//调整行间距
    [attributedString addAttribute:NSFontAttributeName
                             value:[EMChatTextBubbleView textLabelFont]
                             range:NSMakeRange(0, attributedString.length)];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}

+ (CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    return 2 * BUBBLE_VIEW_PADDING + object.textSize.height;
}

+ (CGSize)textSize:(HDMessage *)message { //只有文字消息
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[[self class] lineSpacing]];//调整行间距
    NSAttributedString *att = message.att;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:[[self class]textBlockMinSize ] text:att];
    return layout.textBoundingSize;
}

+ (CGSize)textBlockMinSize {
     return CGSizeMake(TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX);
}

+(UIFont *)textLabelFont
{
    return [UIFont systemFontOfSize:LABEL_FONT_SIZE];
}

+(CGFloat)lineSpacing{
    return LABEL_LINESPACE;
}

+(NSLineBreakMode)textLabelLineBreakModel
{
    return NSLineBreakByCharWrapping;
}


@end
