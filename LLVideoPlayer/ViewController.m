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
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rzjt" ofType:@"MP4"];
    _fileURL = [NSURL fileURLWithPath:filePath];
}

- (IBAction)btn:(id)sender {
    LLVideoPlayerViewController *videoPlayerVC = [[LLVideoPlayerViewController alloc] initWithVideoUrl:_fileURL];
    [self presentViewController:videoPlayerVC animated:YES completion:nil];
}

@end
