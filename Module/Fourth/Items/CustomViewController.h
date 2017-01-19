//
//  CustomViewController.h
//  DemoDev
//
//  Created by 郑丰 on 2017/1/19.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface CustomViewController : UIViewController < AVCaptureVideoDataOutputSampleBufferDelegate>
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@end
