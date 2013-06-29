//
//  DemoViewController.m
//  CENotifier
//
//  Created by Charles Etzel on 6/29/13.
//  Copyright (c) 2013 Chad Etzel. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController () {
    NSInteger _notifyCount;
}

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

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
    //[CENotifier displayInView:self.view image:nil title:@"Testing" text:@"This is a test" delay:3.0 userInfo:nil delegate:self];

    _notifyCount++;
    NSUInteger duration = arc4random_uniform(10) + 1;

    NSMutableString *randomText = [[NSMutableString alloc] init];
    NSUInteger ulimit = arc4random_uniform(30);
    for (int i = 0; i < ulimit; i++) {
        [randomText appendString:@"blah "];
    }

    NSString *title = [NSString stringWithFormat:@"Notification #%d", _notifyCount];
    NSString *text = [NSString stringWithFormat:@"Showing for %d seconds.\n%@", duration, randomText];
    NSDictionary *userInfo = @{@"num": @(_notifyCount)};
    
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
