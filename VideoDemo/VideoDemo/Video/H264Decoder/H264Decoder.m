//
//  H264Decoder.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/18.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "H264Decoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration );

@implementation VideoPacket
- (instancetype)initWithSize:(NSInteger)size
{
    self = [super init];
    if (self) {
        self.buffer = malloc(size);
        self.size = size;
    }
    return self;
}

-(void)dealloc
{
    free(self.buffer);
}
@end

@interface H264Decoder ()
{
    uint8_t *_sps;
    NSInteger _spsSize;
    uint8_t *_pps;
    NSInteger _ppsSize;
    VTDecompressionSessionRef _deocderSession;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
}

@end

@implementation H264Decoder
-(void)dealloc
{
    if(_deocderSession) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    
    if(_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    
    free(_sps);
    free(_pps);
    _spsSize = _ppsSize = 0;
}

- (CMSampleBufferRef)decoderNALU:(NSData*)nalu
{
//    CVPixelBufferRef outputPixelBuffer = NULL;
    uint8_t buffer[512*1024];
    NSInteger size = nalu.length;
    [nalu getBytes:buffer length:size];
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void*)buffer, size,
                                                          kCFAllocatorNull,
                                                          NULL, 0, size,
                                                          0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {size};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription ,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        CFRelease(blockBuffer);
        return sampleBuffer;
    }else{
        return NULL;
    }

}

-(CMSampleBufferRef)decode:(NSData*)h264Data
{
    CMSampleBufferRef sampleBuffer = NULL;
    
    if(h264Data == nil) {
        return sampleBuffer;
    }
    
    uint8_t buffer[512*1024];
//    uint8_t * buffer = h264Data.bytes;
    NSInteger size = h264Data.length;
    [h264Data getBytes:buffer length:size];
    
    uint32_t nalSize = (uint32_t)(h264Data.length - 4);
    uint8_t *pNalSize = (uint8_t*)(&nalSize);
    buffer[0] = *(pNalSize + 3);
    buffer[1] = *(pNalSize + 2);
    buffer[2] = *(pNalSize + 1);
    buffer[3] = *(pNalSize);
    NSData *newdata = [NSData dataWithBytes:buffer length:size];
    
    int nalType = buffer[4] & 0x1F;
    switch (nalType) {
        case 0x05:
            NSLog(@"Nal type is IDR frame");
            if(_pps&&_sps&&[self initH264Decoder]) {
                sampleBuffer = [self decoderNALU:newdata];
            }
            break;
        case 0x07:
            NSLog(@"Nal type is SPS");
            _spsSize = size - 4;
            _sps = malloc(_spsSize);
            memcpy(_sps, buffer + 4, _spsSize);
            break;
        case 0x08:
            NSLog(@"Nal type is PPS");
            _ppsSize = size - 4;
            _pps = malloc(_ppsSize);
            memcpy(_pps, buffer + 4, _ppsSize);
            break;
            
        default:
            NSLog(@"Nal type is B/P frame");
            if(_pps&&_sps&&[self initH264Decoder]) {
                sampleBuffer = [self decoderNALU:newdata];
            }
            
            break;
    }
    
    return sampleBuffer;
    
}

-(BOOL)initH264Decoder {
    if(_deocderSession) {
        return YES;
    }
    
    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { _spsSize, _ppsSize };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    
    if(status == noErr) {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
        //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
        //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
        attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decoderFormatDescription,
                                              NULL, attrs,
                                              &callBackRecord,
                                              &_deocderSession);
        CFRelease(attrs);
    } else {
        NSLog(@"IOS8VT: reset decoder session failed status=%d", status);
    }
    
    return YES;
}

@end

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

