//
//  LocationViewController.h
//  EMCSApp
//
//  Created by EaseMob on 8/5/15.
//  Copyright (c) 2015年 easemob. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol LocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface LocationViewController : EMBaseViewController

@property (nonatomic, assign) id<LocationViewDelegate> delegate;

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;

@end
