//
//  HDLocationMessageBody.h
//  AgentSDK
//
//  Created by afanda on 10/10/17.
//  Copyright © 2017 环信. All rights reserved.
//

#import <AgentSDK/AgentSDK.h>

@interface HDLocationMessageBody : HDBaseMessageBody

/*!
 *  \~chinese
 *  纬度
 *
 *  \~english
 *  Location latitude
 */
@property (nonatomic) double latitude;

/*!
 *  \~chinese
 *  经度
 *
 *  \~english
 *  Loctaion longitude
 */
@property (nonatomic) double longitude;

/*!
 *  \~chinese
 *  地址信息
 *
 *  \~english
 *  Address
 */
@property (nonatomic, copy) NSString *address;

/*!
 *  \~chinese
 *  初始化位置消息体
 *
 *  @param aLatitude   纬度
 *  @param aLongitude  经度
 *  @param aAddress    地理位置信息
 *
 *  @result 位置消息体实例
 *
 *  \~english
 *  Initialize a location message body instance
 *
 *  @param aLatitude   Latitude
 *  @param aLongitude  Longitude
 *  @param aAddress    Address
 *
 *  @result Location message body instance
 */
- (instancetype)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                         address:(NSString *)aAddress;


@end
