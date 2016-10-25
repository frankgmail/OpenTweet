//
//  TweetPostCell.m
//  OpenTweet
//
//  Created by OSX Frank on 10/24/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

#import "TweetPostCell.h"
#define kAvatarImageSize    44.0
@implementation TweetPostCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatar.layer.cornerRadius = kAvatarImageSize/2;

    self.avatar.clipsToBounds = YES;
    self.avatar.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
