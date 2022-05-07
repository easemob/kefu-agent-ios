//
//  EMFileViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/18.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMFileViewController.h"
#import "ChatViewController.h"

@interface EMFileViewController ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic, strong) UIBarButtonItem *openFileItem;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIImageView *fileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation EMFileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"文件";
    self.view.backgroundColor = kTableViewBgColor;
    
    self.tableView.hidden = YES;
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.navigationItem.rightBarButtonItem = self.openFileItem;
    
    if (![ChatViewController isExistFile:_model]) {
        [self.view addSubview:self.downloadButton];
    }
    [self.view addSubview:self.fileImageView];
    [self.view addSubview:self.nameLabel];
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake((KScreenWidth - 200.f)/2, CGRectGetMaxY(self.fileImageView.frame) + 10.f, 200.f, 20.f);
        _nameLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.text = ((HDFileMessageBody *)_model.nBody).displayName;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIImageView*)fileImageView
{
    if (_fileImageView == nil) {
        _fileImageView = [[UIImageView alloc] init];
        _fileImageView.frame = CGRectMake((KScreenWidth - 120)/2, 100.f, 120.f, 120.f);
        _fileImageView.image = [UIImage imageNamed:@"image_file2_icon_files"];
        _fileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fileImageView.layer.masksToBounds = YES;
    }
    return _fileImageView;
}

- (UIButton *)downloadButton
{
    if (_downloadButton == nil) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + 10.f, KScreenWidth, 20.f);
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_downloadButton setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (UIBarButtonItem*)openFileItem
{
    if (_openFileItem == nil) {
        UIButton *openFileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openFileButton.frame = CGRectMake(0, 0, 44, 44);
        [openFileButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [openFileButton setTitle:@"打开" forState:UIControlStateNormal];
        [openFileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [openFileButton addTarget:self action:@selector(openFileAction) forControlEvents:UIControlEventTouchUpInside];
        _openFileItem = [[UIBarButtonItem alloc] initWithCustomView:openFileButton];
    }
    return _openFileItem;
}

- (void)downloadAction
{
    [self downloadMessageAttachments:_model];
}

- (void)openFileAction
{
    HDFileMessageBody *body = (HDFileMessageBody *)_model.nBody;
    NSString *filePath = [[KFFileCache sharedInstance] fileFullPathWithUrlStr:body.remotePath];
    if (![[KFFileCache sharedInstance] isExistFile:filePath]) {
        [self showHint:@"正在下载文件,请稍后点击"];
        [self downloadMessageAttachments:_model];
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [filePath stringByDeletingLastPathComponent];
    path = [path stringByAppendingPathComponent:body.displayName];
    [fm moveItemAtPath:filePath toPath:path error:nil];
    
    NSURL *URL = [NSURL fileURLWithPath:path];
    self.documentController = [UIDocumentInteractionController
                               interactionControllerWithURL:URL];
    self.documentController.delegate = self;
    if (![self.documentController presentPreviewAnimated:YES]) {
        CGRect frame = UIScreen.mainScreen.bounds;
        CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.documentController presentOptionsMenuFromRect:rect
                                                     inView:self.view
                                                   animated:YES];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)downloadMessageAttachments:(HDMessage *)model
{
    if (model.type == HDMessageBodyTypeFile) {
        HDFileMessageBody *body = (HDFileMessageBody *)model.nBody;
        if (body) {
            [self showHintNotHide:@"正在下载文件"];
            WEAK_SELF
            [[KFFileCache sharedInstance] storeFileWithRemoteUrl:body.remotePath completion:^(id responseObject, NSString *path, NSError *error) {
                [weakSelf hideHud];
                if (!error) {
                    weakSelf.downloadButton.hidden = YES;
                }
            }];
        }
    }
}

@end
