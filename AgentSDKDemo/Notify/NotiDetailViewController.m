//
//  NotiDetailViewController.m
//  EMCSApp
//
//  Created by afanda on 3/28/17.
//  Copyright © 2017 easemob. All rights reserved.
//

#import "NotiDetailViewController.h"
#import "NSDate+Formatter.h"
#import "ClientInforViewController.h"
@interface NotiDetailViewController ()

@property (nonatomic, strong) UILabel *nickName;
@property (nonatomic, strong) UILabel *createDate;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *actorId;
@property (nonatomic, strong) UIButton *detailBtn;
@property (nonatomic, strong) UILabel *detail;

@end


@implementation NotiDetailViewController
{
    UIScrollView *_backView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"通知详情";
    [self baseUI];
    
}

- (void)baseUI {
    CGFloat maxY = 0;
    _backView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, maxY, KScreenWidth, KScreenHeight-64)];
    _backView.contentSize = CGSizeMake(KScreenWidth, KScreenHeight);
    _backView.scrollEnabled = YES;
    _backView.backgroundColor = RGBACOLOR(243, 243, 243, 1);
    //title
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
    titleView.backgroundColor = [UIColor whiteColor];
    _nickName = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 200, 20)];
    _nickName.font = [UIFont boldSystemFontOfSize:18];
    _nickName.text = _model.name;
    _nickName.textColor = UIColor.grayColor;
    [titleView addSubview:_nickName];
    _createDate = [[UILabel alloc] initWithFrame:CGRectMake(15, 60, 200, 20)];
    _createDate.text = [[NSDate dateWithTimeIntervalSince1970:_model.createDateTime/1000] minuteDescription];;
    _createDate.textColor = UIColor.grayColor;
    [titleView addSubview:_createDate];
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth-80, 20, 60, 60)];
    _avatar.image = [UIImage imageNamed:@"default_customer_avatar"];
    _avatar.layer.cornerRadius = 30;
    _avatar.layer.masksToBounds = YES;
    [titleView addSubview:_avatar];
    [_backView addSubview:titleView];
    maxY = CGRectGetMaxY(titleView.frame);
    if (_model.redirectInfo.count > 0) {
        //middle
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, maxY + 20, KScreenWidth, 50)];
        middleView.backgroundColor = [UIColor whiteColor];
        _actorId = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, KScreenWidth-100, 20)];
        _actorId.numberOfLines = 0;
        NSString *visitorId = @"";
        NSDictionary *dic = [_model.redirectInfo firstObject];
        visitorId = [dic objectForKey:@"visitorNickname"];
        if (visitorId == nil || [visitorId isKindOfClass:[NSNull class]]) {
            visitorId = [dic valueForKey:@"visitorUserId"];
        }
        _actorId.text = [NSString stringWithFormat:@"ID:%@",visitorId];
        [_actorId sizeToFit];
        [middleView addSubview:_actorId];
        _detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailBtn.backgroundColor =RGBACOLOR(25, 168, 236, 1);
        [_detailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_detailBtn setTitle:@"查看详情" forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(detailClicked) forControlEvents:UIControlEventTouchUpInside];
        _detailBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _detailBtn.tintColor = UIColor.whiteColor;
        _detailBtn.frame = CGRectMake(KScreenWidth-85, 10, 70, 30);
        _detailBtn.layer.cornerRadius = 5;
        _detailBtn.layer.masksToBounds = YES;
        [middleView addSubview:_detailBtn];
        [_backView addSubview:middleView];
        maxY = CGRectGetMaxY(middleView.frame);
    }
    
    //detail
    _detail = [[UILabel alloc] initWithFrame:CGRectMake(15, maxY+20, KScreenWidth-30, 20)];
    _detail.textColor = UIColor.grayColor;
    _detail.font = [UIFont systemFontOfSize:14];
    _detail.numberOfLines = 0;
    _detail.text = [NSString stringWithFormat:@"   %@",_model.detail.length != 0?_model.detail:_model.summary];
    [_detail sizeToFit];
    [_backView addSubview:_detail];
    
    [self.view addSubview:_backView];
}

- (void)detailClicked {
    NSLog(@"查看详情");
    NSDictionary *dic = [_model.redirectInfo firstObject];
    NSString *userId = [dic valueForKey:@"visitorUserId"];
    ClientInforViewController *clientView = [[ClientInforViewController alloc] init];
    clientView.userId = userId;
    clientView.readOnly = YES;
    clientView.niceName = _model.name;
    [self.navigationController pushViewController:clientView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
