//
//  AACDecoder.h
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
const int port = 51515;			// the port we will use

const unsigned int kNumAQBufs = 3;			// number of audio queue buffers we allocate
const size_t kAQBufSize = 128 * 1024;		// number of bytes in each audio queue buffer
const size_t kAQMaxPacketDescs = 512;		// number of packet descriptions in our array

@interface AACDecoder : NSObject

@end


@interface MyData : NSObject
{
    AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];
    AudioStreamPacketDescription packetDescs[kAQMaxPacketDescs];
    bool inuse[kNumAQBufs];
}

@property (nonatomic) AudioFileStreamID audioFileStream;
@property (nonatomic) AudioQueueRef audioQueue;
@property (nonatomic) AudioQueueBufferRef * audioQueueBuffer;

@property (nonatomic) unsigned int fillBufferIndex;
@property (nonatomic) size_t bytesFilled;

@property (nonatomic) size_t packetsFilled;
@property (nonatomic) bool started;
@property (nonatomic) bool failed;


@end
