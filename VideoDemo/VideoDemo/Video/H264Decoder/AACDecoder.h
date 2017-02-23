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

@interface AACDecoder : NSObject

- (CMSampleBufferRef)audioDecoder:(NSData *)aacData;

@end


