//
//  AACEncoder.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/22.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "AACEncoder.h"


static OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData);

@interface AACEncoder ()
//音频转换器
@property (nonatomic) AudioConverterRef audioConverter;
//aac缓冲区
@property (nonatomic) uint8_t *aacBuffer;

//缓冲区大小
@property (nonatomic) NSUInteger aacBufferSize;

//pcm缓冲区
@property (nonatomic) char *pcmBuffer;

//pcm缓冲区大小
@property (nonatomic) size_t pcmBufferSize;

@property (nonatomic) dispatch_queue_t encoderQueue;

@end

@implementation AACEncoder
-(void)dealloc{
    AudioConverterDispose(_audioConverter);
    free(_aacBuffer);
}

-(instancetype)init{
    
    if (self = [super init]) {
        //创建队列
        _encoderQueue = dispatch_queue_create("AAC Encoder Queue", DISPATCH_QUEUE_SERIAL);
        _delegateQueue = dispatch_get_main_queue();
        _audioConverter = NULL;
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _aacBufferSize = 1024;
        _aacBuffer = malloc(_aacBufferSize * sizeof(uint8_t));
        memset(_aacBuffer, 0, _aacBufferSize);
    }
    
    return self;
}

-(void)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CFRetain(sampleBuffer);
    dispatch_async(_encoderQueue, ^{
        if (!_audioConverter) {
            [self setupEncoderFromSampleBuffer:sampleBuffer];
        }
        // 编码后的图像，以CMBlockBuffe方式存储

        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        
        OSStatus blockStatus = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, &_pcmBuffer);
        NSError *error = nil;
        if (blockStatus != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:blockStatus userInfo:nil];
        }
        memset(_aacBuffer, 0, _aacBufferSize);

        //一个可变长度的audiobuffer结构阵列。
        AudioBufferList outAudioBufferList = {0};
        //mBuffers数量
        outAudioBufferList.mNumberBuffers = 1;
        //缓冲区中的交错信道的数目。
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        //缓冲区编码大小
        outAudioBufferList.mBuffers[0].mDataByteSize = (int)_aacBufferSize;
        //数据
        outAudioBufferList.mBuffers[0].mData = _aacBuffer;
        //这种结构描述了数据包布局的一个缓冲区的数据大小,每个包可能不是相同的或有外部数据之间的小包.
        AudioStreamPacketDescription *outPacketDescription = NULL;
        UInt32 ioOutputDataPacketSize = 1;
        OSStatus status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
        
        //aac data
        NSData *data = nil;
        if (status == 0) {
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            //adts头
            NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            //拼接
            NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            data = fullData;
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        if (self.delegate) {
            dispatch_async(_delegateQueue, ^{
                [self.delegate audioCompressionSession:self didEncoderAACData:data];;
            });
        }

        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
    });
}

//根据音频初始化编码器
-(void)setupEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 初始化输出流的结构体描述
    AudioStreamBasicDescription outAudioStreamDes = [self  outAudioStreamDescription];
    //输入音频流描述
    AudioStreamBasicDescription inAudioStreamDes = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    // 音频流，在正常播放情况下的帧率。如果是压缩的格式，这个属性表示解压缩后的帧率。帧率不能为0。
    outAudioStreamDes.mSampleRate = inAudioStreamDes.mSampleRate;
    //软编 kAppleSoftwareAudioCodecManufacturer
    //硬编 kAppleHardwareAudioCodecManufacturer
    AudioClassDescription *description =
    [self audioClassDescriptionWithType:kAudioFormatMPEG4AAC
                       fromManufacturer:kAppleSoftwareAudioCodecManufacturer];
    
    // 创建转换器
    OSStatus status = AudioConverterNewSpecific(&inAudioStreamDes,
                                                &outAudioStreamDes,
                                                1,
                                                description,
                                                &_audioConverter);
    if (status != 0) {
        NSLog(@"setup converter: %d", (int)status);
    }
}



- (AudioStreamBasicDescription)outAudioStreamDescription
{
    // 初始化输出流的结构体描述为0. 很重要。
    AudioStreamBasicDescription outAudioStreamDescrip = {0};
    // 设置编码格式
    outAudioStreamDescrip.mFormatID = kAudioFormatMPEG4AAC;
    // 无损编码 ，0表示没有
    outAudioStreamDescrip.mFormatFlags = kMPEG4Object_AAC_LC;
    // 每一个packet的音频数据大小。如果的动态大小，设置为0。动态大小的格式，需要用AudioStreamPacketDescription 来确定每个packet的大小。
    outAudioStreamDescrip.mBytesPerPacket = 0;
    //每个packet的帧数。如果是未压缩的音频数据，值是1。动态帧率格式，这个值是一个较大的固定数字，比如说AAC的1024。如果是动态大小帧数（比如Ogg格式）设置为0。
    outAudioStreamDescrip.mFramesPerPacket = 1024;
    //  每帧的大小。每一帧的起始点到下一帧的起始点。如果是压缩格式，设置为0 。
    outAudioStreamDescrip.mBytesPerFrame = 0;
    // 声道数
    outAudioStreamDescrip.mChannelsPerFrame = 1;
    // 压缩格式设置为0
    outAudioStreamDescrip.mBitsPerChannel = 0;
    // 8字节对齐，填0.
    outAudioStreamDescrip.mReserved = 0;
    return outAudioStreamDescrip;
}

- (AudioClassDescription *)audioClassDescriptionWithType:(UInt32)type
                                           fromManufacturer:(UInt32)manufacturer
{
    static AudioClassDescription desc;
    UInt32 encoderSpecifier = type;
    UInt32 size;
    /**
      属性的信息
      kAudioFormatProperty_Encoders 音频格式属性ID
      encoderSpecifier 大小
      encoderSpecifier 说明符是用作某些属性的输入参数的数据的缓冲区。
      size 属性当前值的大小
     */
    OSStatus infoSt =
    AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                    sizeof(encoderSpecifier),
                                    &encoderSpecifier,
                                    &size);
    if (infoSt) {
        NSLog(@"error getting audio format propery info: %d", (int)(infoSt));
        return nil;
    }
    unsigned int count = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[count];
    /**
     属性数据
     */
    OSStatus st =
    AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                sizeof(encoderSpecifier),
                                &encoderSpecifier,
                                &size,
                                descriptions);
    if (st) {
        NSLog(@"error getting audio format propery: %d", (int)(st));
        return nil;
    }
    for (unsigned int i = 0; i < count; i++) {
        if ((type == descriptions[i].mSubType) &&
            (manufacturer == descriptions[i].mManufacturer)) {
            memcpy(&desc, &(descriptions[i]), sizeof(desc));
            return &desc;
        }
    }
    return nil;
}

- (NSData*)adtsDataForPacketLength:(NSUInteger)packetLength {
    
    //adts头是一个7字节的数据
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    
    // Variables Recycled by addADTStoPacket
    //表示使用哪个级别的AAC，有些芯片只支持AAC LC
    int profile = 2;  //AAC LC
    /**
     0~12 越小采样频率越高 96000HZ~7350HZ。13、14保留参数。15: frequency is written explictly
     */
    int freqIdx = 4;  //44.1KHz
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF; // 11111111     = syncword
    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}


/**
 *  填充PCM到缓冲区
 */
- (size_t) copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
    size_t originalBufferSize = _pcmBufferSize;
    if (!originalBufferSize) {
        return 0;
    }
    ioData->mBuffers[0].mData = _pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = (int)_pcmBufferSize;
    _pcmBuffer = NULL;
    _pcmBufferSize = 0;
    return originalBufferSize;
}

@end

/**
 *  提供音频数据转换的回调函数。 当转换器准备好输入新数据时，将重复调用此回调。
 
 */
static OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    AACEncoder *encoder = (__bridge AACEncoder *)(inUserData);
    UInt32 requestedPackets = *ioNumberDataPackets;
    
    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData];
    if (copiedSamples < requestedPackets) {
        //PCM 缓冲区还没满
        *ioNumberDataPackets = 0;
        return -1;
    }
    *ioNumberDataPackets = 1;
    
    return noErr;
}
