//
//  UIViewController+LLVideoPlayer.h
//  LLVideoPlayer
//
//  Created by WangZhaomeng on 2018/3/2.
//  Copyright © 2018年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LLBaseViewControllerProtocol <NSObject>
@optional
///返回当前ViewController支持的屏幕方向
- (UIInterfaceOrientationMask)ll_supportedInterfaceOrientations;
@end

@interface UIViewController (LLVideoPlayer) <LLBaseViewControllerProtocol>

@end
