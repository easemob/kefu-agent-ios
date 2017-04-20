//
//  EMFileViewController.m
//  EMCSApp
//
//  Created by EaseMob on 16/3/18.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMFileViewController.h"

#import "TTOpenInAppActivity.h"

#import "ChatViewController.h"

@interface EMFileViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *openFileItem;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIImageView *fileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property(nonatomic,strong) UIDocumentInteractionController *documentInteractionController;
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
        _nameLabel.frame = CGRectMake((hScreenWidth - 200.f)/2, CGRectGetMaxY(self.fileImageView.frame) + 10.f, 200.f, 20.f);
        _nameLabel.textColor = RGBACOLOR(26, 26, 26, 1);
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.text = _model.body.fileName;
    }
    return _nameLabel;
}

- (UIImageView*)fileImageView
{
    if (_fileImageView == nil) {
        _fileImageView = [[UIImageView alloc] init];
        _fileImageView.frame = CGRectMake((hScreenWidth - 120)/2, 100.f, 120.f, 120.f);
        _fileImageView.image = [UIImage imageNamed:@"image_file2_icon_files"];
        _fileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fileImageView.layer.masksToBounds = YES;
    }
    return _fileImageView;
}

- (UIButton*)downloadButton
{
    if (_downloadButton == nil) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + 10.f, hScreenWidth, 20.f);
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
- (UIDocumentInteractionController *)documentInteractionController {
    if (!_documentInteractionController) {
        _documentInteractionController = [[UIDocumentInteractionController alloc]init];
        _documentInteractionController.delegate = self;
    }
    return _documentInteractionController;
}

- (void)openFileAction
{
    if (_model.localPath.length == 0) {
        [self showHint:@"正在下载文件,请稍后点击"];
        [self downloadMessageAttachments:_model];
        return;
    }
    
    NSURL *URL = [NSURL fileURLWithPath:_model.localPath];
    self.documentInteractionController.URL = URL;
    self.documentInteractionController.name = _model.body.fileName;
    if (![self.documentInteractionController presentPreviewAnimated:YES]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"系统不支持预览此类文件" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    
//    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:self.tableView.frame];
//    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[openInAppActivity]];
//    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        // Store reference to superview (UIActionSheet) to allow dismissal
//        openInAppActivity.superViewController = activityViewController;
//        // Show UIActivityViewController
//        [self presentViewController:activityViewController animated:YES completion:NULL];
//    } else {
//        // Create pop up
//        UIPopoverController *activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
//        // Store reference to superview (UIPopoverController) to allow dismissal
//        openInAppActivity.superViewController = activityPopoverController;
//        // Show UIActivityViewController in popup
//        [activityPopoverController presentPopoverFromRect:self.tableView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }

}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (void)downloadMessageAttachments:(MessageModel *)model
{
    if (model.type == kefuMessageBodyType_File) {
        if (model.body) {
            
            if ([ChatViewController isExistFile:model]) {
                return;
            }
            [self showHintNotHide:@"正在下载文件"];
            WEAK_SELF
//            [[DXCSManager shareManager] asyncFetchDownLoadWithFilePath:model.body.originalPath Completion:^(id responseObject, DXError *error) {
//                [weakSelf hideHud];
//                if (!error) {
//                    NSString *libDir = NSHomeDirectory();
//                    libDir = [libDir stringByAppendingPathComponent:@"Library"];
//                    NSString *dbDirectoryPath = [libDir stringByAppendingPathComponent:@"kefuAppFile"];
//                    NSData *data = [NSData dataWithContentsOfURL:responseObject];
//                    NSString *path = [NSString stringWithFormat:@"%@/%@",dbDirectoryPath,model.body.fileName];
//                    [data writeToFile:path atomically:YES];
//                    
//                    model.localPath = path;
//                    weakSelf.downloadButton.hidden = YES;
//                }
//            }];
        }
    }
}

@end
