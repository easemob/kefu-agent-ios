//
//  LeaveMsgInputView.m
//  EMCSApp
//
//  Created by EaseMob on 16/9/7.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "LeaveMsgInputView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MessageReadManager.h"

typedef NS_ENUM(NSUInteger, InputViewState) {
    InputViewStateInit = 0, //初始化状态
    InputViewStateEdit,     //编辑状态
};

@interface LeaveMsgInputView () <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *attachmentButton;
@property (nonatomic, strong) UILabel *attachmentLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, assign) CGRect initFrame;
@end

@implementation LeaveMsgInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _initFrame = frame;
        [self addSubview:self.attachmentButton];
        [self addSubview:self.attachmentLabel];
        [self addSubview:self.sendButton];
        [self addSubview:self.inputField];
        [self addSubview:self.tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return _imagePicker;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIButton *)uploadButton
{
    if (_uploadButton == nil) {
        _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _uploadButton.frame = CGRectMake(10, 2, (KScreenWidth - 30)/2, 36.f);
        [_uploadButton setTitle:@"相册" forState:UIControlStateNormal];
        [_uploadButton setBackgroundColor:RGBACOLOR(26, 26, 26, 1)];
        _uploadButton.layer.cornerRadius = 4.f;
        [_uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
        _uploadButton.userInteractionEnabled = YES;
    }
    return _uploadButton;
}

- (UILabel*)attachmentLabel
{
    if (_attachmentLabel == nil) {
        _attachmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_attachmentButton.frame), 5, 40, 30)];
        _attachmentLabel.text = @"0";
        _attachmentLabel.textColor = RGBACOLOR(204, 204, 204, 1);
    }
    return _attachmentLabel;
}

- (UITableView*)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, KScreenWidth, 44 * 3 + 40.f) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc] init];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
        [headerView addSubview:self.uploadButton];
        _tableView.tableHeaderView = headerView;
    }
    return _tableView;
}

//选择附件
- (UIButton *)attachmentButton
{
    if (_attachmentButton == nil) {
        _attachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _attachmentButton.frame = CGRectMake(5, 5, 30.f, 30.f);
        [_attachmentButton setImage:[UIImage imageNamed:@"input_tab_icon_file2"] forState:UIControlStateNormal];
        [_attachmentButton addTarget:self action:@selector(attachmentAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _attachmentButton;
}

//发送
- (UIButton *)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(KScreenWidth - 49, 5, 44.f, 30.f);
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendLeaveMsg) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UITextField *)inputField
{
    if (_inputField == nil) {
        CGFloat width = KScreenWidth - 10;
        // 初始化输入框
        _inputField = [[UITextField  alloc] initWithFrame:CGRectMake(5, 44, width, 32)];
        _inputField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _inputField.returnKeyType = UIReturnKeyDone;
        _inputField.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _inputField.placeholder = @"请输入...";
        _inputField.delegate = self;
        _inputField.backgroundColor = [UIColor whiteColor];
        _inputField.layer.borderColor = RGBACOLOR(0xb5, 0xb7, 0xbb, 1).CGColor;
    }
    return _inputField;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"AttachmentListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    HLeaveMessageCommentAttachment *attachment = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = attachment.attachmentName;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HLeaveMessageCommentAttachment *attachment = [self.dataArray objectAtIndex:indexPath.row];
    NSMutableArray *images = [NSMutableArray array];
    [images addObject:[NSURL URLWithString:attachment.url]];
    if ([images count] > 0) {
        [[MessageReadManager defaultManager] showBrowserWithImages:images];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        _attachmentLabel.text = [NSString stringWithFormat:@"%@",@([self.dataArray count])];
        [tableView endUpdates];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        __weak typeof(self) weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"上传附件中..." toView:self];
        hud.layer.zPosition = 1.f;
        __weak MBProgressHUD *weakHud = hud;
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            NSString *fileName = [representation filename];
            NSData *data;
            //图片进行压缩,清晰度变化不大，大小减小很多
            if (UIImageJPEGRepresentation(orgImage, 0.5) == nil) {
                data = UIImagePNGRepresentation(orgImage);
            } else {
                data = UIImageJPEGRepresentation(orgImage, 0.5);
            }
            
            [HDClient.sharedClient.leaveMessageMananger asyncUploadCommentAttachmentWithData:data fileName:fileName progress:^(float progress) {
                
            } completion:^(HLeaveMessageCommentAttachment *attachment, HDError *error) {
                [weakHud hide:YES];
                if (error == nil) {
                    attachment.attachmentName = fileName;
                    [weakSelf.dataArray addObject:attachment];
                    _attachmentLabel.text = [NSString stringWithFormat:@"%@",@([self.dataArray count])];
                    [weakSelf.tableView reloadData];
                } else {
                    [weakHud setLabelText:@"上传失败"];
                    [weakHud hide:YES afterDelay:0.5];
                }
            }];
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:nil];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    //上分割线，
    CGContextSetStrokeColorWithColor(context, RGBACOLOR(229, 230, 231, 1).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 1.0));
    //下分割线
    //    CGContextSetStrokeColorWithColor(context, RGBACOLOR(0xe5, 0xe5, 0xe5, 1).CGColor);
    //    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 0.5, rect.size.width, 0.5));
}

#pragma mark - action

- (void)uploadAction
{
    [self.inputField endEditing:YES];
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectImageWithPicker:)]) {
        [self.delegate didSelectImageWithPicker:self.imagePicker];
    }
}

- (void)attachmentAction
{
    _attachmentButton.selected = !_attachmentButton.selected;
    if (_attachmentButton.selected) {
        [self changeHeightWithState:InputViewStateEdit];
    } else {
        [self changeHeightWithState:InputViewStateInit];
    }
}

- (void)resetAttachmentButton {
    _attachmentButton.selected = NO;
}

- (void)changeHeightWithState:(InputViewState)inputState{
    [self.inputView endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        if (inputState == InputViewStateEdit) {
            self.top = self.top - 162;
        } else {
            if (self.top != KScreenHeight - 88.f - 64) {
                self.top = self.top + 162;
            }
        }
    }];
}

//发送留言
- (void)sendLeaveMsg
{
    if (_dataArray.count <=0 && self.inputField.text.length <=0) {
        [MBProgressHUD showError:@"请输入内容或附件" toView:fKeyWindow];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendText:attachments:)]) {
        [self.delegate didSendText:self.inputField.text attachments:_dataArray];
        [_dataArray removeAllObjects];
        [self.tableView reloadData];
    }
    self.inputField.text = @"";
    _attachmentLabel.text = @"0";
    [self.inputField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.top = KScreenHeight-88-64;
    }];
    _attachmentButton.selected = NO;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    [UIView animateWithDuration:0.25 animations:^{
        if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
        {
            self.top = KScreenHeight - 88.f - 64;
        }
        else{
            self.top = KScreenHeight - 88.f - toFrame.origin.y;
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


@end
