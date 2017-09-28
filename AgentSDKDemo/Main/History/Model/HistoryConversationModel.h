//
//  HistoryConversationModel.h
//  EMCSApp
//
//  Created by EaseMob on 16/3/2.
//  Copyright © 2016年 easemob. All rights reserved.
//


@interface HistoryConversationModel : HDConversation

@property (nonatomic, copy) NSString *agentUserNiceName;
@property (nonatomic, copy) NSArray *summarys;

@end
