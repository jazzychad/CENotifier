//
//  DemoViewController.m
//  CENotifier
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

#import "DemoViewController.h"

@interface DemoViewController () {
    NSInteger _notifyCount;
}

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Notify!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_notifyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 80.0f, 50.0f);

    [self.view addSubview:button];
}

- (void)_notifyButtonTapped:(id)sender
{
    NSLog(@"view bounds: %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"button tapped!");

    _notifyCount++;
    NSUInteger duration = arc4random_uniform(10) + 1;

    NSMutableString *randomText = [[NSMutableString alloc] init];
    NSUInteger ulimit = arc4random_uniform(30);

    for (int i = 0; i < ulimit; i++) {
        [randomText appendString:@"blah "];
    }

    NSString *title = [NSString stringWithFormat:@"Notification #%d", _notifyCount];
    NSString *text = [NSString stringWithFormat:@"Showing for %d seconds.\n%@", duration, randomText];
    NSDictionary *userInfo = @{
                               @"num": @(_notifyCount)
                               };

    [CENotifier displayInView:self.view imageurl:@"https://si0.twimg.com/profile_images/28332812/addisontodd_bigger.jpg" title:title text:text duration:duration userInfo:userInfo delegate:self];
}

#pragma mark - CENotifyViewDelegate

- (void)notifyView:(CENotifyView *)notifyView didReceiveInteraction:(NSDictionary *)userInfo
{
    NSLog(@"You clicked notification number: %@", userInfo[@"num"]);
}

- (void)notifyView:(CENotifyView *)notifyView didDisappear:(NSDictionary *)userInfo animated:(BOOL)animated
{
    NSLog(@"Notification number %@ disappeared.", userInfo[@"num"]);
}

- (void)notifyView:(CENotifyView *)notifyView didCancel:(NSDictionary *)userInfo
{
    NSLog(@"You clicked CANCEL on notification number: %@", userInfo[@"num"]);
}

@end
