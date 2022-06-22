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

#import "EMCDDeviceManager+Remind.h"

/**
 *  系统铃声播放完成后的回调
 */
void EMSystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}

@implementation EMCDDeviceManager (Remind)
SystemSoundID sound = kSystemSoundID_Vibrate;
// 播放接收到新消息时的声音
- (SystemSoundID)playNewMessageSound
{
    SystemSoundID soundID = 1007;
    AudioServicesPlaySystemSound(soundID);
    
    return soundID;
}
- (SystemSoundID)playNewMessageSoundCustom{
    
    //使用自定义铃声
       NSString *path = [[NSBundle mainBundle] pathForResource:@"call"ofType:@"mp3"];
       //需将音频资源copy到项目<br>
       if (path)
       {
           OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&sound);
           if (error != kAudioServicesNoError)
           {
               sound = 0;
           }
       }else{
           sound = 1007;
//           AudioServicesPlaySystemSound(sound);
       }
//    AudioServicesPlaySystemSound(sound);
    [self btn];
    return sound;
}

- (void)btn
{
     AudioServicesPlaySystemSound(sound);//播放声音
    self.voice_timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(voice) userInfo:nil repeats:YES];
    self.vibrate_timer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(vibrate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.voice_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop]addTimer:self.vibrate_timer forMode:NSRunLoopCommonModes];
}
- (void)stopSystemSoundID
{
    [self.voice_timer invalidate];
    [self.vibrate_timer invalidate];
    AudioServicesDisposeSystemSoundID(sound);
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
}

- (void)voice
{
    AudioServicesPlaySystemSound(sound);//播放声音
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//静音模式下震动
}

// 震动
- (void)playVibration
{
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          EMSystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
