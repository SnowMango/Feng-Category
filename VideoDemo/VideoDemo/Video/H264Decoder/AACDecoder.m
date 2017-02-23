//
//  AACDecoder.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "AACDecoder.h"

@protocol AudioStreamDecoderDelegate <NSObject>

- (void)audioListenerReadyToProducePackets:(AudioStreamBasicDescription)basic fileStream:(AudioFileStreamID)stream;

- (void)audioDecoderPackets:(AudioStreamPacketDescription *)inPacketDescriptions bytes:(UInt32)numberBytes numberPackets:(UInt32)numberPackets;
@end

void MyPacketsProc(void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions);

void MyPropertyListenerProc(void *inClientData,
                            AudioFileStreamID inAudioFileStream,
                            AudioFileStreamPropertyID inPropertyID,
                            UInt32 *ioFlags);


@interface AACDecoder ()
@property (nonatomic) AudioFileStreamID audioFileStream;
@property (nonatomic) AudioStreamBasicDescription basicDescription;
@property (nonatomic) CMFormatDescriptionRef format;
@property (nonatomic) AudioStreamPacketDescription* packetDescriptions;
@property (nonatomic) UInt32 numberBytes;
@property (nonatomic) UInt32 numberPackets;
@end

@implementation AACDecoder
-(void)dealloc
{
    AudioFileStreamClose(_audioFileStream);
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        OSStatus err =
        AudioFileStreamOpen((__bridge void*)self,
                            MyPropertyListenerProc,
                            MyPacketsProc,
                            kAudioFileAAC_ADTSType,
                            &_audioFileStream);
        if (err) { NSLog(@"AudioFileStream Open Fail");  }
    }
    return self;
}

- (void)audioListenerReadyToProducePackets:(AudioStreamBasicDescription)basic fileStream:(AudioFileStreamID)stream
{
    self.basicDescription = basic;
    OSStatus err = noErr;
    
    UInt32 cookieSize;
    err = AudioFileStreamGetPropertyInfo(stream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, NULL);
    if (err) {return;}
    void* cookieData = calloc(1, cookieSize);
    err = AudioFileStreamGetProperty(stream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
    if (err) { free(cookieData); return;}
    
    UInt32 layoutSize;
    err = AudioFileStreamGetPropertyInfo(stream, kAudioFileStreamProperty_ChannelLayout, &layoutSize, NULL);
    if (err) {return;}
    AudioChannelLayout *layout = calloc(1, layoutSize);
    err = AudioFileStreamGetProperty(stream, kAudioFileStreamProperty_ChannelLayout, &cookieSize, layout);
    if (err) {return;}
    
    UInt32 extensionSize;
    err = AudioFileStreamGetPropertyInfo(stream, kAudioFileStreamProperty_InfoDictionary, &extensionSize, NULL);
    if (err) {return;}
    CFDictionaryRef extension = calloc(1, extensionSize);
    err = AudioFileStreamGetProperty(stream, kAudioFileStreamProperty_InfoDictionary, &extensionSize, &extension);
    if (err) {return;}
    
    CMFormatDescriptionRef format;
    CMAudioFormatDescriptionCreate(kCFAllocatorDefault,
                                   &_basicDescription,
                                   layoutSize,
                                   layout,
                                   cookieSize,
                                   cookieData,
                                   extension,
                                   &format);
    self.format = format;
}



- (void)audioDecoderPackets:(AudioStreamPacketDescription *)inPacketDescriptions bytes:(UInt32)numberBytes numberPackets:(UInt32)numberPackets
{
    self.packetDescriptions = inPacketDescriptions;
}

- (CMSampleBufferRef)audioDecoder:(NSData *)aacData
{
    OSStatus err = AudioFileStreamParseBytes(_audioFileStream,
                                           (UInt32)aacData.length,
                                           aacData.bytes,
                                           0);
    
    if (err) { NSLog(@"AudioFileStream Parse Fail");  }
    
    CMSampleBufferRef sm = [self decoderSampleBufferRefWithData:aacData];
    
    return sm;
}

- (CMSampleBufferRef)decoderSampleBufferRefWithData:(NSData*)data
{
    CMBlockBufferRef blockBufferRef = NULL;
    
    //1.Fetch video data and generate CMBlockBuffer
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         (void*)data.bytes,
                                                         data.length,
                                                         kCFAllocatorNull,
                                                         NULL,
                                                         0,
                                                         data.length,
                                                         0,
                                                         &blockBufferRef);
    //2.Create CMSampleBuffer
    if(status == kCMBlockBufferNoErr){
        CMTime time = CMTimeMake(1, self.basicDescription.mSampleRate);
        CMSampleBufferRef sampleBufferRef = NULL;
        status = CMAudioSampleBufferCreateReadyWithPacketDescriptions(kCFAllocatorDefault,
                                                                      blockBufferRef,
                                                                      _format,
                                                                      _numberBytes,
                                                                      time,
                                                                      _packetDescriptions,
                                                                      &sampleBufferRef);
        if(status != noErr){
            CFRelease(sampleBufferRef);
            return NULL;
        }
        return sampleBufferRef;
    }
    return NULL;
}

@end

void MyPropertyListenerProc(void *inClientData,
                            AudioFileStreamID inAudioFileStream,
                            AudioFileStreamPropertyID inPropertyID,
                            UInt32 *ioFlags)
{
    // this is called by audio file stream when it finds property values
    id <AudioStreamDecoderDelegate>decoder = (__bridge id )inClientData;
    OSStatus err = noErr;
    switch (inPropertyID) {
        case kAudioFileStreamProperty_ReadyToProducePackets :
        {
            // the file stream parser is now ready to produce audio packets.
            AudioStreamBasicDescription asbd;
            UInt32 asbdSize = sizeof(asbd);
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
            
            [decoder audioListenerReadyToProducePackets:asbd fileStream:inAudioFileStream];
            break;
        }
    }
}

void MyPacketsProc(void *						inClientData,
                   UInt32						inNumberBytes,
                   UInt32						inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions)
{
    id <AudioStreamDecoderDelegate>decoder = (__bridge id )inClientData;
    [decoder audioDecoderPackets:inPacketDescriptions
                           bytes:inNumberBytes
                   numberPackets:inNumberPackets];
}




