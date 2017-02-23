//
//  MyData.h
//  AudioFileStreamExample
//
//  Created by zhengfeng on 17/2/23.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

const unsigned int kNumAQBufs = 3;			// number of audio queue buffers we allocate
const size_t kAQBufSize = 128 * 1024;		// number of bytes in each audio queue buffer
const size_t kAQMaxPacketDescs = 512;		// number of packet descriptions in our array

@interface MyData : NSObject

@property (nonatomic) AudioFileStreamID audioFileStream;
@property (nonatomic) AudioQueueRef audioQueue;
@property (nonatomic) AudioQueueBufferRef * audioQueueBuffer;
@property (nonatomic) AudioStreamPacketDescription * packetDescs;
@property (nonatomic) bool * inuse;

@property (nonatomic) unsigned int fillBufferIndex;
@property (nonatomic) size_t bytesFilled;

@property (nonatomic) size_t packetsFilled;
@property (nonatomic) bool started;
@property (nonatomic) bool failed;

@end
