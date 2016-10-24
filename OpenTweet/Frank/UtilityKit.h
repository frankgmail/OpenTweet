//
//  UtilityKit.h
//  OpenTweet
//
//  Created by OSX Frank on 10/24/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityKit : NSObject

+(NSString*)convertISO8601Date:(NSString*)srcdate;
+(NSString*)getTime:(NSDate*)sourceDate;

@end
