//
//  AACDecoder.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "AACDecoder.h"


void MyPropertyListenerProc(void *inClientData,
                            AudioFileStreamID inAudioFileStream,
                            AudioFileStreamPropertyID inPropertyID,
                            UInt32 *ioFlags);

void MyAudioQueueOutputCallback(void*					inClientData,
                                AudioQueueRef			inAQ,
                                AudioQueueBufferRef		inBuffer);

void MyAudioQueueIsRunningCallback(void* inClientData,
                                   AudioQueueRef		inAQ,
                                   AudioQueuePropertyID	inID);

int MyFindQueueBuffer(MyData* myData, AudioQueueBufferRef inBuffer)
{
    for (unsigned int i = 0; i < kNumAQBufs; ++i) {
        if (inBuffer == myData.audioQueueBuffer[i])
            return i;
    }
    return -1;
}

void MyPacketsProc(void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions);

@interface AACDecoder ()
{
    MyData *myData;
}

@end

@implementation AACDecoder

- (instancetype)init
{
    self = [super init];
    if (self) {
        myData = [MyData new];
        
    }
    return self;
}
@end


@implementation MyData


-(void)dealloc
{
    AudioFileStreamClose(_audioFileStream);
    AudioQueueDispose(_audioQueue, false);
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
        if (err) { NSLog(@"AudioFileStreamOpen");  }
        
        
        CMAudioFormatDescriptionRef audio_fmt_desc_;
        
        
        ////////////////////////////////////////////////////
        
        AudioStreamBasicDescription audioFormat;
        
        bzero(&audioFormat, sizeof(audioFormat));
        
        audioFormat.mSampleRate = nSampleRate;
        
        audioFormat.mFormatID = kAudioFormatLinearPCM;
        
        audioFormat.mFramesPerPacket = 1;
        
        audioFormat.mChannelsPerFrame = 1;
        
        int bytes_per_sample = sizeof(short);
        
        audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        
        audioFormat.mBitsPerChannel = bytes_per_sample * 8;
        
        audioFormat.mBytesPerPacket = bytes_per_sample * 1;
        
        audioFormat.mBytesPerFrame = bytes_per_sample * 1;
        
        
        CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &audioFormat, 0, NULL, 0, NULL, NULL, &audio_fmt_desc_);
        
        uint32_t _lengthCreateSample = 8192 * sizeof(short) * 1;
    }
    return self;
}



- (void)decoderStreamWithData:(NSData *)aacData
{
    
   OSStatus s = AudioFileStreamParseBytes(_audioFileStream,
                              (UInt32)aacData.length,
                              aacData.bytes,
                              0);
    if (s) {
        AudioQueueFlush(self.audioQueue);
        AudioQueueStop(self.audioQueue, false);
    }
}
- (CMSampleBufferRef)createAudioBuffer:(NSData *)sample_data
                           sampleCount:(size_t)sample_position_
                          channelCount:(size_t)nchans
{
    OSStatus status;
    CMBlockBufferRef bbuf = NULL;
    CMSampleBufferRef sbuf = NULL;
    short *samples = (short *)sample_data.bytes;
    
    size_t buflen = (_lengthCreateSample / 2) * nchans * sizeof(short);
    buflen = sample_data.length;
    // Create sample buffer for adding to the audio input.
    status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, samples, buflen, kCFAllocatorNull, NULL, 0, buflen,
                                                0, &bbuf);
    
    if (status != noErr)
    {
        NSLog(@"CMBlockBufferCreateWithMemoryBlock error");
        return NULL;
    }
    
    CMTime timestamp = CMTimeMake(sample_position_ / nchans, nSampleRate);
    
    status = CMAudioSampleBufferCreateWithPacketDescriptions(kCFAllocatorDefault, bbuf, TRUE, 0, NULL, audio_fmt_desc_,
                                                             sample_data.length / nchans / sizeof(short), timestamp,
                                                             NULL, &sbuf);
    if (status != noErr)
    {
        NSLog(@"CMSampleBufferCreate error");
        return NULL;
    }
    
    CFRelease(bbuf);
    
    return sbuf;
    
}


@end

//OSStatus MyEnqueueBuffer(MyData* myData)
//{
//    OSStatus err = noErr;
//    myData->inuse[myData.fillBufferIndex] = true;		// set in use flag
//    
//    // enqueue buffer
//    AudioQueueBufferRef fillBuf = myData.audioQueueBuffer[myData.fillBufferIndex];
//    fillBuf->mAudioDataByteSize = myData.bytesFilled;
//    err = AudioQueueEnqueueBuffer(myData.audioQueue,
//                                  fillBuf,
//                                  myData.packetsFilled,
//                                  myData->packetDescs);
//    if (err) { return err; }
//    
//    StartQueueIfNeeded(myData);
//    
//    return err;
//}


void MyPropertyListenerProc(void *inClientData,
                            AudioFileStreamID inAudioFileStream,
                            AudioFileStreamPropertyID inPropertyID,
                            UInt32 *ioFlags)
{
    // this is called by audio file stream when it finds property values
    MyData* myData = (__bridge MyData*)inClientData;
    OSStatus err = noErr;
    
//    NSLog(@"found property '%c%c%c%c'\n", (inPropertyID>>24)&255, (inPropertyID>>16)&255, (inPropertyID>>8)&255, inPropertyID&255);
    
    switch (inPropertyID) {
        case kAudioFileStreamProperty_ReadyToProducePackets :
        {
            // the file stream parser is now ready to produce audio packets.
            // get the stream format.
            AudioStreamBasicDescription asbd;
            UInt32 asbdSize = sizeof(asbd);
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
            if (err) {  myData.failed = true; break; }
        
            err = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, (__bridge void *)(myData), NULL, NULL, 0, myData.audioQueue);
            if (err) {myData.failed = true; break; }
            
            // allocate audio queue buffers
            for (unsigned int i = 0; i < kNumAQBufs; ++i) {
                err = AudioQueueAllocateBuffer(myData.audioQueue, kAQBufSize, &myData.audioQueueBuffer[i]);
                if (err) {myData.failed = true; break; }
            }
            
            // get the cookie size
            UInt32 cookieSize;
            Boolean writable;
            err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
            if (err) {break; }
            printf("cookieSize %d\n", cookieSize);
            
            // get the cookie data
            void* cookieData = calloc(1, cookieSize);
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
            if (err) { free(cookieData); break; }
            
            // set the cookie on the queue.
            err = AudioQueueSetProperty(myData.audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
            free(cookieData);
            if (err) {break; }
            
            // listen for kAudioQueueProperty_IsRunning
            err = AudioQueueAddPropertyListener(myData.audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, (__bridge void * )(myData));
            if (err) { myData.failed = true; break; }
            
            break;
        }
    }
}
void MyPacketsProc(void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions)
{
    // this is called by audio file stream when it finds packets of audio
    MyData* myData = (__bridge MyData*)inClientData;
    printf("got data.  bytes: %d  packets: %d\n", inNumberBytes, inNumberPackets);
    
    for (int i = 0; i < inNumberPackets; ++i) {
        SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
        SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
        
        // if the space remaining in the buffer is not enough for this packet, then enqueue the buffer.
        size_t bufSpaceRemaining = kAQBufSize - myData.bytesFilled;
        if (bufSpaceRemaining < packetSize) {
//            MyEnqueueBuffer(myData);
//            WaitForFreeBuffer(myData);
        }
        
        // copy data to the audio queue buffer
        AudioQueueBufferRef fillBuf = myData.audioQueueBuffer[myData.fillBufferIndex];
        memcpy((char*)fillBuf->mAudioData + myData.bytesFilled, (const char*)inInputData + packetOffset, packetSize);
        // fill out packet description
        myData->packetDescs[myData.packetsFilled] = inPacketDescriptions[i];
        myData->packetDescs[myData.packetsFilled].mStartOffset = myData.bytesFilled;
        // keep track of bytes filled and packets filled
        myData.bytesFilled += packetSize;
        myData.packetsFilled += 1;
        
        // if that was the last free packet description, then enqueue the buffer.
        size_t packetsDescsRemaining = kAQMaxPacketDescs - myData.packetsFilled;
        if (packetsDescsRemaining == 0) {
//            MyEnqueueBuffer(myData);
//            WaitForFreeBuffer(myData);
        }
    }	
}

void MyAudioQueueOutputCallback(void*					inClientData,
                                AudioQueueRef			inAQ,
                                AudioQueueBufferRef		inBuffer)
{
    // this is called by the audio queue when it has finished decoding our data.
    // The buffer is now free to be reused.
    MyData* myData = (__bridge MyData*)inClientData;
    
//    unsigned int bufIndex = MyFindQueueBuffer(myData, inBuffer);
//    
//    myData.inuse[bufIndex] = false;
}

void MyAudioQueueIsRunningCallback(void* inClientData,
                                   AudioQueueRef		inAQ,
                                   AudioQueuePropertyID	inID)
{
    MyData* myData = (__bridge MyData*)inClientData;
    
    UInt32 running;
    UInt32 size;
    OSStatus err = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size);
    if (err) { return; }
    
}

