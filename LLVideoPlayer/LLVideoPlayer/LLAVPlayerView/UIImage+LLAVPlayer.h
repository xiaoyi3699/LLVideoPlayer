//
//  UIImage+LLAVPlayer.h
//  LLVideoPlayer
//
//  Created by WangZhaomeng on 2017/4/15.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LLAVPlayer)

+ (UIImage *)getRoundImageWithColor:(UIColor*)color size:(CGSize)size;

@end

@interface UIView (LLAVPlayer)

- (UIViewController *)viewController;

@end
