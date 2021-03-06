//
//  Team.h
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <Foundation/Foundation.h>

enum Momentum {Up, Down, Same};

@interface Team : NSObject

@property (nonatomic) NSString *teamName;
@property (nonatomic) NSString *managerName;
@property (nonatomic) long leaguePosition;
@property (nonatomic) long goldenBootPosition;
@property (nonatomic) long totalPoints;
@property (nonatomic) long weeklyPoints;
@property (nonatomic) long goals;
@property (nonatomic) long startingPoints, startingGoals;
@property (nonatomic) long startingPosition;
@property (nonatomic) long overallPosition;
@property (nonatomic) BOOL chairman;
@property (nonatomic) NSMutableArray *weeks;
@property (nonatomic) NSMutableArray *motms;
@property (nonatomic) enum Momentum momentum;
@property (nonatomic) long movement;

@end
