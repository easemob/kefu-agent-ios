//
//  KFChatSmartView.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/18.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFChatSmartView.h"
#import "KFMSGTypeModel.h"
#import "KFSmartModel.h"
#import "KFSmartUtils.h"
#import "KFSmartDefaultTableViewCell.h"
#import "KFSmartImageTableViewCell.h"
#import "KFSmartChoiceTableViewCell.h"



NSString *const kRouterEventCopyTextTapEventName = @"kRouterEventCopyTextTapEventName";
NSString *const kRouterEventSendMessageTapEventName = @"kRouterEventSendMessageTapEventName";
NSString *const kSearchDatakeyBoardHiddenTapEventName = @"kSearchDatakeyBoardHiddenTapEventName";

@interface KFChatSmartView()
{
    HDSmartExtMsgType _msgtype;
    
    NSArray *_articleArray;
}
@property (nonatomic,strong) UILabel *knowledgeLabel;
@property (nonatomic,strong) UILabel *copyLabel;
@property (nonatomic,strong) UILabel *copyLabelNum;
@property (nonatomic,strong) UILabel *sendLabel;
@property (nonatomic,strong) UILabel *sendLabelNum;
@property (nonatomic,strong) UIView * notDataView;
@property (nonatomic,strong) UIView * searchView;
@end
@implementation KFChatSmartView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
    }
    return self;
}
- (void)createUI{

    if (@available(iOS 13.0, *)) {
           self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
     } else {
           // Fallback on earlier versions
     }
    
    
    [self addSubview: self.searchView];
    [self addSubview: self.tableView];
    [self addSubview: self.notDataView];
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}
- (UIView *)searchView{
    if (!_searchView) {
        _searchView = [[UIView alloc ]init];
//        _searchView.backgroundColor = [UIColor redColor];
        [_searchView addSubview:self.searchBar];
        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(25);
            make.leading.offset(20);
            make.trailing.offset(-20);
            make.bottom.offset(-5);
        }];
        [_searchView addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(0);
            make.trailing.offset(-8);
            make.height.width.offset(32);
        }];
    }
    return _searchView;
}
-(void)layoutSubviews{

    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(5);
        make.leading.offset(0);
        make.trailing.offset(0);
        make.height.offset(70);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(70);
        make.leading.offset(20);
        make.trailing.offset(-20);
        make.bottom.offset(0);
    }];

  
        [self.notDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(70);
            make.leading.offset(20);
            make.trailing.offset(-20);
            make.bottom.offset(0);
        }];


}
- (void)_setupBubbleConstraints
{
//    [self.fileIconView hdmas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.backgroundImageView.mas_top).offset(self.margin.top);
//        make.bottom.equalTo(self.backgroundImageView.mas_bottom).offset(-self.margin.bottom);
//        make.left.equalTo(self.backgroundImageView.mas_left).offset(self.margin.left);
//        make.height.equalTo(self.fileIconView.mas_width).offset(0);
//    }];
//
//    [self.fileNameLabel hdmas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.backgroundImageView.mas_top).offset(self.margin.top);
//        make.right.equalTo(self.backgroundImageView.mas_right).offset(-self.margin.right);
//        make.left.equalTo(self.fileIconView.mas_right).offset(HDMessageCellPadding);
//    }];
//
//    [self.fileSizeLabel hdmas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.fileNameLabel.mas_left).offset(0);
//        make.right.equalTo(self.fileNameLabel.mas_right).offset(0);
//        make.top.equalTo(self.fileNameLabel.mas_bottom).offset(0);
//        make.bottom.equalTo(self.backgroundImageView.mas_bottom).offset(-self.margin.bottom);
//    }];
}

- (void)updateFileMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    [self _setupBubbleConstraints];
}

- (void)setModel:(HDMessage *)model{
    
    [super setModel:model];
    _model = model;
    _body = (HDTextMessageBody *)model.nBody;
    self.searchBar.text = _body.text;
    [self endEditing:YES];
    //调用搜索接口
    [self kf_searchQuestion:_body.text];

}
- (void)kf_searchQuestion:(NSString *)question{
    
    
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self];
    __weak MBProgressHUD *weakHud = hud;
    
    [[HDClient sharedClient].setManager kf_searchAnswerWithQuestion:question withSessionId:[NSString stringWithFormat:@"%ld",(long)_model.conversationId] withMsgId:_model.messageId completion:^(id responseObject, HDError *error) {
        [weakHud hide:YES];
//        {"status":"OK","entities":[],"first":false,"last":true,"size":2,"number":1,"numberOfElements":0,"totalPages":0,"totalElements":0}
        NSLog(@"======%@",responseObject);
        WEAK_SELF
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary * dic = responseObject;
            
            if ([[dic allKeys] containsObject:@"status"] && [[dic valueForKey:@"status"]isEqualToString:@"OK"]) {
                if ([[dic allKeys] containsObject:@"entities"]) {
                    NSArray * array = [dic valueForKey:@"entities"];
                    
                    if (array.count > 0) {
                        [weakSelf.dataArray removeAllObjects];
                        self.notDataView.hidden = YES;
                        
                        //加载数据
                        NSArray * resArray = [NSArray yy_modelArrayWithClass:[KFSmartModel class] json:[dic valueForKey:@"entities"]];
                        
                        for (KFSmartModel * model in resArray) {
                           
                            NSLog(@"==%@",model.ext);
                            
                            if ([KFSmartUtils isGroupMessageStr:model.type]) {
                                
                                if (model.answerDataGroup) {
                                    
                                    NSArray * groupArray = [NSArray yy_modelArrayWithClass:[KFSmartModel class] json:model.answerDataGroup];
                                    [weakSelf.dataArray addObjectsFromArray:groupArray];
                                    
                                }
                                
                            }else{
                           
                                [weakSelf.dataArray addObject:model];
                            }
                        
                        }
        
                    }else{
                        
                        //没有数据
                        self.notDataView.hidden = NO;
                        
                
                    }
                    
                }
                
            }
            
            [self.tableView reloadData];
            [self endEditing:YES];
        }
        
    }];
    
    
}

#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
 
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
    KFSmartModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    if (model.msgtype == HDSmartExtMsgTypearticle) {

        _msgtype = HDSmartExtMsgTypearticle;;
        KFSmartArticleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFSmartArticleTableViewCell"];
           if(!cell){
           cell =[[KFSmartArticleTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"KFSmartArticleTableViewCell"];
           }
        cell.delegate = self;
        
        if (_articleArray.count >0) {



        }else{
            
            [cell setModel:model];
            
        }
        
        
        return cell;
        
    }else if(model.msgtype ==HDSmartExtMsgTypeText){
        
        _msgtype = HDSmartExtMsgTypeText;
        KFSmartDefaultTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFSmartDefaultTableViewCell"];
           if(!cell){
           cell =[[KFSmartDefaultTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"KFSmartDefaultTableViewCell"];
           }
        
        
        [cell setModel:model];
        cell.clickDefaultCopyItemBlock = ^(KFSmartModel * _Nonnull model, id  _Nonnull cell) {
            
            [self labelCopyClick:model];
            
        };
        cell.clickDefaultSendItemBlock = ^(KFSmartModel * _Nonnull model, id  _Nonnull cell) {
            
            [self labelSendClick:model];
        };
        
        return cell;
    }else if(model.msgtype == HDSmartExtMsgTypeMenu){
        _msgtype = HDSmartExtMsgTypeMenu;
        KFSmartChoiceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFSmartChoiceTableViewCell"];
           if(!cell){
           cell =[[KFSmartChoiceTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"KFSmartChoiceTableViewCell"];
           }
        [cell setModel:model];
     
        cell.clickChoiceItemBlock = ^(KFSmartModel * _Nonnull model, id  _Nonnull cell) {
            
            [self labelSendClick:model];
        };
        
        return cell;
        
    }else if(model.msgtype == HDSmartExtMsgTypeImamge){
        _msgtype = HDSmartExtMsgTypeImamge;
        KFSmartImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KFSmartImageTableViewCell"];
           if(!cell){
           cell =[[KFSmartImageTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"KFSmartImageTableViewCell"];
           }
        [cell setModel:model];
     
        cell.clickImageItemBlock = ^(KFSmartModel * _Nonnull model, UIImage * _Nonnull image) {
            
            [self labelSendClick:model];
            
        };
        
        return cell;
        
    }else{
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
           if(!cell){
           cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:@"id"];
           }
        return cell;
    }
    return nil;
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@"====%@",searchBar.text);
    _articleArray  = nil;
    [self kf_searchQuestion:searchBar.text];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//此协议方法中header不受约束影响，不用设置固定高度也不会出问题
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    return  self.searchBar;
//
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//
//    return  self.footerView;
//}

- (void)didChangeCell:(NSArray *)items{
    
    _articleArray = [NSArray arrayWithArray:items];
    
    [self.tableView reloadData];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KFSmartModel *model = [self.dataArray objectAtIndex:indexPath.row];

    CGFloat height;
    switch (model.msgtype) {
        case HDSmartExtMsgTypearticle:
            height = [self kf_smartArticleTableViewCellHeight];
            
            break;
        case HDSmartExtMsgTypeText:
            
            height = model.cellHeight > 0 ? model.cellHeight : 100;
            break;
        case HDSmartExtMsgTypeMenu:
            
            height = model.cellHeight > 0 ? model.cellHeight : 200;
            break;
        case HDSmartExtMsgTypeImamge:
            
            height = 100;
            break;
            
        default:
            height = 66;
            break;
    }
    
    
  
    
    return height;
}

- (CGFloat)kf_smartArticleTableViewCellHeight{
    
    CGFloat height = 0;
    for (KFMSGTypeModel *model in _articleArray) {
        
        height = height + model.cellHeight;
    }
    
    if (height > 200) {
        return height;
    }
    
    return 215;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//
//    return 44;
//
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//
//    return 44;
//}
- (void)reloadData {
    [_tableView reloadData];
}

- (void)close:(UIButton *)sender{
    
    [self removeFromSuperview];
    

 
}
-(void)labelCopyClick {
    
    if (self.dataArray.count >0) {
    
        KFMSGTypeModel * model = [self.dataArray firstObject];
        
        [self routerEventWithName:kRouterEventCopyTextTapEventName
                         userInfo:@{@"smartText":model.title}];
    }
    
}

-(void)labelCopyClick:(KFSmartModel *)model{
    
    
//    [self routerEventWithName:kRouterEventCopyTextTapEventName
//                     userInfo:@{@"smartText":model.answer}];
    
    [self routerEventWithName:kRouterEventCopyTextTapEventName
                     userInfo:@{@"smartModel":model}];
    
    
}
-(void)labelSendClick:(KFSmartModel *)model{
    
    
    if (model) {
       
        
        [self routerEventWithName:kRouterEventSendMessageTapEventName
                         userInfo:@{@"smartModel":model}];
    }
   
    
    [self close:nil];
}


//-(void)labelSendClick:(HDSmartExtMsgType *)model {
//    NSLog(@"==labelSendClick==");
//
//
//    if (self.dataArray.count >0) {
//
//        KFMSGTypeModel * model = [self.dataArray firstObject];
//
//        if (_msgtype == HDSmartExtMsgTypeMenu) {
//
//
//            NSString *title = @"";
//            NSString *headStr = @"";
//            for (int i = 0; i<model.itemModel.dataArray.count; i++) {
//                NSString * str = model.itemModel.dataArray[i];
//
//                if (i == 0) {
//                    headStr = str;
//                }else{
//                    if (str.length >0) {
//
//                        title = [NSString stringWithFormat:@"%@\n%d %@",title, i ,str];
//
//                    }else{
//
//                        title = [NSString stringWithFormat:@"%@%@",title,str];
//
//                    }
//
//                }
//
//
//
//            }
//
//
//            model.title = [NSString stringWithFormat:@"%@%@",headStr,title];
//
//        }
//        [self routerEventWithName:kRouterEventSendMessageTapEventName
//                         userInfo:@{@"smartModel":model}];
//    }
//
//
//
//}
- (UITableView *)tableView{
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;;
        _tableView.allowsSelection = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;        
        [_tableView registerNib:[UINib nibWithNibName:@"KFSmartDefaultTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartDefaultTableViewCell"];
        
        [_tableView registerNib:[UINib nibWithNibName:@"KFSmartImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartImageTableViewCell"];
        
        [_tableView registerNib:[UINib nibWithNibName:@"KFSmartChoiceTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartChoiceTableViewCell"];
        
        [_tableView registerNib:[UINib nibWithNibName:@"KFSmartArticleTableViewCell" bundle:nil] forCellReuseIdentifier:@"KFSmartArticleTableViewCell"];
       
    }
    return _tableView;
}
- (UIView *)notDataView{
    
    if (!_notDataView) {
        _notDataView = [[UIView alloc] init];
        _notDataView .backgroundColor = [UIColor whiteColor];
//        _notDataView.hidden = YES;
        UILabel *label = [[UILabel alloc]init];
        label.text = @"暂无数据";
        [_notDataView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.mas_equalTo(_notDataView.mas_centerX).offset(0);
            make.centerY.mas_equalTo(_notDataView.mas_centerY).offset(0);
            
        }];
        
    }
    return _notDataView;
}


- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
//        _searchBar.backgroundColor = [UIColor yellowColor];
        _searchBar.delegate = self;
        [_searchBar setSearchBarStyle:UISearchBarStyleMinimal];
        _searchBar.placeholder = @"请输入...";
        UITextField *searTextField;
        if (@available(iOS 13.0, *)) {
            searTextField =_searchBar.searchTextField;
        } else {
            // Fallback on earlier versions
            searTextField =[_searchBar valueForKey:@"_searchField"];
        }
        searTextField.font = [UIFont systemFontOfSize:14];
        searTextField.layer.cornerRadius = 22;
        searTextField.layer.masksToBounds = YES;
       
    }
    
    return _searchBar;
}
- (UIButton *)closeBtn{
    
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"icon_close_select"] forState:UIControlStateNormal];
        
        [_closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
- (UILabel *)sendLabel{
    
    if (!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.text = @"发送";
        _sendLabel.font = [UIFont systemFontOfSize:18];
        _sendLabel.textColor = [UIColor colorWithRed:75/255.0 green:131/255.0 blue:235/255.0 alpha:1];
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSendClick)];

        [_sendLabel addGestureRecognizer:labelTapGestureRecognizer];

        _sendLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击//
    }
    return _sendLabel;
}
- (UILabel *)sendLabelNum{
    
    if (!_sendLabelNum) {
        _sendLabelNum = [[UILabel alloc] init];
        _sendLabelNum.text = @"0";
        _sendLabelNum.font = [UIFont systemFontOfSize:18];
       
    }
    return _sendLabelNum;
}
- (UILabel *)copyLabel{
    
    if (!_copyLabel) {
        _copyLabel = [[UILabel alloc] init];
        _copyLabel.text = @"引用";
        _copyLabel.font = [UIFont systemFontOfSize:18];
        _copyLabel.textColor = [UIColor colorWithRed:75/255.0 green:131/255.0 blue:235/255.0 alpha:1];
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelCopyClick)];

        [_copyLabel addGestureRecognizer:labelTapGestureRecognizer];

        _copyLabel.userInteractionEnabled = YES; // 可以理解为设置label可被点击//

    }
    return _copyLabel;
}
- (UILabel *)copyLabelNum{
    
    if (!_copyLabelNum) {
        _copyLabelNum = [[UILabel alloc] init];
        _copyLabelNum.text = @"0";
        _copyLabelNum.font = [UIFont systemFontOfSize:18];
    }
    return _copyLabelNum;
}
- (UILabel *)knowledgeLabel{
    
    if (!_knowledgeLabel) {
        _knowledgeLabel = [[UILabel alloc] init];
        _knowledgeLabel.text = @"知识库";
        _knowledgeLabel.font = [UIFont systemFontOfSize:16];
        _knowledgeLabel.textAlignment = NSTextAlignmentCenter;
//        _knowledgeLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _knowledgeLabel.backgroundColor = [UIColor colorWithRed:168/255.0 green:178/255.0 blue:185/255.0 alpha:0.8];
        _knowledgeLabel.layer.cornerRadius = 5;
        _knowledgeLabel.layer.masksToBounds = YES;
        _knowledgeLabel.textColor = [UIColor whiteColor];
       
    }
    return _knowledgeLabel;
}
- (UIView *)footerView{
    
    if (!_footerView) {
        _footerView = [[UIView alloc]init];
        [_footerView addSubview:self.knowledgeLabel];
        [self.knowledgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.leading.offset(20);
            make.width.offset(66);
        }];
       
        [_footerView addSubview:self.sendLabelNum];
        [self.sendLabelNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.offset(-20);
        }];
        [_footerView addSubview:self.sendLabel];
        [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.mas_equalTo(self.sendLabelNum.mas_leading).offset(-5);
        }];
        [_footerView addSubview:self.copyLabelNum];
        [self.copyLabelNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.mas_equalTo(self.sendLabel.mas_leading).offset(-10);
        }];
        [_footerView addSubview:self.copyLabel];
        [self.copyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(10);
            make.bottom.offset(-10);
            make.trailing.mas_equalTo(self.copyLabelNum.mas_leading).offset(-5);
        }];
    }
    
    return _footerView;
    
}


@end
