//
//  CENotifyView.m
//
//
// The MIT License (MIT)
//
// Copyright (c) 2013 Chad Etzel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import "CENotifyView.h"
#import "SDWebImageManager.h"

@implementation CENotifyView

#pragma mark - Static Methods

+ (CGSize)renderedSizeForText:(NSString *)text
{
    CGSize siz = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(300.0 - 40.0 - 5.0 - 10.0, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];


    return siz;
}

+ (CGSize)renderedSizeForTitle:(NSString *)text
{
    CGSize siz = [text sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(300.0 - 40.0 - 5.0 - 10.0, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];


    return siz;
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code.
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor blackColor];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)displayInView:(UIView *)v frame:(CGRect)frame imageurl:(NSString *)imageurl title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    SDImageCache *imageCache = manager.imageCache;
    UIImage *cachedImage = [imageCache imageFromDiskCacheForKey:imageurl];


    if (cachedImage) {
        [self displayInView:v frame:frame image:cachedImage title:title text:text duration:duration];
    } else {
        [self displayInView:v frame:frame image:[UIImage imageNamed:@"Icon"] title:title text:text duration:duration];
    }
}

- (void)displayInView:(UIView *)v frame:(CGRect)frame image:(UIImage *)image title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration
{
    self.parentView = v;
    self.frame = frame;
    self.image = image;
    self.title = title;
    self.text = text;
    self.duration = duration;

    [self displayInView];
}

- (void)displayInView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    self.frame = self.frame;

    CGSize siz;
    CGSize siz2;

    UIImageView *imgview = [[UIImageView alloc] initWithImage:self.image];
    imgview.frame = CGRectMake(10.0, 10.0, 24.0, 24.0);
    [self addSubview:imgview];

    siz = [CENotifyView renderedSizeForTitle:self.title];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 10.0, 300.0 - 40.0 - 5.0 - 10.0, siz.height)];
    lbl.font = [UIFont boldSystemFontOfSize:18.0];
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.lineBreakMode = UILineBreakModeWordWrap;
    lbl.numberOfLines = 2;
    lbl.text = self.title;
    [self addSubview:lbl];

    siz2 = [CENotifyView renderedSizeForText:self.text];

    lbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 10.0 + siz.height + 4.0, 300.0 - 40.0 - 5.0 - 10.0, siz2.height)];
    lbl.font = [UIFont systemFontOfSize:14.0];
    lbl.textColor = [UIColor whiteColor];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.lineBreakMode = UILineBreakModeWordWrap;
    lbl.numberOfLines = 0;
    lbl.text = self.text;
    [self addSubview:lbl];

    self.alpha = 0.0;

    [self.parentView addSubview:self];

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.8;
                     }

                     completion:^(BOOL finished) {
                         [self performSelector:@selector(removeView) withObject:nil afterDelay:self.duration];
                     }];
}

- (void)removeView
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.alpha = 0.0;
                     }

                     completion:^(BOOL finished) {
                         if ([self superview]) {
                             [self removeFromSuperview];
                         }

                         if (_delegate && [_delegate respondsToSelector:@selector(notifyView:didDisappear:animated:)]) {
                             [_delegate notifyView:self didDisappear:self.userInfo animated:YES];
                         }
                     }];
}

- (void)removeViewNow
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if ([self superview]) {
        [self removeFromSuperview];
    }

    if (_delegate && [_delegate respondsToSelector:@selector(notifyView:didDisappear:animated:)]) {
        [_delegate notifyView:self didDisappear:self.userInfo animated:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];


    if (point.x >= 0.0 && point.x <= 50.0 && point.y >= 0 && point.y <= 50.0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];

        if (_delegate && [_delegate respondsToSelector:@selector(notifyView:didCancel:)]) {
            [_delegate notifyView:self didCancel:self.userInfo];
        }

        [self removeView];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];

        if (_delegate && [_delegate respondsToSelector:@selector(notifyView:didReceiveInteraction:)]) {
            [_delegate notifyView:self didReceiveInteraction:self.userInfo];
        }

        [self removeView];
    }
}

@end
