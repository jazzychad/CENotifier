//
//  CENotifier.h
//  VorePad
//
//  Created by Chad Etzel on 4/8/11.
//  Copyright 2011 Phrygian Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CENotifyView.h"

@interface CENotifier : NSObject <CENotifyViewDelegate>

@property (nonatomic) NSMutableArray *viewsToAvoid;

// static

+ (CENotifier *)sharedCENotifier;

+ (void)displayInView:(UIView *)v imageurl:(NSString *)imageurl title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration userInfo:(NSDictionary *)userInfo delegate:(id <CENotifyViewDelegate, NSObject>) delegate;

+ (void)displayInView:(UIView *)v image:(UIImage *)image title:(NSString *)title text:(NSString *)text duration:(NSTimeInterval)duration userInfo:(NSDictionary *)userInfo delegate:(id <CENotifyViewDelegate, NSObject>) delegate;

+ (CGRect) frameForView:(CENotifyView *)view;

+ (void)removeAllNotifications;

// instance

- (void)displayNotifications;


@end

