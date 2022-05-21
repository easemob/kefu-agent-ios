//
//  KFSmartChoiceTableViewCell.h
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickChoiceItemBlock)(KFSmartModel *model,id cell);
@interface KFSmartChoiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *knowledgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelCopy;
@property (weak, nonatomic) IBOutlet UILabel *labelCopyNum;
@property (weak, nonatomic) IBOutlet UILabel *labelSendNum;
@property (weak, nonatomic) IBOutlet UILabel *labelSend;
@property(nonatomic,copy) ClickChoiceItemBlock clickChoiceItemBlock;
- (void)setModel:(KFSmartModel *)model;
@end

NS_ASSUME_NONNULL_END
