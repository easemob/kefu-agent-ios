//
//  DXUpdateView.m
//  EMCSApp
//
//  Created by EaseMob on 15/9/10.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXUpdateView.h"

@interface DXUpdateView ()
{
    NSDictionary *_info;
}

@end

@implementation DXUpdateView

- (id)initWithFrame:(CGRect)frame updateInfo:(NSDictionary*)info
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupView:info];
    }
    return self;
}

- (void)_setupView:(NSDictionary*)info
{
    _info = info;
}

#pragma mark - action

-(void)endAction
{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)updateAction
{
}

@end
