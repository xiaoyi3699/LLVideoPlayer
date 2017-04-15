//
//  LLVideoPlayerViewController.m
//  LLFoundation
//
//  Created by zhaomengWang on 2017/4/14.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLVideoPlayerViewController.h"
#import "LLAVPlayerView.h"
#import <CoreMotion/CoreMotion.h>

@interface LLVideoPlayerViewController ()<LLAVPlayerViewDelegate>{
    NSURL          *_videoUrl;
    LLAVPlayerView *_playerView;
}

@end

#define LL_SCREEN_BOUNDS  [UIScreen mainScreen].bounds
@implementation LLVideoPlayerViewController

- (instancetype)initWithVideoUrl:(NSURL *)videoUrl {
    self = [super init];
    if (self) {
        _videoUrl = videoUrl;
    }
    return self;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //监听横竖屏切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //监听程序进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
    
    //创建试图
    [self createViews];
}

- (void)createViews {
    _playerView = [[LLAVPlayerView alloc] initWithFrame:self.view.bounds];
    _playerView.delegate = self;
    [_playerView playWith:_videoUrl];
    [self.view addSubview:_playerView];
}

//横竖屏切换
- (void)orientationChanged:(NSNotification *)notification {
    if (_playerView == nil) return;
    UIDeviceOrientation currentOrientation = [UIDevice currentDevice].orientation;
    if (currentOrientation == UIDeviceOrientationFaceUp) return;
    static CGFloat rotation;
    if (currentOrientation == UIDeviceOrientationLandscapeLeft) {
        rotation = 0.5;
        _playerView.fullScreenBtn.selected = YES;
    }
    else if (currentOrientation == UIDeviceOrientationLandscapeRight) {
        rotation = -0.5;
        _playerView.fullScreenBtn.selected = YES;
    }
    else {
        rotation = 0;
        _playerView.fullScreenBtn.selected = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformMakeRotation(M_PI*(rotation));
            self.view.frame = LL_SCREEN_BOUNDS;
            _playerView.frame = self.view.bounds;
        }];
    });
}

//程序进入后台
- (void)applicationWillResignActive:(NSNotification *)notification {
    [_playerView pause];//暂停播放
}

#pragma mark - LLAVPlayerViewDelegate
- (void)goback {//返回按钮点击事件
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fullScreen:(UIButton *)btn {//全屏按钮点击事件
    CGFloat rotation;
    if (btn.selected) {
        rotation = 0;
        btn.selected = NO;
    }
    else {
        rotation = 0.5;
        btn.selected = YES;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformMakeRotation(M_PI*(rotation));
        self.view.frame = LL_SCREEN_BOUNDS;
        _playerView.frame = self.view.bounds;
    }];
}

- (void)dealloc {
    NSLog(@"playerViewController释放了,无内存泄漏");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
