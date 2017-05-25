//
//  HDPushOptions.h
//  AgentSDK
//
//  Created by afanda on 4/6/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDPushOptions.h"
/*!
 *  \~chinese
 *  推送消息的显示风格
 *
 *  \~english
 *  Display style of push message
 */
typedef enum
{
    HDPushDisplayStyleSimpleBanner = 0, /*!
                                        *  \~chinese
                                        *  简单显示"您有一条新消息"
                                        *
                                        *  \~english
                                        *  Simply show "You have a new message"
                                        */
    HDPushDisplayStyleMessageSummary,   /*!
                                        *  \~chinese
                                        *  显示消息内容
                                        *
                                        *  \~english
                                        *  Show message's content
                                        */
}HDPushDisplayStyle;

/*!
 *  \~chinese
 *  推送免打扰设置的状态
 *
 *  \~english
 *  Status of Push Notification no-disturb setting
 */
typedef enum{
    HDPushNoDisturbStatusDay = 0,   /*! \~chinese 全天免打扰 \~english The whole day */
    HDPushNoDisturbStatusCustom,    /*! \~chinese 自定义时间段免打扰 \~english User defined period */
    HDPushNoDisturbStatusClose,     /*! \~chinese 关闭免打扰 \~english Close no-disturb mode */
}HDPushNoDisturbStatus;

/*!
 *  \~chinese
 *  消息推送的设置选项
 *
 *  \~english
 *  Apple Push Notification setting options
 */
@interface HDPushOptions : NSObject
/*!
 *  \~chinese
 *  推送消息显示的昵称
 *
 *  \~english
 *  User's nickname to be displayed in apple push notification service messages
 */
@property (nonatomic, copy) NSString *displayName;

/*!
 *  \~chinese
 *  推送消息显示的类型
 *
 *  \~english
 *  Display style of notification message
 */
@property (nonatomic) HDPushDisplayStyle displayStyle;

/*!
 *  \~chinese
 *  消息推送的免打扰设置
 *
 *  \~english
 *  No disturbing setting of notification message
 */
@property (nonatomic) HDPushNoDisturbStatus noDisturbStatus;

/*!
 *  \~chinese
 *  消息推送免打扰开始时间，小时，暂时只支持整点（小时）
 *
 *  \~english
 *  No disturbing mode start time (in hour)
 */
@property (nonatomic) NSInteger noDisturbingStartH;

/*!
 *  \~chinese
 *  消息推送免打扰结束时间，小时，暂时只支持整点（小时）
 *
 *  \~english
 *  No disturbing mode end time (in hour)
 */
@property (nonatomic) NSInteger noDisturbingEndH;
@end

