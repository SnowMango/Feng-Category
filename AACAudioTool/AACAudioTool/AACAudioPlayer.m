//
//  AACAudioPlayer.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/24.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "AACAudioPlayer.h"
#import <pthread.h>

static pthread_mutex_t mutex;
static pthread_cond_t cond;
static pthread_cond_t done;

static void DecoderPacketsProc(void *							inClientData,
                               UInt32							inNumberBytes,
                               UInt32							inNumberPackets,
                               const void *                     inInputData,
                               AudioStreamPacketDescription	*inPacketDescriptions);

static void DecoderPropertyListenerProc(void *inClientData,
                                        AudioFileStreamID inAudioFileStream,
                                        AudioFileStreamPropertyID inPropertyID,
                                        UInt32 *ioFlags);

void MyAudioQueueOutputCallback(void*					inClientData,
                                AudioQueueRef			inAQ,
                                AudioQueueBufferRef		inBuffer);

void MyAudioQueueIsRunningCallback(void*					inClientData,
                                   AudioQueueRef			inAQ,
                                   AudioQueuePropertyID	 inID);


@protocol AudioStreamDecoderDelegate <NSObject>

- (void)audioListenerReadyToPro:(AudioFileStreamPropertyID)propertyID fileStream:(AudioFileStreamID)stream;

- (void)audioDecoderPackets:(AudioStreamPacketDescription *)inPacketDescriptions bytes:(UInt32)numberBytes numberPackets:(UInt32)numberPackets input:(void*)inputData;

@end


@interface AACAudioPlayer()<AudioStreamDecoderDelegate>
{
    AudioQueueBufferRef audioQueueBuffer[QUEUE_BUFFER_SIZE];
    AudioStreamPacketDescription packetDescs[MAX_PACKETS_COUNt];
    bool inuse[QUEUE_BUFFER_SIZE];
}
@property (nonatomic) BOOL  autoDecoder;

@property (nonatomic) AudioFileStreamID audioFileStream;
@property (nonatomic) AudioQueueRef audioQueue;

@property (nonatomic) unsigned int fillBufferIndex;
@property (nonatomic) size_t bytesFilled;

@property (nonatomic) size_t packetsFilled;
@property (nonatomic) bool started;
@end

@implementation AACAudioPlayer
-(void)dealloc
{
    [self stop];
    AudioFileStreamClose(_audioFileStream);
    AudioQueueDispose(_audioQueue, false);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        OSStatus err =
        AudioFileStreamOpen((__bridge void*)self,
                            DecoderPropertyListenerProc,
                            DecoderPacketsProc,
                            kAudioFileAAC_ADTSType,
                            &_audioFileStream);
        if (err) { NSLog(@"AudioFileStream Open Fail");  }
        self.autoDecoder = YES;
        pthread_mutex_init(&mutex, NULL);
        pthread_cond_init(&cond, NULL);
        pthread_cond_init(&done, NULL);
    }
    return self;
}

-(void)handlerOutputAudioQueue:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer
{
    unsigned int bufIndex = [self findQueueBuffer:inBuffer];
    // signal waiting thread that the buffer is free.
    pthread_mutex_lock(&mutex);
    inuse[bufIndex] = false;
    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mutex);
}


- (void)audioListenerReadyToPro:(AudioFileStreamPropertyID)propertyID fileStream:(AudioFileStreamID)streamID
{
    if (propertyID != kAudioFileStreamProperty_ReadyToProducePackets) {
        return;
    }
    AudioStreamBasicDescription asbd;
    OSStatus err = noErr;
    
    UInt32 asbdSize = sizeof(asbd);
    err = AudioFileStreamGetProperty(streamID, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
    if (err) {
        NSLog(@"get kAudioFileStreamProperty_DataFormat");
        return;
    }

    err = AudioQueueNewOutput(&asbd,
                              MyAudioQueueOutputCallback,
                              (__bridge void *)(self),
                              NULL, NULL, 0,
                              &_audioQueue);
 
    if (err) {
        NSLog(@"get AudioQueueNewOutput");
        return;
    }
    
    for (unsigned int i = 0; i < QUEUE_BUFFER_SIZE; ++i) {
//        AudioQueueBufferRef queueBuffer;
        err = AudioQueueAllocateBuffer(self.audioQueue, AUDIO_BUFFER_SIZE, &audioQueueBuffer[i]);

        if (err) {
            NSLog(@"AudioQueueBufferRef %d", i);
            return;
        }
        
    }
    // get the cookie size
    UInt32 cookieSize;
    Boolean writable;
    err = AudioFileStreamGetPropertyInfo(streamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
    if (err) { NSLog(@"info kAudioFileStreamProperty_MagicCookieData"); return; }
    printf("cookieSize %d\n", cookieSize);
    
    // get the cookie data
    void* cookieData = calloc(1, cookieSize);
    err = AudioFileStreamGetProperty(streamID, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
    if (err) { NSLog(@"get kAudioFileStreamProperty_MagicCookieData"); free(cookieData); return; }
    
    // set the cookie on the queue.
    err = AudioQueueSetProperty(self.audioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
    free(cookieData);
    if (err) { NSLog(@"set kAudioQueueProperty_MagicCookie"); return; }
    
    // listen for kAudioQueueProperty_IsRunning
    err = AudioQueueAddPropertyListener(self.audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, (__bridge void *)(self));
    if (err) { NSLog(@"AudioQueueAddPropertyListener"); return; }
}

- (void)audioDecoderPackets:(AudioStreamPacketDescription *)inPacketDescriptions bytes:(UInt32)numberBytes numberPackets:(UInt32)numberPackets input:(void*)inputData
{
    NSLog(@"got data.  bytes: %d  packets: %d\n", numberBytes, numberPackets);
    for (int i = 0; i < numberPackets; ++i) {
        SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
        SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
        size_t bufSpaceRemaining = AUDIO_BUFFER_SIZE - self.bytesFilled;
        if (bufSpaceRemaining < packetSize) {
            [self enqueueBuffer];
            [self waitForFreeBuffer];
        }
        
        AudioQueueBufferRef fillBuf = audioQueueBuffer[self.fillBufferIndex];
        memcpy((char*)fillBuf->mAudioData + self.bytesFilled, (const char*)inputData + packetOffset, packetSize);
        // fill out packet description
        packetDescs[self.packetsFilled] = inPacketDescriptions[i];
        packetDescs[self.packetsFilled].mStartOffset = self.bytesFilled;
        // keep track of bytes filled and packets filled
        self.bytesFilled += packetSize;
        self.packetsFilled += 1;
        
        // if that was the last free packet description, then enqueue the buffer.
        size_t packetsDescsRemaining = MAX_PACKETS_COUNt - self.packetsFilled;
        if (packetsDescsRemaining == 0) {
            [self enqueueBuffer];
            [self waitForFreeBuffer];
        }
    }
}

-(BOOL)start{
    return ![self startQueueIfNeeded];
}

-(void)play:(NSData *)aacData{
    if (self.autoDecoder) {
        OSStatus err = AudioFileStreamParseBytes(_audioFileStream,
                                                 (UInt32)aacData.length,
                                                 aacData.bytes,
                                                 0);
        if (err) { NSLog(@"AudioFileStream Parse Fail");  }
    }else{
        OSStatus err = noErr;
        inuse[self.fillBufferIndex] = true;
        AudioQueueBufferRef fillBuf = audioQueueBuffer[self.fillBufferIndex];
        fillBuf->mAudioDataByteSize = (UInt32)self.bytesFilled;
        err = AudioQueueEnqueueBuffer(self.audioQueue, fillBuf, (UInt32)self.packetsFilled, packetDescs);
        if (err) { return; }
        [self startQueueIfNeeded];
        
    }
}

-(void)stop{
    
    self.fillBufferIndex = 0;
    self.bytesFilled = 0;
    self.packetsFilled = 0;
    self.started = false;
    
    AudioQueueFlush(self.audioQueue);
    AudioQueueStop(self.audioQueue, false);
}



- (void)waitForFreeBuffer
{
    // go to next buffer
    if (++self.fillBufferIndex >= QUEUE_BUFFER_SIZE) self.fillBufferIndex = 0;
    self.bytesFilled = 0;		// reset bytes filled
    self.packetsFilled = 0;		// reset packets filled
    
    // wait until next buffer is not in use
    pthread_mutex_lock(&mutex);
    while (inuse[self.fillBufferIndex]) {
        printf("... WAITING ...\n");
        pthread_cond_wait(&cond, &mutex);
    }
    pthread_mutex_unlock(&mutex);

}
- (OSStatus)startQueueIfNeeded
{
    OSStatus err = noErr;
    if (!self.started) {		// start the queue if it has not been started already
        err = AudioQueueStart(self.audioQueue, NULL);
        if (err) {return err; }
        self.started = true;
    }
    return err;
}

- (OSStatus)enqueueBuffer
{
    OSStatus err = noErr;
    inuse[self.fillBufferIndex] = true;// set in use flag
    
    AudioQueueBufferRef fillBuf = audioQueueBuffer[self.fillBufferIndex];
    fillBuf->mAudioDataByteSize = (UInt32)self.bytesFilled;
    err = AudioQueueEnqueueBuffer(self.audioQueue, fillBuf, (UInt32)self.packetsFilled, packetDescs);
    if (err) {return err; }
    
    [self startQueueIfNeeded];
    return err;
}

-(int)findQueueBuffer:(AudioQueueBufferRef)inBuffer
{
    for (unsigned int i = 0; i < QUEUE_BUFFER_SIZE; ++i) {
        if (inBuffer == audioQueueBuffer[i])
            return i;
    }
    return -1;
}

@end

void MyAudioQueueOutputCallback(void*					inClientData,
                                AudioQueueRef			inAQ,
                                AudioQueueBufferRef		inBuffer)
{
    // this is called by the audio queue when it has finished decoding our data.
    // The buffer is now free to be reused.
    AACAudioPlayer *player = (__bridge AACAudioPlayer *)(inClientData);
    [player handlerOutputAudioQueue:inAQ inBuffer:inBuffer];
}

void MyAudioQueueIsRunningCallback(void*					inClientData,
                                   AudioQueueRef			inAQ,
                                   AudioQueuePropertyID	 inID)
{
    
    UInt32 running;
    UInt32 size;
    OSStatus err = AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &running, &size);
    if (err) { return; }
    if (!running) {
        pthread_mutex_lock(&mutex);
        pthread_cond_signal(&done);
        pthread_mutex_unlock(&mutex);
    }
}

static void DecoderPacketsProc(void *							inClientData,
                               UInt32							inNumberBytes,
                               UInt32							inNumberPackets,
                               const void *                     inInputData,
                               AudioStreamPacketDescription	*inPacketDescriptions)
{
    id <AudioStreamDecoderDelegate>decoder = (__bridge id )inClientData;
    [decoder audioDecoderPackets:inPacketDescriptions
                           bytes:inNumberBytes
                   numberPackets:inNumberPackets
                           input:(void *)inInputData];
}

static void DecoderPropertyListenerProc(void *inClientData,
                                        AudioFileStreamID inAudioFileStream,
                                        AudioFileStreamPropertyID inPropertyID,
                                        UInt32 *ioFlags)
{
    id <AudioStreamDecoderDelegate>decoder = (__bridge id )inClientData;
    [decoder audioListenerReadyToPro:inPropertyID
                          fileStream:inAudioFileStream];
}


