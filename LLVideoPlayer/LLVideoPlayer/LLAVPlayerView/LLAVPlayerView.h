//
//  PlayView.h
//  LLAVPlayer
//
//  Created by zhaomengWang on 2017/4/13.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LLAVPlayerViewDelegate;

@interface LLAVPlayerView : UIView

@property (nonatomic, weak) id<LLAVPlayerViewDelegate> delegate;
@property (nonatomic, strong) UIButton *fullScreenBtn;

/**
 播放视屏
 */
- (void)playWith:(NSURL *)url;

/**
 暂停
 */
- (void)pause;

@end

@protocol LLAVPlayerViewDelegate <NSObject>

@optional
- (void)goback;
- (void)fullScreen:(UIButton *)btn;

@end
