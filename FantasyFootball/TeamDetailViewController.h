//
//  TeamDetailViewController.h
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Team;

@interface TeamDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Team *team;

@end