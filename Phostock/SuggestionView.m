//
//  SuggestionView.m
//  Phostock
//
//  Created by Roman Truba on 08.12.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "SuggestionView.h"

@implementation SuggestionView
@synthesize suggestionTable;
-(void)awakeFromNib
{
    suggestionTable.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    suggestionTable.frame = CGRectMake(0, 0, suggestionTable.frame.size.height, suggestionTable.frame.size.width);
    [self filterSuggestions:@""];
    font = [UIFont fontWithName:kLobsterFont size:24];
    
    UIImageView * img = (UIImageView*)self.subviews[0];
    img.image = [img.image stretchableImageWithLeftCapWidth:4 topCapHeight:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return suggestionArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * currentSuggestion = [NSString stringWithFormat:@"@%@", suggestionArray[indexPath.row]];
    CGSize size = [currentSuggestion sizeWithFont:font constrainedToSize:CGSizeMake(10000, 26)];
    return size.width + 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"SuggestionCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    UILabel * label = nil;
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        label = [[UILabel alloc] init];
        label.font = font;
        label.tag = 1;
        label.transform = CGAffineTransformMakeRotation(M_PI / 2);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(1, 1);
        [cell.contentView addSubview:label];
    }
    else
    {
        label = (UILabel*)[cell.contentView viewWithTag:1];
    }
    
    NSString * currentSuggestion = [NSString stringWithFormat:@"@%@", suggestionArray[indexPath.row]];
    CGSize size = [currentSuggestion sizeWithFont:font constrainedToSize:CGSizeMake(10000, 26)];
    
    label.frame = CGRectMake(0, 0, size.height, size.width + 20);
    label.text = currentSuggestion;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate suggestionSelected:suggestionArray[indexPath.row] ];
}
-(void)filterSuggestions:(NSString *)filter
{
    suggestionArray = [[[NetWorker sharedInstance] getKnownUSers] allObjects];
    if ([filter isEqualToString:@""])
    {
        [suggestionTable reloadData];
        return;
    }
    
    NSMutableArray * copy = [NSMutableArray arrayWithCapacity:suggestionArray.count];
    for (NSString * curr in suggestionArray)
    {
        if ([curr rangeOfString:filter].location == 0) {
            [copy addObject:curr];
        }
    }
    suggestionArray = copy;
    [suggestionTable reloadData];
}
@end
