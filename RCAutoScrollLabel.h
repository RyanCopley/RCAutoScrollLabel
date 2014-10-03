//
//  RCAutoScrollLabel.h
//  AmpacheY
//
//  Created by Ryan Copley on 10/3/14.
//  Copyright (c) 2014 Ampache.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAutoScrollLabel : UIView

@property (nonatomic, strong) UILabel* label;

@property (nonatomic) float scrollSpeed; // pixels per second
@property (nonatomic) NSTimeInterval pauseInterval;
@property (nonatomic, readonly) BOOL scrolling;
@property (nonatomic, readonly) BOOL scrollFadeState;
@property (nonatomic, assign) CGFloat fadeLength;
@property (nonatomic, strong) NSString* text;

@end
