//
//  EMChatHeaderTagView.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/3.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatHeaderTagView.h"
#import "AddTagViewController.h"
#import "EMTagView.h"
#import "UILabel+Category.h"

#define kChatHeaderTagViewHeight 60.f
#define kChatHeaderTagViewSpace 5.f
#define kChatHeaderLabelHeight 20.f

@interface EMChatHeaderTagView ()<TagNodeDelegate>
{
    NSString *_serviceSessionId;
    NSString *_comment;
    BOOL _edit;
    
    NSString *_ipInfoStr;
    NSString *_noteInfoStr;
}

@property (nonatomic, strong) NSMutableDictionary *tree;
@property (nonatomic, strong) NSMutableArray *tagViews;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *unfoldButton;
@property (nonatomic, assign) BOOL unfold;

@end

@implementation EMChatHeaderTagView
{
    HDConversationManager *_conversation;
}
- (instancetype)initWithSessionId:(NSString*)serviceSessionId edit:(BOOL)edit
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, KScreenWidth, kChatHeaderTagViewHeight);
        self.backgroundColor = [UIColor whiteColor];
        _serviceSessionId = serviceSessionId;
        _conversation = [[HDConversationManager alloc] initWithSessionId:_serviceSessionId];
        _tagViews = [NSMutableArray array];
        _unfold = !edit;
        _edit = edit;
        [self loadData];
    }
    return self;
}

- (UIButton*)unfoldButton
{
    if (_unfoldButton == nil) {
        _unfoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unfoldButton setImage:[UIImage imageNamed:@"info_expand_icon_push"] forState:UIControlStateNormal];
        [_unfoldButton setImage:[UIImage imageNamed:@"info_expand_icon_pull"] forState:UIControlStateSelected];
        _unfoldButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        _unfoldButton.frame = CGRectMake(KScreenWidth - 30.f - kChatHeaderTagViewSpace, 0, 30.f, kChatHeaderLabelHeight);
        [_unfoldButton addTarget:self action:@selector(unfoldButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unfoldButton;
}

- (UILabel*)countLabel
{
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.textColor = [UIColor blackColor];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.frame = CGRectMake(self.width - 30.f - kChatHeaderTagViewSpace, kChatHeaderTagViewSpace, 30.f, kChatHeaderLabelHeight);
    }
    return _countLabel;
}

- (UILabel*)commentLabel
{
    if (_commentLabel == nil) {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentLabel.font = [UIFont systemFontOfSize:15];
        _commentLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}

- (void)setupView
{
    [self removeAllSubviews];
    [_tagViews removeAllObjects];
    self.height = kChatHeaderTagViewHeight;
    for (TagNode *node in self.dataSource) {
        TagNode *rootNode = [self _getTopParentTree:node.parentId];
        if (rootNode == nil) {
            EMTagView *tagView = [[EMTagView alloc] initWithRootNode:node childNode:nil edit:_edit];
            tagView.delegate = self;
            [_tagViews addObject:tagView];
        } else {
            EMTagView *tagView = [[EMTagView alloc] initWithRootNode:rootNode childNode:node edit:_edit];
            tagView.delegate = self;
            [_tagViews addObject:tagView];
        }
    }
    
    CGFloat left = 0.f;
    CGFloat top = kChatHeaderTagViewSpace;
    CGFloat lastHeight = 0;
    if ([_tagViews count] > 0) {
        BOOL more = NO;
        for (EMTagView *tagView in _tagViews) {
            left +=kChatHeaderTagViewSpace;
            if (left + tagView.width + 30 >= KScreenWidth) {
                top += tagView.height + kChatHeaderTagViewSpace;
                self.height += tagView.height + kChatHeaderTagViewSpace;
                left = kChatHeaderTagViewSpace;
            }
            tagView.left = left;
            tagView.top = top;
            [self addSubview:tagView];
            left += tagView.width;
            lastHeight = tagView.height;
        }
        
        if (more) {
            [self addSubview:self.countLabel];
            self.countLabel.text = [NSString stringWithFormat:@"(%@)",@((int)[_tagViews count])];
        }
        
        self.height = top + lastHeight;
    } else {
        self.height = 30.f;
    }
    
    if (!_edit) {
        _commentLabel.top = self.height + kChatHeaderTagViewSpace;
        [self addSubview:self.commentLabel];
        self.height += self.commentLabel.height;
    }
}

#pragma mark - public

- (void)refreshHeaderView
{
    if (_edit) {
        [self setupView];
    } else {
        WEAK_SELF
        [_conversation asyncGetSessionSummaryResultsCompletion:^(id responseObject, HDError *error) {
            if (!error) {
                NSArray *json = responseObject;
                weakSelf.dataSource = [NSMutableArray array];
                for (NSString *string in json) {
                    NSString *key = [NSString stringWithFormat:@"%@",string];
                    if ([weakSelf.tree objectForKey:key]) {
                        [weakSelf.dataSource addObject:[weakSelf.tree objectForKey:key]];
                    }
                }
            }
            [weakSelf _loadComment];
        }];
    }
}

- (void)setTagDatasource:(NSArray *)datasource
{
    self.dataSource = [NSMutableArray arrayWithArray:datasource];
    [self setupView];
}

#pragma mark - action

- (void)unfoldButtonAction
{
    _unfold = !_unfold;
    _unfoldButton.selected = !_unfoldButton.selected;
    [self setupView];
}

#pragma mark - private

- (void)loadData
{
    if (_tree == nil) {
        _tree = [NSMutableDictionary dictionary];
    } else {
        [_tree removeAllObjects];
    }
    
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSData *jsonData = [ud objectForKey:USERDEFAULTS_DEVICE_TREE];
    if (jsonData == nil) {
        return;
    }
    NSArray *json = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    if (json) {
        [self _analyzeTree:json];
    } else {
        
    }
    [self refreshHeaderView];
}

- (void)_loadComment
{
    WEAK_SELF
    [_conversation asyncFetchCustomerInfo:^(HCustomerLocalModel *model, HDError *error) {
        
        if (!error && model) {
            _ipInfoStr = [NSString stringWithFormat:@"ip:%@ \n 地区:%@\n 系统:%@",model.ip, model.region, model.userAgent];
        }else {
            _ipInfoStr = @"";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.commentLabel.text = [NSString stringWithFormat:@"备注:%@\n%@", _noteInfoStr,_ipInfoStr];
            
            CGFloat height = [weakSelf.commentLabel getSpaceLabelHeight:weakSelf.commentLabel.text
                                                               withFont:weakSelf.commentLabel.font
                                                              withWidth:self.superview.frame.size.width
                                                        spaceLineHeight:3];
            

            
            weakSelf.commentLabel.frame = CGRectMake(0, 0, self.superview.frame.size.width, height);
            [weakSelf setupView];
        });
    }];
    
    
    [_conversation asyncGetSessionCommentCompletion:^(id responseObject, HDError *error) {
        if (!error) {
            NSDictionary *json = responseObject;
            if (json != nil) {
                _noteInfoStr = [json objectForKey:@"comment"] ?: @"";
            } else {
                _noteInfoStr = @"";
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.commentLabel.text = [NSString stringWithFormat:@"备注:%@\n%@", _noteInfoStr,_ipInfoStr];
            
            CGFloat height = [weakSelf.commentLabel getSpaceLabelHeight:weakSelf.commentLabel.text
                                                               withFont:weakSelf.commentLabel.font
                                                              withWidth:self.superview.frame.size.width
                                                        spaceLineHeight:3];
            
            
            
            weakSelf.commentLabel.frame = CGRectMake(0, 0, self.superview.frame.size.width, height);
            [weakSelf setupView];
        });
    }];
}

- (void)_analyzeTree:(NSArray*)array
{
    if (![array isKindOfClass:[NSArray class]]|| array == nil || [array count] == 0){
        return;
    }
    for (NSDictionary *dic in array) {
        TagNode *node = [[TagNode alloc] initWithDictionary:dic];
        [_tree setObject:node forKey:node.Id];
        if ([dic objectForKey:@"children"]) {
            [self _analyzeTree:[dic objectForKey:@"children"]];
        }
    }
}

- (TagNode*)_getTopParentTree:(NSString*)parentId
{
    if ([_tree objectForKey:parentId]) {
        TagNode *node = [_tree objectForKey:parentId];
        if ([node.parentId isEqualToString:@"0"]) {
            return node;
        } else {
            TagNode *temp = [self _getTopParentTree:node.parentId];
            return temp;
        }
    }
    return nil;
}

#pragma mark - TagNodeDelegate

- (void)deleteWithTagNode:(TagNode *)tagNode
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteTagNode:)]) {
        [self.delegate deleteTagNode:tagNode];
    }
}

@end
