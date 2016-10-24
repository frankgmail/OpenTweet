//
//  UtilityKit.m
//  OpenTweet
//
//  Created by OSX Frank on 10/24/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

#import "UtilityKit.h"

@implementation UtilityKit


// convert date - ISO-8601 format
+(NSString*)convertISO8601Date:(NSString*)srcdate
{
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    NSDate *date = [formatter dateFromString:srcdate];
    //NSLog(@"date = %@", date);
    NSString *dateString = [NSString stringWithFormat:@"%@", [self getTime:date]];
    return dateString;
}

+(NSString*)getTime:(NSDate*)sourceDate {
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setTimeZone:[NSTimeZone localTimeZone]];
    [timeFormat setDateFormat:@"yyyy/MM/dd hh:mm:ss a"];
    
    NSString *timeString = [timeFormat stringFromDate:sourceDate];
    return timeString;
}

@end
