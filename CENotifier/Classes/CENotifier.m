//
//  CENotifier.m
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

#import "CENotifier.h"
#import "SDWebImageManager.h"


#define MIN_Y (15.0)
#define WIDTH (290.0f)

@implementation CENotifier

static NSMutableArray *_queue;
static NSMutableArray *_onScreenViews;

#pragma mark - Static Methods

+ (void)initialize
{
    if (self == [CENotifier class]) {
        _queue = [[NSMutableArray alloc] initWithCapacity:0];
        _onScreenViews = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

+ (CENotifier *)sharedCENotifier
{
    static CENotifier *_sharedCENotifier;
    static dispatch_once_t onceToken;


    dispatch_once(&onceToken, ^{
        _sharedCENotifier = [[CENotifier alloc] init];
    });

    return _sharedCENotifier;
}

+ (void)displayInView:(UIView *)v imageurl:(NSString *)imageurl title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration userInfo:(NSDictionary *)userInfo delegate:(id <CENotifyViewDelegate, NSObject>)delegate
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    SDImageCache *imageCache = manager.imageCache;
    UIImage *cachedImage = [imageCache imageFromDiskCacheForKey:imageurl];
    UIImage *useImage;


    if (cachedImage) {
        useImage = cachedImage;
    } else {
        useImage = [UIImage imageNamed:@"Icon"];
        [manager downloadWithURL:[NSURL URLWithString:imageurl] options:0 progress:nil completed:nil];
        [manager downloadWithURL:[NSURL URLWithString:imageurl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (image && finished) {
                [manager.imageCache storeImage:image forKey:imageurl toDisk:YES];
            }
        }];
    }

    CENotifyView *nv = [[CENotifyView alloc] init];
    nv.parentView = v;
    nv.imageurl = imageurl;
    nv.image = useImage;
    nv.title = title;
    nv.text = text;
    nv.duration = duration;
    nv.delegate = [CENotifier sharedCENotifier];
    nv.finalDelegate = delegate;
    nv.frame = [CENotifier frameForView:nv];
    nv.userInfo = userInfo;

    [_queue addObject:nv];

    [[CENotifier sharedCENotifier] displayNotifications];
}

+ (void)displayInView:(UIView *)v image:(UIImage *)image title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration userInfo:(NSDictionary *)userInfo delegate:(id <CENotifyViewDelegate, NSObject>)delegate
{
    CENotifyView *nv = [[CENotifyView alloc] init];


    nv.parentView = v;
    nv.image = image;
    nv.title = title;
    nv.text = text;
    nv.duration = duration;
    nv.delegate = [CENotifier sharedCENotifier];
    nv.finalDelegate = delegate;
    nv.frame = [CENotifier frameForView:nv];
    nv.userInfo = userInfo;

    [_queue addObject:nv];

    [[CENotifier sharedCENotifier] displayNotifications];
}

// "private" static methods

+ (CGRect)frameForView:(CENotifyView *)notifyView
{
    CGSize sizText = [CENotifyView renderedSizeForText:notifyView.text];      //[view.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(300.0 - 40.0 - 5.0, 60.0) lineBreakMode:UILineBreakModeWordWrap];
    CGSize sizTitle = [CENotifyView renderedSizeForTitle:notifyView.title];

    CGRect ret;


    if ([notifyView.text isEqualToString:@""]) {
        ret = CGRectMake(notifyView.parentView.bounds.size.width - WIDTH - 15.0, MIN_Y, WIDTH, 44.0);
    } else {
        //ret = CGRectMake(view.view.frame.size.width - WIDTH - 15.0, MIN_Y, WIDTH, 10.0 + 44.0 + 1.0 + siz.height + 10.0);
        ret = CGRectMake(notifyView.parentView.bounds.size.width - WIDTH - 15.0, MIN_Y, WIDTH, MAX(44.0, 10.0 + sizTitle.height + 4.0 + sizText.height + 10.0));
    }

    return ret;
}

+ (BOOL)frame:(CGRect)f1 overlapsFrame:(CGRect)g1
{
    CGFloat fx1 = f1.origin.x;
    CGFloat fx2 = f1.origin.x + f1.size.width;
    CGFloat fy1 = f1.origin.y;
    CGFloat fy2 = f1.origin.y + f1.size.height;

    CGFloat gx1 = g1.origin.x;
    CGFloat gx2 = g1.origin.x + g1.size.width;
    CGFloat gy1 = g1.origin.y;
    CGFloat gy2 = g1.origin.y + g1.size.height;


    if (gx1 >= fx1 && gx1 <= fx2 && gy1 >= fy1 && gy1 <= fy2) {
        return YES;
    }

    if (gx2 >= fx1 && gx2 <= fx2 && gy1 >= fy1 && gy1 <= fy2) {
        return YES;
    }

    if (gx1 >= fx1 && gx1 <= fx2 && gy2 >= fy1 && gy2 <= fy2) {
        return YES;
    }

    if (gx2 >= fx1 && gx2 <= fx2 && gy2 >= fy1 && gy2 <= fy2) {
        return YES;
    }

    // check for reverse

    if (fx1 >= gx1 && fx1 <= gx2 && fy1 >= gy1 && fy1 <= gy2) {
        return YES;
    }

    if (fx2 >= gx1 && fx2 <= gx2 && fy1 >= gy1 && fy1 <= gy2) {
        return YES;
    }

    if (fx1 >= gx1 && fx1 <= gx2 && fy2 >= gy1 && fy2 <= gy2) {
        return YES;
    }

    if (fx2 >= gx1 && fx2 <= gx2 && fy2 >= gy1 && fy2 <= gy2) {
        return YES;
    }

    return NO;
}

#pragma mark - Instance Methods

- (id)init
{
    if (self = [super init]) {
        self.viewsToAvoid = [NSMutableArray arrayWithCapacity:5];
    }

    return self;
}

- (BOOL)viewWillFitInView:(CENotifyView *)notifyView
{
    UIView *superView = notifyView.parentView;
    CGRect superFrame = superView.bounds;
    CGRect f = notifyView.frame;
    CGFloat x, y, h, w;


    x = f.origin.x;
    w = f.size.width;
    h = f.size.height;
    BOOL flag1 = YES;
    BOOL flag2 = YES;
    int safety = 0;

    while (1) {
        safety++;

        if (safety == 100) {
            return NO;
        }

        CGRect ff = CGRectZero;
        CGRect gg = CGRectZero;

        for (UIView *v in self.viewsToAvoid) {
            if (![v superview] || v.hidden == YES) {
                continue;
            }

            ff = [[v superview] convertRect:v.frame toView:notifyView.parentView];

            if ([CENotifier frame:f overlapsFrame:ff]) {
                flag1 = NO;
                break;
            } else {
                flag1 = YES;
            }
        }         // end fore

        if (flag1 == YES) {
            for (CENotifyView *v in _onScreenViews) {
                if (v.parentView != superView) {
                    continue;
                }

                gg = v.frame;

                if ([CENotifier frame:f overlapsFrame:gg]) {
                    flag2 = NO;
                    break;
                } else {
                    flag2 = YES;
                }
            } // end fore
        }

        if (flag1 == NO || flag2 == NO) {
            // try to move down first
            CGRect conflictFrame;

            if (!flag1) {
                conflictFrame = ff;
            } else {
                conflictFrame = gg;
            }

            y = ceilf(conflictFrame.origin.y + conflictFrame.size.height + 5.0);

            if (y + h > superFrame.size.height) {
                // try moving left
                y = MIN_Y;
                x -= (WIDTH + 5.0);

                if (x < 0.0f) {
                    // moved offscreen...
                    return NO;
                }
            }

            f = CGRectMake(x, y, w, h);
            continue;
        } else {
            notifyView.frame = f;
            return YES;
        }
    }     // end while

    return NO;
}

- (BOOL)viewAvoidsOtherViews:(CENotifyView *)notifyView
{
    UIView *superView = notifyView.parentView;
    CGRect superFrame = superView.frame;
    CGRect f = notifyView.frame;
    CGFloat x, y, h, w;


    x = f.origin.x;
    w = f.size.width;
    h = f.size.height;
    BOOL flag = YES;
    int safety = 0;

    while (1) {
        safety++;

        if (safety == 100) {
            return NO;
        }

        CGRect ff = CGRectZero;

        for (UIView *v in self.viewsToAvoid) {
            if (![v superview] || v.hidden == YES) {
                continue;
            }

            ff = [[v superview] convertRect:v.frame toView:notifyView.parentView];

            if ([CENotifier frame:f overlapsFrame:ff]) {
                flag = NO;
                break;
            } else {
                flag = YES;
            }
        }         // end fore

        if (flag == NO) {
            // try to move down first
            y = ceilf(ff.origin.y + ff.size.height + 5.0);

            if (y + h > superFrame.size.height) {
                // try moving left
                y = MIN_Y;
                x -= (WIDTH + 5.0);

                if (x < 0.0f) {
                    // moved offscreen...
                    return NO;
                }
            }

            f = CGRectMake(x, y, w, h);
            continue;
        } else {
            notifyView.frame = f;
            return YES;
        }
    }     // end while

    return NO;
}

- (void)displayNotifications
{
    if ([_queue count]) {
        int i;
        int max = [_queue count];

        for (i = 0; i < max; i++) {
            //pop off _queue
            CENotifyView *nv = [_queue objectAtIndex:i];

            [_queue removeObjectAtIndex:i];

            if ([self viewWillFitInView:nv]) {
                [_onScreenViews addObject:nv];
                [nv displayInView];
                max--;
                i--;
            } else {
                [_queue insertObject:nv atIndex:i];
            }
        }
    }
}

+ (void)removeAllNotifications
{
    for (CENotifyView *v in _onScreenViews) {
        [v removeViewNow];
    }
}

#pragma mark -
#pragma mark CENotifyViewDelegate

- (void)notifyView:(CENotifyView *)notifyView didReceiveInteraction:(NSDictionary *)userInfo
{
    if (notifyView.finalDelegate && [notifyView.finalDelegate respondsToSelector:@selector(notifyView:didReceiveInteraction:)]) {
        [notifyView.finalDelegate notifyView:notifyView didReceiveInteraction:userInfo];
    }

    [self displayNotifications];
}

- (void)notifyView:(CENotifyView *)notifyView didCancel:(NSDictionary *)userInfo
{
    if (notifyView.finalDelegate && [notifyView.finalDelegate respondsToSelector:@selector(notifyView:didCancel:)]) {
        [notifyView.finalDelegate notifyView:notifyView didCancel:userInfo];
    }

    [self displayNotifications];
}

- (void)notifyView:(CENotifyView *)notifyView didDisappear:(NSDictionary *)userInfo animated:(BOOL)animated
{
    [_onScreenViews removeObject:notifyView];

    if (notifyView.finalDelegate && [notifyView.finalDelegate respondsToSelector:@selector(notifyView:didDisappear:animated:)]) {
        [notifyView.finalDelegate notifyView:notifyView didDisappear:userInfo animated:animated];
    }

    [self displayNotifications];
}

@end
