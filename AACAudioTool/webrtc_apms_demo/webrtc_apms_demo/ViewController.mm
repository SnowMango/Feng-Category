//
//  ViewController.m
//  webrtc_apms_demo
//
//  Created by CaoZhihui on 16/8/11.
//  Copyright © 2016年 Ulucu. All rights reserved.
//

#import "ViewController.h"
#import "ApmWrapper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     FILE* infile = fopen("D:\\micsrc.pcm", "rb");
     FILE* outfile = fopen("des.pcm", "wb");
     unsigned char *input = new unsigned char[960 * sizeof(int16_t)+1];
     ApmBase *ap;
     ApmCreate(&ap);
     ap->ApmInit();
     while (fread(input,sizeof(int16_t),960,infile))
     {
     ap->ApmProcess(input, 1920);
     fwrite(ap->getOutputData(), sizeof(int16_t), 960, outfile);
     fflush(outfile);
     }
     fclose(outfile);
     fclose(infile);
     system("pause");
     return 0;
     
     
     */
#if !TARGET_OS_SIMULATOR
    
    //get temp file full path
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *document_path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *temp_directory = NSTemporaryDirectory();
    NSString *save_dir = [NSString stringWithFormat:@"%@/AudioProcess", [document_path objectAtIndex:0]];
    if(![file_manager fileExistsAtPath:save_dir]) {
        [file_manager createDirectoryAtPath:save_dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *name = [NSString stringWithFormat:@"micsrc.pcm"];
    NSString *finalPath = [path stringByAppendingPathComponent:name];
    
    NSData *audio_test_file_data = [NSData dataWithContentsOfFile:finalPath];
    NSString *file_full_path = [NSString stringWithFormat:@"%@/micsrc.pcm", save_dir];
    [audio_test_file_data writeToFile:file_full_path atomically:YES];
    
    NSString *write_file_full_path = [NSString stringWithFormat:@"%@/des.pcm", save_dir];
    
    FILE* infile = fopen([file_full_path UTF8String], "rb");
    FILE* outfile = fopen([write_file_full_path UTF8String], "wb");
#else
    FILE* infile = fopen("~/Desktop/micsrc.pcm", "rb");
    FILE* outfile = fopen("~/Desktop/des.pcm", "wb");
#endif
    unsigned char *input = new unsigned char[960 * sizeof(int16_t)+1];
    ApmBase *ap;
    ApmCreate(&ap);
    ap->ApmInit();
    while (fread(input,sizeof(int16_t),960,infile))
    {
        ap->ApmProcess(input, 1920);
        fwrite(ap->getOutputData(), sizeof(int16_t), 960, outfile);
        fflush(outfile);
    }
    fclose(outfile);
    fclose(infile);
    ////    system("pause");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
