//
//  HomeTableViewController.m
//  OpenTweet
//
//  Created by OSX Frank on 10/24/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

/* Notes:
 A tweet has at the minimum:
    * An id
    * An author
    * A content (e.g. the actual tweet)
    * A date (text format, in the standard ISO-8601 format)
 * Display the tweets in the order the json file defines them. The app should display:
   - the author, the tweet and the date it was tweeted at.
   - Tweets are variable length, so the cells must be properly sized to the content
*/

#import "HomeTableViewController.h"
#import "TweetPostCell.h"
#import "DetailsTableViewController.h"
#import "UtilityKit.h"

// Capture specifics here to minimize hard-coding and ease maintenance and internationalization
#define kJsonFileName   @"timeline"
#define kDataKey        @"timeline"
#define kInputError     @"\nThere is an error reading input. Please try again later.\n"

// cell specifics
#define kCellBaseSize   70.0f   // Cell base fit avatar, author and date
#define kCellIndent     80.0f   // Content indent from left margin

static NSString * const kReusePostCell = @"TweetPostCell";

@interface HomeTableViewController ()
@property(nonatomic, strong)NSMutableArray *timelineArray;
@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Home";
    
    // register subclass PostCell
    [self.tableView registerNib:[UINib nibWithNibName:kReusePostCell bundle:nil] forCellReuseIdentifier:kReusePostCell];
    
    // read in source data
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kJsonFileName ofType:@"json"];
    _timelineArray = [[NSMutableArray alloc] initWithArray:[[self parseJsonTweets:filePath] objectForKey:kDataKey]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper methods
// From a given JSON-format tweet file, return a json dictionary of array
// Error handling: display alerts to user if there is issue reading file or file is ill-formatted.
-(NSDictionary*)parseJsonTweets:(NSString*)filePath {
    NSDictionary *jsonDict = NULL;
    if (filePath != NULL) {
        NSError *deserializingError;
        NSURL *localFileURL = [NSURL fileURLWithPath:filePath];
        NSData *jsonData = [NSData dataWithContentsOfURL:localFileURL];
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&deserializingError];
        if (deserializingError) {
            [self presentAlert:kInputError];
        }
    } else {
        NSLog(@"File read error: %@", filePath);
        [self presentAlert:kInputError];
    }
    return jsonDict;
}

// Display alert to user upon error
-(void)presentAlert:(NSString*)alertMessage {
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timelineArray.count;
}


// Size height of cell based on the length of tweet content, font and font size
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *content = [[_timelineArray objectAtIndex:indexPath.row ] objectForKey:@"content"];
    // size height dynamically based on length of tweet content, indented from left margin
    CGSize maximumLabelSize = CGSizeMake(self.tableView.frame.size.width - kCellIndent, FLT_MAX);
    
    // Calculate height from via attributedString factoring in style
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                              range:NSMakeRange(0, attributedString.length)];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                              range:NSMakeRange(0, attributedString.length)];
    CGSize expectedSize = [attributedString boundingRectWithSize:maximumLabelSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return expectedSize.height + kCellBaseSize;  // add cellBaseSize (Avatar, Author, Date)
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetPostCell *cell = [tableView dequeueReusableCellWithIdentifier:kReusePostCell forIndexPath:indexPath];
    id element = [_timelineArray objectAtIndex:indexPath.row];
    cell.author.text = [element objectForKey:@"author"];
    cell.date.text = [UtilityKit convertISO8601Date:[element objectForKey:@"date"]];
    cell.content.text = [element objectForKey:@"content"];      // dynamically sized via autolayout
    [cell.content setFont:[UIFont systemFontOfSize:16.0f]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsTableViewController *detailsTVC = [[DetailsTableViewController alloc] init];
    NSMutableArray *threadArray = [[NSMutableArray alloc] init];
    threadArray = [self extractTweetsFromSelectedCellAtIndex:indexPath];
    detailsTVC.detailsArray = threadArray;
    [self.navigationController pushViewController:detailsTVC animated:YES];
}

#pragma mark - Extract Tweets
/*
 Display a tweet's thread when tapping on a giving tweet.
 - if the user taps on the first tweet of a thread, display all the replies in ascending chronological order,
 - if the user taps on a reply to another tweet, only show the tapped tweet and the tweet it's replying to.
 */

-(NSMutableArray*)extractTweetsFromSelectedCellAtIndex:(NSIndexPath*)indexPath
{
    NSMutableArray *extractedArray = [[NSMutableArray alloc] init];
    
    id element = [_timelineArray objectAtIndex:indexPath.row];
    NSString *inReplyTo = [element objectForKey:@"inReplyTo"];
    
    // check if replyTo is present
    if ( inReplyTo && inReplyTo.length > 0) // validate inReplyTo exist
    {   // extract the selected reply and original tweet
        [extractedArray addObject:[self addOriginalTweetWithId:inReplyTo]];
        [extractedArray addObject:element];
        
    } else {    // user taps on original tweet, extract all replies
        [extractedArray addObject:element]; // Add original tweet as first element
        NSString *originalId = [element objectForKey:@"id"];
        
        // Optimization:
        // Skip all tweets prior to original tweets leverage the chrono order
        for (int i=(int)indexPath.row; i < _timelineArray.count; i++) {
            if ([[[_timelineArray objectAtIndex:i] objectForKey:@"inReplyTo"] isEqualToString:originalId]) {
                [extractedArray addObject:[_timelineArray objectAtIndex:i]];
            }
        }
    }
    return extractedArray;
}

-(id)addOriginalTweetWithId:(NSString*)searchId
{
    id element;
    for (int i=0; i < _timelineArray.count; i++) {
        if ([[[_timelineArray objectAtIndex:i] objectForKey:@"id"] isEqualToString:searchId]) {
            element = [_timelineArray objectAtIndex:i];
            break;
        }
    }
    return element;
}

@end
