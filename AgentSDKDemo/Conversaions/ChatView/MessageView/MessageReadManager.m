/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "MessageReadManager.h"
#import "UIImageView+EMWebCache.h"
#import "EMCDDeviceManager.h"

static MessageReadManager *detailInstance = nil;

@interface MessageReadManager()<UIActionSheetDelegate>

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UINavigationController *photoNavigationController;

@property (strong, nonatomic) UIAlertView *textAlertView;

@end

@implementation MessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}

#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}

- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

- (MWPhotoBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _photoBrowser.displayActionButton = YES;
        _photoBrowser.displayNavArrows = YES;
        _photoBrowser.displaySelectionButtons = NO;
        _photoBrowser.alwaysShowControls = NO;
        _photoBrowser.wantsFullScreenLayout = YES;
        _photoBrowser.zoomPhotosToFill = YES;
        _photoBrowser.enableGrid = NO;
        _photoBrowser.startOnGrid = NO;
        _photoBrowser.delegate = self;
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.photoBrowser];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [self.photoBrowser viewDidLoad];
    return _photoNavigationController;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}


#pragma mark - private


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
                [photoArray addObject:photo];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [MWPhoto photoWithURL:object];
                [photoArray addObject:photo];
            }
            else if ([object isKindOfClass:[NSString class]])
            {
                
            }
        }
        
        self.photos = photoArray;
    }
    
    UIViewController *rootController = [self.keyWindow rootViewController];
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
//    [self.photoNavigationController.view addGestureRecognizer:longPress];
    [rootController presentViewController:self.photoNavigationController animated:YES completion:nil];
}


//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    
//}

- (void)showMenu {
    UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册", nil];
    
    [act showInView:self.keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"保存");
        UIImage *img = [self.photos firstObject];
//        if (![img isKindOfClass:[UIImage class]]) {
//            img = self.photoBrowser
//        }
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"error";
    if (!error) {
        [MBProgressHUD showSuccess:@"保存成功" toView:self.keyWindow];
    }else
    {
        message = [error description];
        [MBProgressHUD showError:message toView:self.keyWindow];
    }
}

- (BOOL)prepareMessageAudioModel:(HDMessage *)messageModel
                      updateViewCompletion:(void (^)(HDMessage *prevAudioModel, HDMessage *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    if(messageModel.type == HDMessageBodyTypeVoice)
    {
        HDMessage *prevAudioModel = self.audioMessageModel;
        HDMessage *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isPlaying;
        if (isPlaying) {
            messageModel.isPlaying = NO;
            self.audioMessageModel = nil;
            prevAudioModel.isPlaying = NO;
            currentAudioModel = nil;
            
            [[EMCDDeviceManager sharedInstance] stopPlaying];
            
//            [[EaseMob sharedInstance].chatManager stopPlayingAudio];
        }
        else {
            messageModel.isPlaying = YES;
            prevAudioModel.isPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isPlayed) {
                messageModel.isPlayed = YES;
                /*
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [chatMessage updateMessageExtToDB];
                    }
                }*/
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    return isPrepare;
}

- (HDMessage *)stopMessageAudioModel
{
    HDMessage *model = nil;
    if (self.audioMessageModel.type == HDMessageBodyTypeVoice) {
        if (self.audioMessageModel.isPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}


@end
