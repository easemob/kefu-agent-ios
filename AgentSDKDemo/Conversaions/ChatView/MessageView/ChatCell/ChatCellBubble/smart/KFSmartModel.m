//
//  KFSmartModel.m
//  AgentSDKDemo
//
//  Created by houli on 2022/5/20.
//  Copyright © 2022 环信. All rights reserved.
//

#import "KFSmartModel.h"
#import "KFSmartUtils.h"
@implementation KFSmartModel



-(void)setType:(NSString *)type{

    _type = type;
    NSLog(@"====%@",type);
    if ([KFSmartUtils isTextMessageStr:type]) {
        //文本 答案
        _msgtype = HDSmartExtMsgTypeText;
        
    } else if ([KFSmartUtils isMenuMessageStr:type]) {
        //菜单答案
        _msgtype = HDSmartExtMsgTypeMenu;
    }else if ([KFSmartUtils isArticleMessageStr:type]) {
    
        //图文 答案
        _msgtype = HDSmartExtMsgTypearticle;
    }else if ([KFSmartUtils isImgMessageStr:type]) {
        
        //图片 答案
        _msgtype = HDSmartExtMsgTypeImamge;
    }else if ([KFSmartUtils isGroupMessageStr:type]) {
        
        // 答案组
        _msgtype = HDSmartExtMsgTypeGroup;
    }
    
}



@end
