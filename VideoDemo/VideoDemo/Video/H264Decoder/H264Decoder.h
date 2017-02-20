//
//  H264Decoder.h
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/18.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface H264Decoder : NSObject
-(CMSampleBufferRef)decode:(NSData*)h264Data;

@end

@interface VideoPacket : NSObject

@property uint8_t* buffer;
@property NSInteger size;

@end
