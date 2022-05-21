//
//  KFChatSmartView.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/18.
//  Copyright © 2022 环信. All rights reserved.
//

#import "EMChatBaseBubbleView.h"

NS_ASSUME_NONNULL_BEGIN
extern  NSString *const kRouterEventCopyTextTapEventName ;
extern  NSString *const kRouterEventSendMessageTapEventName ;



@interface KFChatSmartView : EMChatBaseBubbleView<UITextFieldDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIEdgeInsets _margin;
    HDTextMessageBody *_body;

}
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UIView *footerView;
- (void)updateFileMargin:(UIEdgeInsets)margin;
- (void)setModel:(HDMessage *)model;
@end

NS_ASSUME_NONNULL_END
