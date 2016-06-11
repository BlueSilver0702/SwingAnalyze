//
//  AudioRecorder.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 7/26/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "AudioRecorder.h"

@implementation AudioRecorder

+ (NSString *)defaultOutputPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/audio_record.m4a", documentsDirectory];
}

- (void)startRecording
{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof (audioRouteOverride),&audioRouteOverride);

    if (![[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error]){
        
        NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    }
    
    NSDictionary* recordsettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
     nil];
    

    NSString *strRecordingFilePath = [AudioRecorder defaultOutputPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:strRecordingFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:strRecordingFilePath error:nil];
    
    m_recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:strRecordingFilePath]
                                             settings:recordsettings
                                                error:nil];

    m_recorder.delegate = self.delegate;
    
    [m_recorder record];
}

- (void)stopRecording
{
    [m_recorder stop];
    
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}
@end
