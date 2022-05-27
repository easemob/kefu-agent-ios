//
//  KFChatArticleBubbleView.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/27.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFChatArticleBubbleView.h"
#import "KFSmartArticleMoreTableViewCell.h"
NSString *const kRouterEventArticleBubbleTapEventName = @"kRouterEventArticleBubbleTapEventName";

@interface KFChatArticleBubbleView()<UITableViewDelegate,UITableViewDataSource>
{
    HDMessage *_model;
}
@property (strong, nonatomic) NSArray *itemArray;
@end

@implementation KFChatArticleBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
       
        self.backgroundColor = [UIColor redColor];
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.bottom.offset(0);
        make.leading.offset(0);
        make.trailing.offset(0);
    }];
    
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
}

#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return self.itemArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    KFSmartArticleMoreTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFSmartArticleMoreTableViewCell"];
       if(!cell){
       cell =[[KFSmartArticleMoreTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"KFSmartArticleMoreTableViewCell"];
       }
    KFMSGTypeModel * model = [self.itemArray objectAtIndex:indexPath.row];
    
 
    [cell setModel:model];
    
  
   
    cell.clickAtricleModorItemBlock = ^(KFMSGTypeModel * _Nonnull model, id  _Nonnull cell) {
        
        //跳转 url
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url]];
        [self routerEventWithName:kRouterEventArticleBubbleTapEventName
                         userInfo:@{KMESSAGEKEY:model}];
        
    };
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    KFMSGTypeModel *model = [self.itemArray objectAtIndex:indexPath.row];
    return model.cellHeight>0 ? model.cellHeight : 175;
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate didChangeCell:self.itemArray ];
        });
       
    }
}
- (CGFloat)kf_smartArticleTableViewCellHeight{
    
    CGFloat height = 0;
    for (KFMSGTypeModel *model in self.itemArray) {
        
        height = height + model.cellHeight;
    }
    
    height = height - self.itemArray.count * 44;
   
    if (height > 156) {
        return height;
    }
    
    return 156;
}
-(void)setModel:(HDMessage *)model{
    
    _model = model;
    
    NSArray * articles = [NSArray yy_modelArrayWithClass:[KFMSGTypeModel class] json:[[model.nBody.msgExt valueForKey:@"msgtype"] valueForKey:@"articles"]];
    
                                
    self.itemArray = articles;
    
    if (self.itemArray.count > 1) {
        
        self.tableView.scrollEnabled = YES;
    }else{
        
        self.tableView.scrollEnabled = NO;
        
    }
    [self.tableView reloadData];

}

//view 本身大小
- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize retSize;
    if (self.model.ext) {
        retSize = CGSizeMake(0, 0);
    } else {
        retSize = CGSizeMake(0, 0);
    }
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
  
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH,[self kf_smartArticleTableViewCellHeight]);
   
}
#pragma mark - public


//cell 外层大小
+(CGFloat)heightForBubbleWithObject:(HDMessage *)object
{
    NSArray * articles = [NSArray yy_modelArrayWithClass:[KFMSGTypeModel class] json:[[object.nBody.msgExt valueForKey:@"msgtype"] valueForKey:@"articles"]];
    CGFloat height = 0;
    for (KFMSGTypeModel *model in articles) {
        
        height = height + model.cellHeight;
    }
    
    height = height - articles.count * 44;
   
    if (height > 156) {
        return height;
    }
    
    return 156;
    
    
//    return 2 * BUBBLE_VIEW_PADDING + ANIMATION_IMAGEVIEW_SIZE;
    
}
- (NSArray *)itemArray{
    
    if (!_itemArray) {
        _itemArray = [[NSArray alloc] init];
    }
    
    return _itemArray;
    
}
-(UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;;
        _tableView.allowsSelection = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"KFSmartArticleMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartArticleMoreTableViewCell"];
    }
    return _tableView;
    
}
@end
