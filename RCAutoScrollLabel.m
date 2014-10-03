//
//  RCAutoScrollLabel.m
//  AmpacheY
//
//  Created by Ryan Copley on 10/3/14.
//  Copyright (c) 2014 Ampache.com. All rights reserved.
//

#import "RCAutoScrollLabel.h"

@interface RCAutoScrollLabel ()
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation RCAutoScrollLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    _label = [[UILabel alloc] init];
    _label.autoresizingMask = self.autoresizingMask;
    _label.frame = self.bounds;
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    _label.text = @"";
    [_label sizeToFit];
    [self addSubview:_label];
    
    // default values
    _scrollSpeed = 45;
    _pauseInterval = 1;
    _fadeLength = 16;
    _scrolling = NO;
    _scrollFadeState = NO;
    
    
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self applyGradientMaskForFadeLength:_fadeLength enableFade:YES];
}

-(void)setText:(NSString *)text {
    _text = text;
    _label.text = text;
    [_label sizeToFit];
    [_timer invalidate];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];

    
}

-(void)scroll{
    CGRect labelSize = [_label.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.bounds))
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:_label.font}
                                                         context:nil];
    if (labelSize.size.width > self.bounds.size.width){
        float outSpeed = _label.frame.size.width/_scrollSpeed;
        _scrolling = YES;
        _scrollFadeState = YES;
        [self applyGradientMaskForFadeLength:_fadeLength enableFade:YES];

        [UIView animateWithDuration:outSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^(void){
            
            CGRect labelFrame = _label.frame;
            labelFrame.origin = CGPointMake(-_label.frame.size.width, 0.0f);
            _label.frame = labelFrame;
        } completion:^(BOOL finished){
            
            CGRect labelFrame = _label.frame;
            labelFrame.origin = CGPointMake(self.frame.size.width, 0.0f);
            _label.frame = labelFrame;
            
            
            _scrollFadeState = NO;
            [self applyGradientMaskForFadeLength:_fadeLength enableFade:YES];
            
            CGFloat inSpeed = self.frame.size.width/_scrollSpeed;
            [UIView animateWithDuration:inSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^(void){
                
                CGRect labelFrame = _label.frame;
                labelFrame.origin = CGPointMake(0.0f, 0.0f);
                _label.frame = labelFrame;
            } completion:^(BOOL finished){
                
                _scrolling = NO;
                [NSTimer scheduledTimerWithTimeInterval:_pauseInterval target:self selector:@selector(scroll) userInfo:nil repeats:NO];
            }];
        }];
    }
    
}


- (void)removeGradientMask {
    self.layer.mask = nil;
}


- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength enableFade:(BOOL)fade
{
    CGFloat labelWidth = CGRectGetWidth(_label.bounds);
    if (labelWidth <= CGRectGetWidth(self.bounds))
        fadeLength = 0;
    
    if (fadeLength)
    {
        // Recreate gradient mask with new fade length
        CAGradientLayer *gradientMask = [CAGradientLayer layer];
        
        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;
        
        gradientMask.startPoint = CGPointMake(0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1, CGRectGetMidY(self.frame));
        
        // setup fade mask colors and location
        id transparent = (id)[UIColor clearColor].CGColor;
        id opaque = (id)[UIColor blackColor].CGColor;
        gradientMask.colors = @[transparent, opaque, opaque, transparent];
        
        // calcluate fade
        CGFloat fadePoint = fadeLength / CGRectGetWidth(self.bounds);
        NSNumber *leftFadePoint = @(fadePoint);
        NSNumber *rightFadePoint = @(1 - fadePoint);
        
        if (!_scrollFadeState){
            leftFadePoint = @(0);
        }
        
        // apply calculations to mask
        gradientMask.locations = @[@0, leftFadePoint, rightFadePoint, @1];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.mask = gradientMask;
        [CATransaction commit];
    }
    else
    {
        // Remove gradient mask for 0.0f lenth fade length
        self.layer.mask = nil;
    }
}

@end
