//
//  KFSmartArticleTableViewCell.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartArticleTableViewCell.h"
#import "KFSmartArticleMoreTableViewCell.h"
@interface KFSmartArticleTableViewCell ()<UITableViewDelegate,UITableViewDataSource> 
{
    
    KFSmartModel *_model;
    
}
@property (strong, nonatomic) NSArray *itemArray;
@end
@implementation KFSmartArticleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.iconImage.image = [UIImage imageNamed:@"tabbar_icon_ongoing"];
    self.labelSend.font  = [UIFont systemFontOfSize:18];
     self.labelSend.textColor = [UIColor colorWithRed:75/255.0 green:131/255.0 blue:235/255.0 alpha:1];
    _knowledgeLabel.font = [UIFont systemFontOfSize:16];
    _knowledgeLabel.textAlignment = NSTextAlignmentCenter;
//        _knowledgeLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _knowledgeLabel.backgroundColor = [UIColor colorWithRed:168/255.0 green:178/255.0 blue:185/255.0 alpha:0.8];
    _knowledgeLabel.layer.cornerRadius = 5;
    _knowledgeLabel.layer.masksToBounds = YES;
    _knowledgeLabel.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *labelTapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSendClick)];

    [self.labelSend addGestureRecognizer:labelTapGestureRecognizer1];

    self.labelSend.userInteractionEnabled = YES; // 可以理解
    
//    self.labelSend.hidden = YES;
//    self.labelSendNum.hidden = YES;
    
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;;
    _tableView.allowsSelection = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"KFSmartArticleMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartArticleMoreTableViewCell"];
   
    
    
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
    
    cell.fTitleLabel.hidden = YES;
    [cell setModel:model];
    
  
   
    cell.clickAtricleModorItemBlock = ^(KFMSGTypeModel * _Nonnull model, id  _Nonnull cell) {
        
        //跳转 url
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url]];

        
    };


    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    KFMSGTypeModel *model = [self.itemArray objectAtIndex:indexPath.row];
    return model.cellHeight > 0 ? model.cellHeight : 198;
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didChangeCell:self.itemArray ];
        });
       
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)labelSendClick{
    
    if (self.clickArticleItemBlock) {
        
        self.clickArticleItemBlock(_model, self);
    }
    
}
- (void)setModel:(KFSmartModel *)model{
    
    _model = model;
    
    NSArray * articles = [NSArray yy_modelArrayWithClass:[KFMSGTypeModel class] json:[[model.ext valueForKey:@"msgtype"] valueForKey:@"articles"]];
    
                                
    self.itemArray = articles;
    
    if (self.itemArray.count > 1) {
        
        self.tableView.scrollEnabled = YES;
    }else{
        
        self.tableView.scrollEnabled = NO;
        
    }
    [self.tableView reloadData];
    
    self.labelCopyNum.text =  [NSString stringWithFormat:@"%ld",model.quoteFrequencyStr] ;
    self.labelSendNum.text = [NSString stringWithFormat:@"%ld",model.sendFrequencyStr] ;
    if ([model.cooperationSource isEqualToString:@"knowledge"]) {
        self.knowledgeLabel.text = @"知识库";
    }else{
        self.knowledgeLabel.text =@"";
    }
    
   
}
- (NSArray *)itemArray{
    
    if (!_itemArray) {
        _itemArray = [[NSArray alloc] init];
    }
    
    return _itemArray;
    
}
@end
