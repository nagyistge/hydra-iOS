//
//  PreferencesService.m
//  Hydra
//
//  Created by Pieter De Baets on 18/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "PreferencesService.h"

#define kFilterAssociationsKey @"useAssociationFilter"
#define kShowActivitiesInFeedKey @"showActivitiesInFeed"
#define kPreferredAssociationsKey @"preferredAssociations"
#define kHydraTabBarOrder @"hydraTabBarOrder"
#define kShownFacebookPrompt @"shownFacebookPrompt"
#define kUserLoggedInToFacebook @"userLoggedInToFacebook"

@interface PreferencesService ()

@property (nonatomic, strong) NSUserDefaults *settings;

@end

@implementation PreferencesService

+ (PreferencesService *)sharedService
{
    static PreferencesService *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[PreferencesService alloc] init];
    }
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.settings = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)filterAssociations
{
    BOOL key =  [self.settings boolForKey:kFilterAssociationsKey];
    return key;
}

- (void)setFilterAssociations:(BOOL)filterAssociations
{
    [self willChangeValueForKey:@"filterAssociations"];
    [self.settings setBool:filterAssociations forKey:kFilterAssociationsKey];
    [self didChangeValueForKey:@"filterAssociations"];
}

- (BOOL)showActivitiesInFeed
{
    return [self.settings boolForKey:kShowActivitiesInFeedKey];
}

- (void)setShowActivitiesInFeed:(BOOL)showActivitiesInFeed
{
    [self willChangeValueForKey:@"showActivitiesInFeed"];
    [self.settings setBool:showActivitiesInFeed forKey:kShowActivitiesInFeedKey];
    [self didChangeValueForKey:@"showActivitiesInFeed"];
}

- (BOOL)shownFacebookPrompt
{
    return [self.settings boolForKey:kShownFacebookPrompt];
}

- (void)setShownFacebookPrompt:(BOOL)shownFacebookPrompt
{
    [self willChangeValueForKey:@"shownFacebookPrompt"];
    [self.settings setBool:shownFacebookPrompt forKey:kShownFacebookPrompt];
    [self didChangeValueForKey:@"shownFacebookPrompt"];
}

- (BOOL)userLoggedInToFacebook
{
    return [self.settings boolForKey:kUserLoggedInToFacebook];
}

- (void)setUserLoggedInToFacebook:(BOOL)userLoggedInToFacebook
{
    [self willChangeValueForKey:kUserLoggedInToFacebook];
    [self.settings setBool:userLoggedInToFacebook forKey:kUserLoggedInToFacebook];
    [self didChangeValueForKey:kUserLoggedInToFacebook];
}

- (NSArray *)preferredAssociations
{
    NSArray *list = [self.settings objectForKey:kPreferredAssociationsKey];
    AssertClassOrNil(list, NSArray);
    if (list == nil) {
        list = [[NSArray alloc] init];
    }
    return list;
}

- (void)setPreferredAssociations:(NSArray *)preferredAssociations
{
    [self willChangeValueForKey:@"preferredAssociations"];
    [self.settings setObject:preferredAssociations forKey:kPreferredAssociationsKey];
    [self didChangeValueForKey:@"preferredAssociations"];
}


- (NSArray *)hydraTabBarOrder
{
    NSArray *list = [self.settings objectForKey:kHydraTabBarOrder];
    AssertClassOrNil(list, NSArray);
    if (list == nil) {
        list = [[NSArray alloc] init];
    }
    return list;
}

- (void)setHydraTabBarOrder:(NSArray *)hydraTabBarOrder
{
    [self willChangeValueForKey:kHydraTabBarOrder];
    [self.settings setObject:hydraTabBarOrder forKey:kHydraTabBarOrder];
    [self didChangeValueForKey:kHydraTabBarOrder];
}
@end
