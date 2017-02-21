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


@interface H264Decoder ()
{
    uint8_t *_sps;
    uint8_t *_pps;
    NSInteger _spsSize;
    NSInteger _ppsSize;
    
    int64_t mCurrentVideoSeconds;
    
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

- (CMSampleBufferRef)sampleBufferWithData:(NSData*)frameData
{
    NALUnit nalUnit;
    CMSampleBufferRef sampleBuffer = NULL;
    char *data = (char*)frameData.bytes;
    int dataLen = (int)frameData.length;
    
    if(data == NULL || dataLen == 0){
        return NULL;
    }
    while([self nalunitWithData:data andDataLen:dataLen toNALUnit:&nalUnit])
    {
        if(nalUnit.data == NULL || nalUnit.size == 0){
            return NULL;
        }
        
        sampleBuffer = NULL;
        [self infalteStartCodeWithNalunitData:&nalUnit];
        
        switch (nalUnit.type) {
            case NALUTypeIFrame://IFrame
                if(_sps && _pps)
                {
                    if([self initH264Decoder]){
                        sampleBuffer = [self decoderNALU:nalUnit];
                        NSLog(@"=== I ==Frame size:%d", nalUnit.size);
                        return sampleBuffer;
                    }
                }
                break;
            case NALUTypeSPS://SPS
                _spsSize = nalUnit.size - 4;
                if(_spsSize <= 0){
                    return NULL;
                }
                _sps = (uint8_t*)malloc(_spsSize);
                memcpy(_sps, nalUnit.data + 4, _spsSize);
                NSLog(@"=== SPS ===size:%d", nalUnit.size - 4);
                break;
            case NALUTypePPS://PPS
                _ppsSize = nalUnit.size - 4;
                if(_ppsSize <= 0){
                    return NULL;
                }
                _pps = (uint8_t*)malloc(_ppsSize);
                memcpy(_pps, nalUnit.data + 4, _ppsSize);
                NSLog(@"=== PPS ===size:%d", nalUnit.size - 4);
                break;
            case NALUTypeBPFrame://B/P Frame
                if(_sps && _pps)
                {
                    if([self initH264Decoder]){
                        sampleBuffer = [self decoderNALU:nalUnit];
                        NSLog(@"=== B/P ===Frame size:%d", nalUnit.size);
                        return sampleBuffer;
                    }
                }
            default:
                break;
        }
    }
    
    return NULL;
}

-(CVPixelBufferRef)deCompressedCMSampleBufferWithData:(NSData *)frameData
{
    NALUnit nalUnit;
    CVPixelBufferRef pixelBufferRef = NULL;
    char *data = (char*)frameData.bytes;
    int dataLen = (int)frameData.length;
    
    if(data == NULL || dataLen == 0){
        return NULL;
    }
    int offset = 0;
    while([self nalunitWithData:data andDataLen:dataLen toNALUnit:&nalUnit])
    {
        if(nalUnit.data == NULL || nalUnit.size == 0){
            return NULL;
        }
        
        pixelBufferRef = NULL;
        [self infalteStartCodeWithNalunitData:&nalUnit];
        
        switch (nalUnit.type) {
            case NALUTypeIFrame://IFrame
                if(_sps && _pps)
                {
                    if([self initH264Decoder]){
//                        pixelBufferRef = [self decompressWithNalUint:nalUnit];
                        NSLog(@"=== I ==Frame size:%d", nalUnit.size);
                        return pixelBufferRef;
                    }
                }
                break;
            case NALUTypeSPS://SPS
                _spsSize = nalUnit.size - 4;
                if(_spsSize <= 0){
                    return NULL;
                }
                _sps = (uint8_t*)malloc(_spsSize);
                memcpy(_sps, nalUnit.data + 4, _spsSize);
                NSLog(@"=== SPS ===size:%d", nalUnit.size - 4);
                break;
            case NALUTypePPS://PPS
                _ppsSize = nalUnit.size - 4;
                if(_ppsSize <= 0){
                    return NULL;
                }
                _pps = (uint8_t*)malloc(_ppsSize);
                memcpy(_pps, nalUnit.data + 4, _ppsSize);
                NSLog(@"=== PPS ===size:%d", nalUnit.size - 4);
                break;
            case NALUTypeBPFrame://B/P Frame
                if(_sps && _pps)
                {
                    if([self initH264Decoder]){
                        pixelBufferRef = [self decompressWithNalUint:nalUnit];
                        NSLog(@"=== B/P ===Frame size:%d", nalUnit.size);
                        return pixelBufferRef;
                    }
                }
            default:
                break;
        }
        
        offset += nalUnit.size;
        if(offset >= dataLen){
            return NULL;
        }
    }

    return NULL;
}

-(void)infalteStartCodeWithNalunitData:(NALUnit *)dataUnit
{
    //Inflate start code with data length
    unsigned char* data  = dataUnit->data;
    unsigned int dataLen = dataUnit->size - 4;
    
    data[0] = (unsigned char)(dataLen >> 24);
    data[1] = (unsigned char)(dataLen >> 16);
    data[2] = (unsigned char)(dataLen >> 8);
    data[3] = (unsigned char)(dataLen & 0xff);
}

-(int)nalunitWithData:(char *)data andDataLen:(int)dataLen toNALUnit:(NALUnit *)unit
{
    unit->size = 0;
    unit->data = NULL;
    
    int addUpLen = 0;
    while(addUpLen < dataLen)
    {
        if(data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x01){//H264 start code
            
            int pos = addUpLen;
            while(pos < dataLen){//Find next NALU
                if(data[pos++] == 0x00 &&
                   data[pos++] == 0x00 &&
                   data[pos++] == 0x00 &&
                   data[pos++] == 0x01){
                    
                    break;
                }
            }
            
            unit->type = data[addUpLen] & 0x1f;
            if(pos == dataLen){
                unit->size = pos - addUpLen + 4;
            }else{
                unit->size = pos - addUpLen;
            }
            
            unit->data = (unsigned char*)&data[addUpLen - 4];
            return 1;
        }
    }
    return -1;
}


-(CVPixelBufferRef)decompressWithNalUint:(NALUnit)dataUnit
{
    CMBlockBufferRef blockBufferRef = NULL;
    CVPixelBufferRef outputPixelBufferRef = NULL;
    
    //1.Fetch video data and generate CMBlockBuffer
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         dataUnit.data,
                                                         dataUnit.size,
                                                         kCFAllocatorNull,
                                                         NULL,
                                                         0,
                                                         dataUnit.size,
                                                         0,
                                                         &blockBufferRef);
    //2.Create CMSampleBuffer
    if(status == kCMBlockBufferNoErr){
        CMSampleBufferRef sampleBufferRef = NULL;
        const size_t sampleSizes[] = {dataUnit.size};
        OSStatus createStatus = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                          blockBufferRef,
                                                          _decoderFormatDescription,
                                                          1,
                                                          0,
                                                          NULL,
                                                          1,
                                                          sampleSizes,
                                                          &sampleBufferRef);
        
        //3.Create CVPixelBuffer
        if(createStatus == kCMBlockBufferNoErr && sampleBufferRef){
            VTDecodeFrameFlags frameFlags = 0;
            VTDecodeInfoFlags infoFlags = 0;
            
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                      sampleBufferRef,
                                                                      frameFlags,
                                                                      &outputPixelBufferRef,
                                                                      &infoFlags);
            
            if(decodeStatus != noErr){
                CFRelease(sampleBufferRef);
                CFRelease(blockBufferRef);
                outputPixelBufferRef = nil;
                return outputPixelBufferRef;
            }
            
            
            CFRelease(sampleBufferRef);
        }  
        CFRelease(blockBufferRef);  
    }  
    return outputPixelBufferRef;  
}


- (CMSampleBufferRef)decoderNALU:(NALUnit)dataUnit
{
    CMBlockBufferRef blockBufferRef = NULL;

    //1.Fetch video data and generate CMBlockBuffer
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         dataUnit.data,
                                                         dataUnit.size,
                                                         kCFAllocatorNull,
                                                         NULL,
                                                         0,
                                                         dataUnit.size,
                                                         0,
                                                         &blockBufferRef);
    //2.Create CMSampleBuffer
    if(status == kCMBlockBufferNoErr){
        CMSampleBufferRef sampleBufferRef = NULL;
        const size_t sampleSizes[] = {dataUnit.size};
        OSStatus createStatus = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                          blockBufferRef,
                                                          _decoderFormatDescription,
                                                          1,
                                                          0,
                                                          NULL,
                                                          1,
                                                          sampleSizes,
                                                          &sampleBufferRef);
        if(createStatus != noErr){
            CFRelease(sampleBufferRef);
            return NULL;
        }
        return sampleBufferRef;
    }else{
        return NULL;
    }

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

