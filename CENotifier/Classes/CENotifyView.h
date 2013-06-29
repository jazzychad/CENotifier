//
//  CENotifyView.h
//  VorePad
//
//  Created by Chad Etzel on 4/4/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

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

+ (CGSize) renderedSizeForText:(NSString *)text;
+ (CGSize) renderedSizeForTitle:(NSString *)text;

@end

@protocol CENotifyViewDelegate <NSObject>

@optional
- (void)notifyView:(CENotifyView *)notifyView didReceiveInteraction:(NSDictionary *)userInfo;
- (void)notifyView:(CENotifyView *)notifyView didCancel:(NSDictionary *)userInfo;
- (void)notifyView:(CENotifyView *)notifyView didDisappear:(NSDictionary *)userInfo animated:(BOOL)animated;

@end