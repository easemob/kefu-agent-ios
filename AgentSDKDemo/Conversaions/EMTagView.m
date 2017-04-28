//
//  EMTagView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMTagView.h"

#import "AddTagViewController.h"

#define kDefaultHeight 24.f
#define kDefaultSpace 5.f

#define kTagViewFontSize 14.f

@interface EMTagView ()
{
    TagNode *_rootNode;
    TagNode *_childNode;
    BOOL _edit;
}

@property (nonatomic, strong) UILabel *rootLabel;
@property (nonatomic, strong) UILabel *childLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *pointView;

@end

@implementation EMTagView

- (instancetype)initWithRootNode:(TagNode*)rootNode childNode:(TagNode*)childNode
{
    return [self initWithRootNode:rootNode childNode:childNode edit:NO];
}

- (instancetype)initWithRootNode:(TagNode *)rootNode childNode:(TagNode *)childNode edit:(BOOL)edit
{
    self = [super init];
    if (self) {
        _edit = edit;
        _rootNode = rootNode;
        _childNode = childNode;
        [self setupTagView];
    }
    return self;
}

- (void)setWithRootNode:(TagNode*)rootNode childNode:(TagNode*)childNode
{
    _rootNode = rootNode;
    _childNode = childNode;
    [self setupTagView];
}

- (UIButton*)deleteButton
{
    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, 30, kDefaultHeight);
        [_deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(1.f, 2.f, 0, 0)];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton setTitle:@"X" forState:UIControlStateNormal];
        [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
    }
    return _deleteButton;
}

- (UILabel*)rootLabel
{
    if (_rootLabel == nil) {
        _rootLabel = [[UILabel alloc] init];
        _rootLabel.frame = CGRectMake(kDefaultSpace, 0, 40, kDefaultHeight);
        _rootLabel.textColor = [UIColor whiteColor];
        _rootLabel.font = [UIFont systemFontOfSize:kTagViewFontSize];
        [self addSubview:_rootLabel];
    }
    return _rootLabel;
}

- (UILabel*)childLabel
{
    if (_childLabel == nil) {
        _childLabel = [[UILabel alloc] init];
        _childLabel.frame = CGRectMake(CGRectGetMaxX(_rootLabel.frame) + kDefaultSpace * 2, 0, 40, kDefaultHeight);
        _childLabel.textColor = [UIColor whiteColor];
        _childLabel.font = [UIFont systemFontOfSize:kTagViewFontSize];
        [self addSubview:_childLabel];
    }
    return _childLabel;
}

- (UIView*)pointView
{
    if (_pointView == nil) {
        _pointView = [[UIView alloc] init];
        _pointView.backgroundColor = [UIColor whiteColor];
        _pointView.layer.cornerRadius = 1.f;
        _pointView.width = 2.f;
        _pointView.height = 2.f;
        _pointView.top = (kDefaultHeight - 2.f)/2;
        [self addSubview:_pointView];
    }
    return _pointView;
}

- (void)setupTagView
{
    if (_rootNode != nil && _rootNode.name.length > 0) {
        self.backgroundColor = [_rootNode tagNodeColor];
        
        self.rootLabel.text = _rootNode.name;
        self.rootLabel.width = [self makeLabelSize:_rootNode.name].width;
        
        self.frame = CGRectMake(0, 0, kDefaultSpace + _rootLabel.width + kDefaultSpace, kDefaultHeight);
        
        if (_childNode != nil) {
            self.childLabel.text = _childNode.name;
            self.childLabel.width = [self makeLabelSize:_childNode.name].width;
            
            _childLabel.left = CGRectGetMaxX(_rootLabel.frame) + kDefaultSpace * 2;
            self.pointView.left = _childLabel.left - kDefaultSpace - self.pointView.width/2;
            
            self.frame = CGRectMake(0, 0, kDefaultSpace + _rootLabel.width + kDefaultSpace * 2 + _childLabel.width + kDefaultSpace, kDefaultHeight);
            if (self.width > KScreenWidth*3/4) {
                self.childLabel.width -=self.width - KScreenWidth*3/4;
                self.width = KScreenWidth*3/4;
            }
            
            self.childLabel.hidden = NO;
            self.pointView.hidden = NO;
        } else {
            self.childLabel.hidden = YES;
            self.pointView.hidden = YES;
        }
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
    self.layer.cornerRadius = 4.f;
    self.layer.masksToBounds = YES;
    
    if (_edit) {
        self.width += 30;
        self.deleteButton.left = self.width - 30;
    }
}

- (CGSize)makeLabelSize:(NSString*)text
{
    CGSize textBlockMinSize = {CGFLOAT_MAX, kDefaultHeight};
    CGSize retSize = [text boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{
                                                                  NSFontAttributeName:[UIFont systemFontOfSize:kTagViewFontSize],
                                                                  }
                                                        context:nil].size;
    return retSize;
}

#pragma mark - action

- (void)deleteAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteWithTagNode:)]) {
        if (_childNode) {
            [self.delegate deleteWithTagNode:_childNode];
        } else {
            [self.delegate deleteWithTagNode:_rootNode];
        }
    }
}

@end
