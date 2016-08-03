//
//  TeamDetailViewController.m
//  FantasyFootball
//
//  Created by Mark Riley on 25/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "Team.h"
#import "TeamWeek.h"
#import "TeamManager.h"
#import "Month.h"

@interface TeamDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *teamName;
@property (weak, nonatomic) IBOutlet UITextField *managerName;
@property (weak, nonatomic) IBOutlet UITextField *totalPoints;
@property (weak, nonatomic) IBOutlet UITextField *goals;
@property (weak, nonatomic) IBOutlet UILabel *fuCup;
@property (weak, nonatomic) IBOutlet UILabel *motm;
@property (weak, nonatomic) IBOutlet UILabel *predictedWinnings;
@property (weak, nonatomic) IBOutlet UITableView *weeklyPointsTable;

@end

@implementation TeamDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = _team.teamName;
    _teamName.text = [NSString stringWithFormat:@"%@", _team.teamName];
    _managerName.text = [NSString stringWithFormat:@"%@", _team.managerName];
    _totalPoints.text = [NSString stringWithFormat:@"%li", _team.totalPoints];
    _goals.text = [NSString stringWithFormat:@"%li", _team.goals];
    
    _fuCup.text = @"1st Round";
    
    if (_team.motms.count == 0)
        _motm.text = @"None";
    else {
        BOOL firstMonth = YES;
        _motm.text = @"";
        for (NSNumber *month in _team.motms) {
            _motm.text = [NSString stringWithFormat:@"%@%@%@", _motm.text, (firstMonth ? @"" : @", "), [((Month *)[TeamManager getInstance].months[10 - [month intValue]]).monthName substringToIndex:3]];
            firstMonth = NO;
        }
    }
    
    double winnings = 0;
    
    // league winnings
    switch (_team.leaguePosition) {
        case 1: winnings += 120; break;
        case 2: winnings += 60; break;
        case 3: winnings += 30; break;
        case 4: winnings += 20; break;
        case 5: winnings += 15; break;
        case 6: winnings += 10; break;
        case 7: winnings += 9; break;
        case 8: winnings += 8; break;
        case 9: winnings += 7; break;
        case 10: winnings += 6; break;
        case 11: winnings += 5; break;
        case 12: winnings += 4; break;
        case 13: winnings += 3; break;
        case 14: winnings += 2; break;
        case 15: winnings += 1; break;
    }
    
    // motm winnings
    winnings += (_team.motms.count * 10);
    
    // golden boot winnings
    if (_team.goldenBootPosition == 1)
        winnings += 15;
    
    // side bets
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"side_bets" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *sideBets = dict[@"sideBets"];
    for (NSDictionary *sideBet in sideBets) {
        NSString *type = sideBet[@"type"];
        Team *team1 = [[TeamManager getInstance] getTeam:sideBet[@"managerName1"]];
        Team *team2 = [[TeamManager getInstance] getTeam:sideBet[@"managerName2"]];
        Team *team3 = [[TeamManager getInstance] getTeam:sideBet[@"managerName3"]];
        
        Team *winningTeam = [[TeamManager getInstance] whoIsWinningBetOfType:type betweenTeam1:team1 team2:team2 team3:team3];
        Team *losingTeam = [[TeamManager getInstance] whoIsLosingBetOfType:type betweenTeam1:team1 team2:team2 team3:team3];
        
        if ([winningTeam.managerName isEqualToString:_team.managerName]) {
            if ([type isEqualToString:@"league"]) {
                winnings += team3 ? 2 * [sideBet[@"amount"] doubleValue] : [sideBet[@"amount"] doubleValue];
            }
            else if ([type isEqualToString:@"goals"]) {
                winnings += [sideBet[@"amount"] doubleValue];
            }
        }
        else if ([losingTeam.managerName isEqualToString:_team.managerName]) {
            if ([type isEqualToString:@"league"]) {
                winnings -= (team3 ? 2 * [sideBet[@"amount"] doubleValue] : [sideBet[@"amount"] doubleValue]);
            }
            else if ([type isEqualToString:@"goals"]) {
                winnings -= [sideBet[@"amount"] doubleValue];
            }
        }
    }
    
    // fu cup is £50 winner / £15 runner up

    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLenient:YES];
    [currencyFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [currencyFormatter setRoundingIncrement:[NSNumber numberWithDouble:0.01]];
    [currencyFormatter setCurrencySymbol:@"£"];
    [currencyFormatter setNegativeFormat:[@"-" stringByAppendingString:[currencyFormatter positiveFormat]]];

    if (_team.leaguePosition == 16)
        _predictedWinnings.text = [NSString stringWithFormat:@"%@ + WC", [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:winnings]]];
    else
        _predictedWinnings.text = [NSString stringWithFormat:@"%@", [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:winnings]]];
    
    _weeklyPointsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _weeklyPointsTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _weeklyPointsTable.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _team.weeks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Points"];
    //cell.textLabel.text = [NSString stringWithFormat:@"%li", (_team.weeks.count - indexPath.row)];
    
    TeamWeek *teamWeek = [_team.weeks objectAtIndex:(_team.weeks.count - indexPath.row - 1)];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%li", teamWeek.points];
    
    UILabel *week = (UILabel *)[cell viewWithTag:1];
    week.text = [NSString stringWithFormat:@"%li", (_team.weeks.count - indexPath.row)];
    
    UILabel *points = (UILabel *)[cell viewWithTag:2];
    points.text = [NSString stringWithFormat:@"%li", teamWeek.points];
    
    UILabel *position = (UILabel *)[cell viewWithTag:3];
    position.text = [NSString stringWithFormat:@"%li", teamWeek.position];
    
    // extend the separator to the left edge
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    
    return cell;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == _goals) {
        _team.goals = [textField.text intValue];
        [[TeamManager getInstance] sortGoals];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _totalPoints) {
        _team.totalPoints = [textField.text intValue];
        [[TeamManager getInstance] sortLeague];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _managerName) {
        _team.managerName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }
    else if (textField == _teamName) {
        _team.teamName = textField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:self];
    }

    return YES;
}

- (BOOL) doubleValues:(double) double1 equalsDoubleValue:(double) double2 withAccuracy:(double) accuracy {
    return (fabs(double1 - double2) < accuracy);
}

@end
