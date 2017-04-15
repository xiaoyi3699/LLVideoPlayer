//
//  PlayView.m
//  LLAVPlayer
//
//  Created by zhaomengWang on 2017/4/13.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLAVPlayerView.h"
#import "UIImage+LLAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, LLDirection) {
    LLDirectionNone = 0,
    LLDirectionHrizontal,    //水平方向滑动
    LLDirectionVertical,     //垂直方向滑动
};

@interface LLAVPlayerView (){
    UIView   *_topView;
    UIView   *_toolView;
    AVPlayer *_player;
    UISlider *_progressSlider;
    UILabel  *_currentTime;
    UILabel  *_totalTime;
    UIButton *_playBtn;
}


@property (nonatomic, assign) LLDirection direction;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat startVB;
@property (nonatomic, assign) CGFloat startVideoRate;
@property (nonatomic, assign) CGFloat dur;
@property (nonatomic, strong) MPVolumeView *volumeView;    //控制音量的view
@property (nonatomic, strong) UISlider *volumeViewSlider;  //控制音量
@property (nonatomic, strong) UISlider *brightnessSlider;  //控制亮度

@end

#define R_G_B(_r_,_g_,_b_)          \
[UIColor colorWithRed:_r_/255. green:_g_/255. blue:_b_/255. alpha:1.0]
#define R_G_B_A(_r_,_g_,_b_,_a_)    \
[UIColor colorWithRed:_r_/255. green:_g_/255. blue:_b_/255. alpha:_a_]
@implementation LLAVPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViewsWithFrame:frame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)playWith:(NSURL *)url
{
    //加载视频资源的类
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    //AVURLAsset 通过tracks关键字会将资源异步加载在程序的一个临时内存缓冲区中
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        //能够得到资源被加载的状态
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:nil];
        //如果资源加载完成,开始进行播放
        if (status == AVKeyValueStatusLoaded) {
            //将加载好的资源放入AVPlayerItem 中，item中包含视频资源数据,视频资源时长、当前播放的时间点等信息
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            _player = [[AVPlayer alloc] initWithPlayerItem:item];
            //将播放器与播放视图关联
            [self setPlayer:_player];
            [_player play];
            //需要时时显示播放的进度
            //根据播放的帧数、速率，进行时间的异步(在子线程中完成)获取
            __weak AVPlayer *weakPlayer     = _player;
            __weak UISlider *weakSlider     = _progressSlider;
            __weak UILabel *weakCurrentTime = _currentTime;
            __weak UILabel *weakTotalTime   = _totalTime;
            __weak typeof(self) weakSelf    = self;
            [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
                //获取当前播放时间
                NSInteger current = CMTimeGetSeconds(weakPlayer.currentItem.currentTime);
                //总时间
                weakSelf.dur = CMTimeGetSeconds(weakPlayer.currentItem.duration);
                
                float pro = current*1.0/weakSelf.dur;
                if (pro >= 0.0 && pro <= 1.0) {
                    //回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSlider.value     = pro;
                        weakCurrentTime.text = [weakSelf getTime:current];
                        weakTotalTime.text   = [weakSelf getTime:weakSelf.dur];
                    });
                }
            }];
        }
    }];
}

//暂停
- (void)pause {
    [self playBtnClick:_playBtn];
}

//创建相关UI
-(void)createViewsWithFrame:(CGRect)frame
{
    self.backgroundColor=[UIColor blackColor];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGR:)];
    [self addGestureRecognizer:tapGR];
    
    self.volumeView.frame = CGRectMake(frame.size.width-30, (frame.size.height-100)/2.0, 20, 100);
    self.volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.volumeView.hidden = YES;
    [self addSubview:self.volumeView];
    
    self.brightnessSlider.frame = CGRectMake(20, (frame.size.height-100)/2.0, 20, 100);
    self.brightnessSlider.minimumValue = 0.0;
    self.brightnessSlider.maximumValue = 1.0;
    self.brightnessSlider.hidden = YES;
    [self.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    self.brightnessSlider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.brightnessSlider];
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    _topView.backgroundColor = R_G_B_A(50, 50, 50, .5);
    _topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_topView];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(10, 13, 50, 18)];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [backBtn setTitle:@" 返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_white_small"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:backBtn];
    
    //全屏按钮
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenBtn setFrame:CGRectMake(CGRectGetMaxX(_topView.frame)-40, 15, 35, 20)];
    fullScreenBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    fullScreenBtn.layer.masksToBounds = YES;
    fullScreenBtn.layer.cornerRadius = 3;
    fullScreenBtn.layer.borderColor = R_G_B(200, 200, 200).CGColor;
    fullScreenBtn.layer.borderWidth = 1;
    [fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
    [fullScreenBtn setTitle:@"还原" forState:UIControlStateSelected];
    [fullScreenBtn setTitleColor:R_G_B(200, 200, 200) forState:UIControlStateNormal];
    [fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    fullScreenBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_topView addSubview:fullScreenBtn];
    self.fullScreenBtn = fullScreenBtn;
    
    _toolView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height-40, frame.size.width, 40)];
    _toolView.backgroundColor = R_G_B_A(50, 50, 50, .5);
    _toolView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_toolView];
    
    //播放暂停按钮
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setFrame:CGRectMake(5,10,20,20)];
    _playBtn.selected=YES;
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:_playBtn];
    
    _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playBtn.frame), 10, 40, 20)];
    _currentTime.text = @"00:00";
    _currentTime.textColor = [UIColor whiteColor];
    _currentTime.font = [UIFont systemFontOfSize:8];
    _currentTime.textAlignment = NSTextAlignmentCenter;
    [_toolView addSubview:_currentTime];
    
    _progressSlider= [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_currentTime.frame),12.5,frame.size.width-CGRectGetMaxX(_currentTime.frame)-40,15)];
    _progressSlider.minimumValue = 0.0;
    _progressSlider.maximumValue = 1.0;
    [_progressSlider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(touchChange:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [_progressSlider setThumbImage:[UIImage getRoundImageWithColor:[UIColor whiteColor] size:CGSizeMake(15, 15)] forState:UIControlStateNormal];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolView addSubview:_progressSlider];
    
    _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_progressSlider.frame), 10, 40, 20)];
    _totalTime.text = @"00:00";
    _totalTime.textColor = [UIColor whiteColor];
    _totalTime.font = [UIFont systemFontOfSize:8];
    _totalTime.textAlignment = NSTextAlignmentCenter;
    _totalTime.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_toolView addSubview:_totalTime];
}

//音量调节
- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        _volumeView.transform = CGAffineTransformMakeRotation(M_PI*(-0.5));
        [_volumeView setShowsVolumeSlider:YES];
        [_volumeView setShowsRouteButton:NO];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                [self.volumeViewSlider setThumbImage:[UIImage getRoundImageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
                break;
            }
        }
    }
    return _volumeView;
}

//亮度调节
- (UISlider *)brightnessSlider {
    if (_brightnessSlider == nil) {
        _brightnessSlider  = [[UISlider alloc] init];
        _brightnessSlider.transform = CGAffineTransformMakeRotation(M_PI*(-0.5));
        [_brightnessSlider setThumbImage:[UIImage getRoundImageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
    }
    return _brightnessSlider;
}

//亮度调节相关
- (void)brightnessChanged:(UISlider *)slider {
    [[UIScreen mainScreen] setBrightness:slider.value];
}

//每个视图都对应一个层，改变视图的形状、动画效果\与播放器的关联等，都可以在层上操作
- (void)setPlayer:(AVPlayer *)myPlayer
{
    AVPlayerLayer *playerLayer=(AVPlayerLayer *)self.layer;
    [playerLayer setPlayer:myPlayer];
}

//在调用视图的layer时，会自动触发layerClass方法，重写它，保证返回的类型是AVPlayerLayer
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

//播放器的单击事件<控制底部和顶部view的显示与隐藏>
- (void)tapGR:(UITapGestureRecognizer *)tapGR {
    [UIView animateWithDuration:.5 animations:^{
        _topView.hidden = !_topView.isHidden;
        _toolView.hidden = !_toolView.isHidden;
    }];
}

#pragma mark - 顶部view相关事件
//返回按钮的点击事件
- (void)goBack:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(goback)]) {
        [self.delegate goback];
    }
}

//全屏按钮的点击事件
- (void)fullScreen:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(fullScreen:)]) {
        [self.delegate fullScreen:btn];
    }
}

#pragma mark - 底部view相关事件
//播放按钮的点击事件
-(void)playBtnClick:(UIButton *)btn
{
    if (_player == nil) {
        return;
    }
    if (btn.selected) {//暂停
        [_player pause];
        btn.selected = NO;
        return;
    }
    else {//播放
        [_player play];
        btn.selected = YES;
    }
}

//进度条滑动开始
-(void)touchDown:(UISlider *)sl
{
    if (_player == nil) {
        return;
    }
    [_player pause];
    _playBtn.selected = NO;
}

//进度条滑动
-(void)touchChange:(UISlider *)sl
{
    //通过进度条控制播放进度
    if (_player == nil) {
        return;
    }
    CMTime dur = _player.currentItem.duration;
    float current = _progressSlider.value;
    _currentTime.text = [self getTime:(NSInteger)(current*self.dur)];
    //跳转到指定的时间
    [_player seekToTime:CMTimeMultiplyByFloat64(dur, current)];
}

//进度条滑动结束
-(void)touchUp:(UISlider *)sl
{
    if (_player == nil) {
        return;
    }
    [_player play];
    _playBtn.selected = YES;
}

#pragma mark - 滑动手势处理,亮度/音量/进度
/**
 开始触摸
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    self.direction = LLDirectionNone;
    
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= self.bounds.size.width/2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音量
        self.startVB = self.volumeViewSlider.value;
    }
    CMTime ctime = _player.currentTime;
    self.startVideoRate = ctime.value /ctime.timescale/self.dur;
}

/**
 移动手指
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    if (self.direction == LLDirectionNone) {
        //分析出用户滑动的方向
        if (fabs(panPoint.x) >= 30) {
            [_player pause];
            self.direction = LLDirectionHrizontal;
        }
        else if (fabs(panPoint.y) >= 30) {
            self.direction = LLDirectionVertical;
        }
        else {
            return;
        }
    }
    
    if (self.direction == LLDirectionHrizontal) {
        CGFloat rate = self.startVideoRate+(panPoint.x*180/(self.bounds.size.width*self.dur));
        NSLog(@"%f",self.dur);
        if (rate > 1) {
            rate = 1;
        }
        else if (rate < 0) {
            rate = 0;
        }
        _progressSlider.value = rate;
        CMTime dur = _player.currentItem.duration;
        _currentTime.text = [self getTime:(NSInteger)(rate*self.dur)];
        [_player seekToTime:CMTimeMultiplyByFloat64(dur, rate)];
        
    }else if (self.direction == LLDirectionVertical) {
        CGFloat value = self.startVB-(panPoint.y/self.bounds.size.height);
        if (value > 1) {
            value = 1;
        }
        else if (value < 0) {
            value = 0;
        }
        if (self.startPoint.x <= self.frame.size.width/2.0) {//亮度
            self.brightnessSlider.hidden = NO;
            self.brightnessSlider.value = value;
            [[UIScreen mainScreen] setBrightness:value];
        }
        else {//音量
            self.volumeView.hidden = NO;
            [self.volumeViewSlider setValue:value];
        }
    }
}

/**
 结束触摸
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.direction == LLDirectionHrizontal) {
        [_player play];
    }
    else if (self.direction == LLDirectionVertical) {
        self.volumeView.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
}

/**
 取消触摸
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.direction == LLDirectionHrizontal) {
        [_player play];
    }
    else if (self.direction == LLDirectionVertical) {
        self.volumeView.hidden = YES;
        self.brightnessSlider.hidden = YES;
    }
}

#pragma mark - 视频播放完毕
-(void)moviePlayDidEnd:(NSNotification *)notification
{
    NSLog(@"视频播放完毕！");
}

#pragma mark - private method
//销毁player
-(void)releasePlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_player) {
        [_player pause];
        _player=nil;
    }
    for (UIView *view in _toolView.subviews) {
        [view removeFromSuperview];
    }
}

//将秒数换算成具体时长
- (NSString *)getTime:(NSInteger)second
{
    NSString *time;
    if (second < 60) {
        time = [NSString stringWithFormat:@"00:%02ld",(long)second];
    }
    else {
        if (second < 3600) {
            time = [NSString stringWithFormat:@"%02ld:%02ld",second/60,second%60];
        }
        else {
            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",second/3600,(second-second/3600*3600)/60,second%60];
        }
    }
    return time;
}

#pragma mark - super method
- (void)dealloc
{
    NSLog(@"playerView释放了,无内存泄漏");
}

- (void)removeFromSuperview
{
    [self releasePlayer];
    [super removeFromSuperview];
}
#pragma mark

@end
