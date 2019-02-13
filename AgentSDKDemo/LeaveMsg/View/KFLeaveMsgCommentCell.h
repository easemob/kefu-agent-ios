//
//  KFLeaveMsgCommentCell.h
//  EMCSApp
//
//  Created by afanda on 16/11/4.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LeaveMsgCellDelegate <NSObject>

- (void)didSelectFileAttachment:(HLeaveMessageCommentAttachment *)attachment;

- (void)didselectImageAttachment:(HLeaveMessageCommentAttachment *)attachment;
@end

@interface KFLeaveMsgCommentCell : UITableViewCell
@property (nonatomic, strong) HLeaveMessageComment *model;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detailMsg;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic) NSInteger unreadCount;

@property (nonatomic, weak) id<LeaveMsgCellDelegate> delegate;


+(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath;

+(CGFloat)tableView:(UITableView *)tableView model:(HLeaveMessageComment *)model;

+ (CGFloat)_heightForModel:(HLeaveMessageComment *)model;
@end
