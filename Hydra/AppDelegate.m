//
//  AppDelegate.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+AppColors.h"
#import "Hydra-Swift.h"

#import <Reachability/Reachability.h>

//@import FBSDKCoreKit;
//@import FBSDKLoginKit;
@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure some parts of the application asynchronously
    dispatch_queue_t async = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(async, ^{
        // Check for internet connectivity
        Reachability *reachability = [Reachability reachabilityWithHostname:@"zeus.ugent.be"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityStatusChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        [reachability startNotifier];
    });

/*    // Restore Facebook-session
    [FacebookSession.sharedSession openWithAllowLoginUI:NO completion:nil];

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];*/

    // Configure Firebase
    [FIRApp configure];

    // Root view controller
    UIViewController *rootvc;

    // Configure user defaults
    [PreferencesService registerAppDefaults];

    bool firstLaunch = [PreferencesService sharedService].firstLaunch;
    if (firstLaunch) {
        // Start onboarding
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"onboarding" bundle:[NSBundle mainBundle]];
        rootvc = [storyboard instantiateInitialViewController];
    } else {
        // Start storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        rootvc = [storyboard instantiateInitialViewController];
    }
    
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootvc;
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return false; //[[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification

    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

    // Pring full message.
    NSLog(@"%@", userInfo);
    if (DEBUG) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Notification" message:userInfo.description delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[SchamperStore sharedStore] syncStorage];
    [[AssociationStore sharedStore] syncStorage];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    //[[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    // You should also take care of closing the session if the app is about to terminate. 
    //[[FBSession activeSession] close];
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if (url != nil && [url.scheme  isEqual: @"hydra-ugent"] && ([url.path containsString:@"zeus/callback"])) {
        // FIXME: work arround until the UGent allows app url-schemes
        NSString *absuluteURL = [url absoluteString];
        absuluteURL = [absuluteURL stringByReplacingOccurrencesOfString:@"hydra-ugent://oauth/zeus/callback" withString:@"https://zeus.UGent.be/hydra/oauth/callback"];

        [[UGentOAuth2Service sharedService] handleRedirectURL:[[NSURL alloc] initWithString:absuluteURL]];
        return true;
    }
    return false;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if ([PreferencesService sharedService].skoNotificationsEnabled) {
        [[FIRMessaging messaging] subscribeToTopic:[NotificationService SKOTopic]];
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{

}

- (void)reachabilityStatusChanged:(NSNotification *)notification
{
    // Prevent this dialog from showing up more than once
    static BOOL reachabilityDetermined = NO;
    if(reachabilityDetermined) return;
    reachabilityDetermined = YES;

    Reachability *reachability = notification.object;
    if (!reachability.isReachable) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{
            kErrorTitleKey: @"Geen internetverbinding",
            kErrorDescriptionKey: @"Sommige onderdelen van Hydra vereisen een "
                                  @"internetverbinding en zullen mogelijks niet "
                                  @"correct werken."}];
        [self handleError:error];
    }
}

BOOL errorDialogShown = false;

- (void)handleError:(NSError *)error
{
    NSLog(@"An error occured: %@, %@", error, error.domain);

    if (errorDialogShown) return;

    NSString *title = error.userInfo[kErrorTitleKey];
    if (!title) title = @"Fout";

    NSString *message = error.userInfo[kErrorDescriptionKey];
    if (!message) message = [error localizedDescription];
    if (!message) message = @"Er trad een onbekende fout op.";

    // Try to improve the error message
    if ([error.domain isEqual:NSURLErrorDomain]) {
        title = @"Netwerkfout";
        message = @"Er trad een fout op het bij het ophalen van externe informatie. "
                   "Gelieve later opnieuw te proberen.";
    }
    else if ([error.domain containsString:@"com.facebook"]) {
        return; // hide facebook errors
    }
    /*else if ([error.domain isEqual:FacebookSDKDomain]) {
        title = @"Facebook";
        switch (error.code) {
            case FBErrorLoginFailedOrCancelled:
                message = @"Er was een probleem bij het aanmelden. Controleer "
                           "of Hydra toegang heeft tot je Facebook-account "
                           "in de systeem-instellingen";
                break;
            case FBErrorRequestConnectionApi:
            case FBErrorProtocolMismatch:
            case FBErrorHTTPError:
            case FBErrorNonTextMimeTypeReturned:
                message = @"Er trad een netwerkfout op. Gelieve later opnieuw"
                           "te proberen.";
                break;
            default:
                message = @"Er trad een onbekende fout op.";
                break;
        }
    }*/

    // Show an alert
    errorDialogShown = true;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:self
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    errorDialogShown = false;
}

- (void) resetApp {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];

    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
}

@end
