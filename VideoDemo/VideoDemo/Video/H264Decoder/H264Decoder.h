//
//  H264Decoder.h
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/18.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef struct ZFNALUnit{
    unsigned int type;
    unsigned int size;
    unsigned char *data;
}NALUnit;

typedef enum{
    NALUTypeBPFrame = 0x01,
    NALUTypeIFrame = 0x05,
    NALUTypeSPS = 0x07,
    NALUTypePPS = 0x08
}NALUType;

@interface H264Decoder : NSObject

- (CVPixelBufferRef)deCompressedCMSampleBufferWithData:(NSData*)frameData;

- (CMSampleBufferRef)sampleBufferWithData:(NSData*)frameData;

@end

