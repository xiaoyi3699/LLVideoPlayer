//
//  ViewController.m
//  LLVideoPlayer
//
//  Created by WangZhaomeng on 2017/4/15.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "LLVideoPlayerViewController.h"

@interface ViewController (){
    NSURL *_fileURL;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //播放本地视频
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rzjt" ofType:@"MP4"];
    _fileURL = [NSURL fileURLWithPath:filePath];
    
//    //播放网络视频
//    NSString *filePath = @"http://oopas6scq.bkt.clouddn.com/video/rzjt.MP4";
//    _fileURL = [NSURL URLWithString:filePath];
//    if (_fileURL == nil) {
//        _fileURL = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    }
}

- (IBAction)btn:(id)sender {
    LLVideoPlayerViewController *videoPlayerVC = [[LLVideoPlayerViewController alloc] initWithVideoUrl:_fileURL];
    [self presentViewController:videoPlayerVC animated:YES completion:nil];
}

@end
