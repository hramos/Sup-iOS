//
//  AppDelegate.m
//  Sup
//
//  Created by Héctor Ramos on 6/19/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "AppDelegate.h"

#import "JCNotificationBannerPresenter.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterSmokeStyle.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "JCNotificationBannerPresenterIOS7Style.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:YOUR_APP_ID clientKey:YOUR_CLIENT_KEY];

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    if (![PFUser currentUser]) {
        // If no user logged in, force login view controller.
        PFLogInViewController *loginViewController = [PFLogInViewController new];
        loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton;
        loginViewController.delegate = self;
        loginViewController.signUpController.delegate = self;
        
        PFSignUpViewController *signUpViewController = [PFSignUpViewController new];
        signUpViewController.delegate = self;
        signUpViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsDismissButton | PFSignUpFieldsSignUpButton;
        loginViewController.signUpController = signUpViewController;
        
        self.window.rootViewController = loginViewController;
    } else {
        if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
            [self handlePush:notificationPayload];
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    if ([PFUser currentUser]) {
        currentInstallation[@"user"] = [PFUser currentUser];
    } else {
        [currentInstallation removeObjectForKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handlePush:userInfo];
}


#pragma mark - PFSignUpViewControllerDelegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self proceedToMainInterface];
}


#pragma mark - PFLogInViewControllerDelegate

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self proceedToMainInterface];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Did fail to log in: %@", error);
    [[[UIAlertView alloc] initWithTitle:[[error userInfo][@"error"] capitalizedString] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}


#pragma mark - ()

- (void)proceedToMainInterface {
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
}


- (void)handlePush:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveRemoteNotification" object:nil userInfo:userInfo];

    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application respondsToSelector:@selector(applicationState)] &&
        [application applicationState] != UIApplicationStateActive) {
        return;
    }
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if ([aps objectForKey:@"alert"]) {
        NSString *title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *message = [aps objectForKey:@"alert"];

        [JCNotificationCenter
         enqueueNotificationWithTitle:title
         message:message
         tapHandler:nil];
    }
    
    if ([aps objectForKey:@"sound"] &&
        ![[aps objectForKey:@"sound"] isEqualToString:@""] &&
        ![[aps objectForKey:@"sound"] isEqualToString:@"default"]) {
        NSString *soundName = [aps objectForKey:@"sound"];
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:[soundName stringByDeletingPathExtension]
                                                              ofType:[soundName pathExtension]];
        if (soundPath) {
            SystemSoundID soundId;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundId);
            AudioServicesPlaySystemSound(soundId);
            return;
        }
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
