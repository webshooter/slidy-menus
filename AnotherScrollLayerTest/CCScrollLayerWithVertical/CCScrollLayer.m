//
// CCScrollLayer.m
//
// Copyright 2010 DK101
// http://dk101.net/2010/11/30/implementing-page-scrolling-in-cocos2d/
//
// Copyright 2010 Giv Parvaneh.
// http://www.givp.org/blog/2010/12/30/scrolling-menus-in-cocos2d/
//
// Copyright 2011 Stepan Generalov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED

#import "CCScrollLayer.h"
#import "CCGL.h"

enum
{
    kCCScrollLayerStateIdle,
    kCCScrollLayerStateSliding,
};

@interface CCTouchDispatcher (targetedHandlersGetter)

- (NSMutableArray *) targetedHandlers;

@end

@implementation CCTouchDispatcher (targetedHandlersGetter)

- (NSMutableArray *) targetedHandlers
{
    return targetedHandlers;
}

@end

@implementation CCScrollLayer

@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;
@synthesize minimumTouchLengthToChangePage = minimumTouchLengthToChangePage_;
@synthesize totalScreens = totalScreens_;
@synthesize currentScreen = currentScreen_;
@synthesize showPagesIndicator = showPagesIndicator_;
@synthesize isHorizontal = isHorizontal_;

+(id) nodeWithLayers:(NSArray *)layers widthOffset: (int) offset
{
    return [[self alloc] initWithLayers: layers widthOffset:offset];
}

-(id) initWithLayers:(NSArray *)layers widthOffset: (int) offset
{
    if ( (self = [super init]) )
    {
        NSAssert([layers count], @"CCScrollLayer#initWithLayers:widthOffset: you must provide at least one layer!");

        // Enable touches.
        self.touchEnabled = YES;

        // Set default minimum touch length to scroll.
        self.minimumTouchLengthToSlide = 30.0f;
        self.minimumTouchLengthToChangePage = 100.0f;

        // Show indicator by default.
        self.showPagesIndicator = YES;

        // Set up the starting variables
        currentScreen_ = 1;
        
        // set isHorizontal
        isHorizontal_ = YES;

        // offset added to show preview of next/previous screens
        scrollDistance_ = [[CCDirector sharedDirector] winSize].width - offset;

        // Loop through the array and add the screens
        int i = 0;
        for (CCLayer *l in layers)
        {
            l.anchorPoint = ccp(0,0);
            l.position = ccp((i*scrollDistance_),0);
            [self addChild:l];
            i++;
        }

        // Setup a count of the available screens
        totalScreens_ = [layers count];

    }
    return self;
}

+(id) nodeWithLayers:(NSArray *)layers heightOffset: (int) offset
{
    return [[self alloc] initWithLayers: layers heightOffset:offset];
}

-(id) initWithLayers:(NSArray *)layers heightOffset: (int) offset
{
    if ( (self = [super init]) )
    {
        NSAssert([layers count], @"CCScrollLayer#initWithLayers:heightOffset: you must provide at least one layer!");

        // Enable touches.
        self.touchEnabled = YES;

        // Set default minimum touch length to scroll.
        self.minimumTouchLengthToSlide = 30.0f;
        self.minimumTouchLengthToChangePage = 100.0f;

        // Show indicator by default.
        self.showPagesIndicator = YES;

        // Set up the starting variables
        currentScreen_ = 1;

        // set isHorizontal
        isHorizontal_ = NO;
        
        // offset added to show preview of next/previous screens
        scrollDistance_ = [[CCDirector sharedDirector] winSize].height - offset;

        // Loop through the array and add the screens
        int i = 0;
        for (CCLayer *l in layers)
        {
            l.anchorPoint = ccp(0,0);
            l.position = ccp(0,-(i*scrollDistance_));
            [self addChild:l];
            i++;
        }

        // Setup a count of the available screens
        totalScreens_ = [layers count];

    }
    return self;
}

#pragma mark CCLayer Methods ReImpl

// Register with more priority than CCMenu's but don't swallow touches
-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority - 1 swallowsTouches:NO];
}

- (void) visit
{
    [super visit];//< Will draw after glPopScene.

    if (self.showPagesIndicator)
    {
        // Prepare Points Array
        CGFloat n = (CGFloat)totalScreens_; //< Total points count in CGFloat.
        CGFloat d = 16.0f; //< Distance between points.
        CGPoint points[totalScreens_];

        if (isHorizontal_ == YES)
        {

            CGFloat pY = ceilf ( self.contentSize.height / 8.0f ); //< Points y-coord in parent coord sys.
            for (int i=0; i < totalScreens_; ++i)
            {
                CGFloat pX = 0.5f * self.contentSize.width + d * ( (CGFloat)i - 0.5f*(n-1.0f) );
                points[i] = ccp (pX, pY);
            }
        }
        else
        {

            CGFloat pX = self.contentSize.width - ceilf ( self.contentSize.width / 8.0f ); //< Points x-coord in parent coord sys.
            for (int i=0; i < totalScreens_; ++i)
            {
                CGFloat pY = 0.5f * self.contentSize.height - d * ( (CGFloat)i - 0.5f*(n-1.0f) );
                points[i] = ccp (pX, pY);
            }
        }

        // Set GL Values
        GLboolean blendWasEnabled = glIsEnabled( GL_BLEND );
        glEnable(GL_BLEND);
        glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
        ccPointSize( 6.0 * CC_CONTENT_SCALE_FACTOR() );

        // Draw Gray Points
        ccDrawColor4F(0x96,0x96,0x96,0xFF);
        ccDrawPoints( points, totalScreens_ );

        // Draw White Point for Selected Page
        ccDrawColor4F(0xFF,0xFF,0xFF,0xFF);
        ccDrawPoint(points[currentScreen_ - 1]);

        // Restore GL Values
        ccPointSize(1.0f);

        if (! blendWasEnabled)
        {
            glDisable(GL_BLEND);
        }
    }
}

#pragma mark Pages Control

-(void) moveToPage:(int)page
{
    int changeX = 0;
    int changeY = 0;

    if (isHorizontal_ == YES)
    {
        changeX = -((page-1)*scrollDistance_);
    }
    else
    {
        changeY = ((page-1)*scrollDistance_);
    }

    id changePage = [CCMoveTo actionWithDuration:0.3 position:ccp(changeX,changeY)];
    [self runAction:changePage];
    currentScreen_ = page;
}

#pragma mark Hackish Stuff

- (void) claimTouch: (UITouch *) aTouch
{
    // Enumerate through all targeted handlers.
    for ( CCTargetedTouchHandler *handler in [[[CCDirector sharedDirector] touchDispatcher] targetedHandlers] )
    {
        // Only our handler should claim the touch.
        if (handler.delegate == self)
        {
            if (![handler.claimedTouches containsObject: aTouch])
            {
                [handler.claimedTouches addObject: aTouch];
            }
            else
            {
                CCLOGERROR(@"CCScrollLayer#claimTouch: %@ is already claimed!", aTouch);
            }
            return;
        }
    }
}

- (void) cancelAndStoleTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Throw Cancel message for everybody in TouchDispatcher.
    [[[CCDirector sharedDirector] touchDispatcher]  touchesCancelled: [NSSet setWithObject: touch] withEvent:event];

    //< after doing this touch is already removed from all targeted handlers

    // Squirrel away the touch
    [self claimTouch: touch];
}

#pragma mark Touches

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

    if (isHorizontal_ == YES)
    {
        startSwipe_ = touchPoint.x;
    }
    else
    {
        startSwipe_ = touchPoint.y;
    }

    state_ = kCCScrollLayerStateIdle;
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

    int moveDistance = 0;
    if (isHorizontal_ == YES) {
    moveDistance = touchPoint.x-startSwipe_;
    } else {
    moveDistance = touchPoint.y-startSwipe_;
    }

    // If finger is dragged for more distance then minimum - start sliding and cancel pressed buttons.
    // Of course only if we not already in sliding mode
    if ( (state_ != kCCScrollLayerStateSliding) && (fabsf(moveDistance) >= self.minimumTouchLengthToSlide) )
    {
        state_ = kCCScrollLayerStateSliding;

        // Avoid jerk after state change.
        if (isHorizontal_ == YES)
        {
            startSwipe_ = touchPoint.x;
        }
        else
        {
            startSwipe_ = touchPoint.y;
        }

        [self cancelAndStoleTouch: touch withEvent: event];
    }

    if (state_ == kCCScrollLayerStateSliding)
    {
        int pointX = 0;
        int pointY = 0;
        if (isHorizontal_ == YES)
        {
            pointX = (-(currentScreen_-1)*scrollDistance_)+(touchPoint.x-startSwipe_);
        }
        else
        {
            pointY = ((currentScreen_-1)*scrollDistance_)+(touchPoint.y-startSwipe_);
        }
        self.position = ccp(pointX,pointY);
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

    int offsetLoc = 0;
    if (isHorizontal_ == YES)
    {
        offsetLoc = (touchPoint.x - startSwipe_);
    }
    else
    {
        offsetLoc = -(touchPoint.y - startSwipe_);
    }

    if ( offsetLoc < -self.minimumTouchLengthToChangePage && (currentScreen_+1) <= totalScreens_ )
    {
        [self moveToPage: currentScreen_+1];
    }
    else if ( offsetLoc > self.minimumTouchLengthToChangePage && (currentScreen_-1) > 0 )
    {
        [self moveToPage: currentScreen_-1];
    }
    else
    {
        [self moveToPage:currentScreen_];
    }
}

@end

#endif