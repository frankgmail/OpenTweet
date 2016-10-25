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
// NSISO8601DateFormatter only available in iOS10. else would have been simple
//  NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
+(NSString*)convertISO8601Date:(NSString*)srcdate
{
    // Example: Convert from 2016-09-30T10:32:00-08:00 to 2016/09/30 05:55 PM
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    // Factor in locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSDate *date = [formatter dateFromString:srcdate];
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

// As of iOS 5, a shared NSURLCache is set for the application by default.
// Per Foundation’s URL Loading System, request through NSURLConnection will be handled by NSURLCache.
+(void)updateCell:(TweetPostCell*)cell fromElement:(id)element {
    // load avatar asynchronously in background if exist
    if ([element objectForKey:@"avatar"]) {
        NSURL *avatarURL = [NSURL URLWithString:[element objectForKey:@"avatar"]];
        NSURLRequest *avatarRequest = [NSURLRequest requestWithURL:avatarURL  cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [NSURLConnection sendAsynchronousRequest:avatarRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!data) {
                NSLog(@"%s: sendAynchronousRequest error: %@", __FUNCTION__, connectionError);
                return;
            } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    NSLog(@"%s: sendAsynchronousRequest status code != 200: response = %@", __FUNCTION__, response);
                    return;
                } else {
                    // update avatar
                    cell.avatar.image = [[UIImage alloc] initWithData:data];
                }
            }
        }];
    } else {
        cell.avatar.image = [UIImage imageNamed:@"profilePic.png"];
    }
}

+(void)AnimateFadeInCell:(UITableViewCell*)cell {
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (2.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //!!!FIX for issue if #1 Cell's position wrong
    if(cell.layer.position.x != 0){
        cell.layer.position = CGPointMake(0, cell.layer.position.y);
    }
    
    //4. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:1.2];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

#pragma mark - detect twitter handles, mentions
// Credits/References:
// 1. http://stackoverflow.com/questions/11011355/detect-url-in-nsstring
// 2. http://stackoverflow.com/questions/24359972/detect-hash-tags-mention-tags-in-ios-like-in-twitter-app
// 3. Simple regex pattern found here: http://regexlib.com/Search.aspx?k=URL
//
+(NSMutableAttributedString*)decorateTags:(NSString *)stringWithTags{
    
    NSError *error = nil;
    
    // Regex patterns
    NSString *patternH = @"http\\://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,3}(/\\S*)?$";
    NSString *patternS = @"https\\://[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,3}(/\\S*)?$";
    NSString *patternA = @"@(\\w+)";
    NSString *patternCombo = [NSString stringWithFormat:@"%@|%@|%@", patternA, patternH, patternS];
    
    NSRegularExpression *regexURL = [NSRegularExpression regularExpressionWithPattern:patternCombo options:0 error:&error];
    NSArray *matches = [regexURL matchesInString:stringWithTags options:0 range:NSMakeRange(0, stringWithTags.length)];
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:stringWithTags];
    
    //DLog(@"matches=%@", matches);
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];     // change to 1 to skip highlight leading @ character
        
        UIFont *font=[UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        [attString addAttribute:NSFontAttributeName value:font range:wordRange];
        
        //Set Foreground Color
        UIColor *foregroundColor=[UIColor blueColor];
        [attString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:wordRange];
        
        //NSLog(@"Found tag %@", word);
    }
    
    return attString;
}
@end
