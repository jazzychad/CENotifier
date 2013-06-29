//
//  CENotifyView.h
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

#import <UIKit/UIKit.h>

@protocol CENotifyViewDelegate;

@interface CENotifyView : UIView

@property (nonatomic, weak) id <CENotifyViewDelegate> delegate;
@property (nonatomic) NSDictionary *userInfo;

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, copy) NSString *imageurl;
@property (nonatomic) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, weak) id <CENotifyViewDelegate> finalDelegate;

- (void)displayInView:(UIView *)v frame:(CGRect)frame imageurl:(NSString *)imageurl title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration;
- (void)displayInView:(UIView *)v frame:(CGRect)frame image:(UIImage *)image title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration;
- (void)displayInView;

- (void)removeViewNow;

+ (CGSize)renderedSizeForText:(NSString *)text;
+ (CGSize)renderedSizeForTitle:(NSString *)text;

@end

@protocol CENotifyViewDelegate <NSObject>

@optional
- (void)notifyView:(CENotifyView *)notifyView didReceiveInteraction:(NSDictionary *)userInfo;
- (void)notifyView:(CENotifyView *)notifyView didCancel:(NSDictionary *)userInfo;
- (void)notifyView:(CENotifyView *)notifyView didDisappear:(NSDictionary *)userInfo animated:(BOOL)animated;

@end