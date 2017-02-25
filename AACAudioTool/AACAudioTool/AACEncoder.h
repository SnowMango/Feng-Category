//
//  AACEncoder.h
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@class AACEncoder;

@protocol AACEncoderDelegate <NSObject>

- (void)audioCompressionSession:(AACEncoder *)encoder didEncoderAACData:(NSData*)aacData;

@end

@interface AACEncoder : NSObject

@property (weak,nonatomic) id<AACEncoderDelegate> delegate;

@property (nonatomic) dispatch_queue_t delegateQueue;

-(void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end



