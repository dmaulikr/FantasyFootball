//
//  SettingsManager.m
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"
#import "TeamManager.h"
#import "Util.h"

@interface SettingsManager ()

@end

@implementation SettingsManager

static SettingsManager* _instance = nil;

- (void) _applySettings {
    
    NSMutableArray *league = [[TeamManager getInstance] loadData:remoteSettings cache:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [TeamManager getInstance].league = league;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    });
}

- (void) _loadSettings {
    // check that we are not in the middle of loading the settings already
    if (isLoading)
        return;

    isLoading = YES;
    remoteSettingsData = [[NSMutableData alloc] init];

    /*NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/get"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];*/
    
    NSURL *URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams.json"];
    if (optionEnabled(@"testMode"))
        URL = [NSURL URLWithString:@"http://www.mhriley.com/fantasyfootball/teams_test.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSError *error2 = nil;
            remoteSettings = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
            
            if (!error2) {
                //NSLog(@"JSON Settings: %@", remoteSettings);
                [self _applySettings];
            }
            else {
                NSLog(@"JSON Deserialization failed: %@", [error2 userInfo]);
            }
        }
        else {
            NSLog(@"Connection failed: %@", [error userInfo]);
        }
        
        isLoading = NO;
    }];
    /*NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:
                                  ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                      NSLog(@"%@", [error localizedDescription]);
                                  }];*/
                                  
    [task resume];
}

+ (void) loadSettings {
    return [[SettingsManager getInstance] _loadSettings];
}

#pragma mark delegate methods for asynchronous requests

- (void)connection:(NSURLConnection*) myConnection didReceiveData:(NSData*) myData {
    [remoteSettingsData appendData:myData];
}

- (void)connection:(NSURLConnection*) myConnection didFailWithError:(NSError*) myError {
    isLoading = NO;

	NSLog(@"Connection failed");
}

- (void)connectionDidFinishLoading:(NSURLConnection*) myConnection {
    NSError *error = nil;
    remoteSettings = [NSJSONSerialization JSONObjectWithData:remoteSettingsData options:NSJSONReadingMutableContainers error:&error];
   
    if (!error) {
        //NSLog(@"JSON Settings: %@", remoteSettings);
        [self _applySettings];
    }
    else {
        NSLog(@"JSON Deserialization failed: %@", [error userInfo]);
    }

    isLoading = NO;
}

#pragma mark -
#pragma mark Lifecycle

+ (SettingsManager *) getInstance
{
    static SettingsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end


