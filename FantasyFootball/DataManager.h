//
//  SettingsManager.h
//  DebtManager
//
//  Created by Mark Riley on 23/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataManager : NSObject {
    NSDictionary *remoteJSONData;
    NSDictionary *staticData;
    NSArray *teamRows, *overallRows;

    BOOL isLoading;
}

+ (DataManager *) getInstance;
+ (void) loadData;
+ (void) checkForNewData:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
