//
//  AACAudioPlayer.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/24.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define QUEUE_BUFFER_SIZE 3   //队列缓冲个数
#define AUDIO_BUFFER_SIZE 1024 //数据区大小
#define MAX_PACKETS_COUNt 512 //数据包最大数

@interface AACAudioPlayer : NSObject

-(BOOL)start;
-(void)play:(NSData *)data;
-(void)stop;

@end
