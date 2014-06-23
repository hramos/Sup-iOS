//
//  AppDelegate.h
//  Sup
//
//  Created by Héctor Ramos on 6/19/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

