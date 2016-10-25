//
//  UtilityKit.h
//  OpenTweet
//
//  Created by OSX Frank on 10/24/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilityKit : NSObject

+(NSString*)convertISO8601Date:(NSString*)srcdate;
+(NSString*)getTime:(NSDate*)sourceDate;

+(void)updateAvatar:(UIImageView*)avatarView fromElement:(id)element;
+(void)updateAvatar:(UIImageView*)avatarView fromElement:(id)element updateAvatarCache:(NSMutableDictionary*)avatarCache;

+(void)AnimateFadeInCell:(UITableViewCell*)cell;
+(NSMutableAttributedString*)decorateTags:(NSString *)stringWithTags;

@end
