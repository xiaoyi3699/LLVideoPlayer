//
//  UIImage+LLAVPlayer.m
//  LLVideoPlayer
//
//  Created by WangZhaomeng on 2017/4/15.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "UIImage+LLAVPlayer.h"

@implementation UIImage (LLAVPlayer)

+ (UIImage *)getRoundImageWithColor:(UIColor*)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

@implementation UIView (LLAVPlayer)

- (UIViewController *)viewController{
    UIResponder *next = [self nextResponder];
    do{
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next);
    return nil;
}

@end
