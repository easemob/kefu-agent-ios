//
//  CustomerViewController.m
//  EMCSApp
//
//  Created by EaseMob on 15/5/14.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "CustomerViewController.h"

#import "CustomerController.h"
#import "HomeViewController.h"

@interface CustomerViewController ()<CustomerControllerDelegate>
{
    
}

@end

@implementation CustomerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _customerController = [[CustomerController alloc] init];
        _customerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _customerController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _customerController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;

//    [_customerController addObserver:self forKeyPath:CUSTOMER_UNREADCOUNT options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.view addSubview:_customerController.view];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_customerController clearSession];
//    [[HomeViewController HomeViewController] setCustomerUnRead:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CustomerControllerDelegate
- (void)CustomerPushIntoChat:(UIViewController *)viewController
{
    [_customerController searhResign];
    [self.conDelegate ConversationPushIntoChat:viewController];
}

- (void)loadData {
    [_customerController loadData];
}
#pragma mark - kvo

/*
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:CUSTOMER_UNREADCOUNT])
    {
        int unreadcount = [[_customerController valueForKey:CUSTOMER_UNREADCOUNT] intValue];
        if (unreadcount <= 0) {
            [[HomeViewController HomeViewController] setCustomerWithBadgeValue:nil];
        } else if (unreadcount > 0 && unreadcount < 100){
            [[HomeViewController HomeViewController] setCustomerWithBadgeValue:[NSString stringWithFormat:@"%@",@(unreadcount)]];
        } else {
            [[HomeViewController HomeViewController] setCustomerWithBadgeValue:[NSString stringWithFormat:@"%@",@"99+"]];
        }
    }
}*/

@end
