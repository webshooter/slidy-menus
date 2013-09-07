//
//  TBGScrollLayer.h
//  AnotherScrollLayerTest
//
//  Created by Randall Nickerson on 8/5/13.
//  Copyright (c) 2013 Threadbare Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class TBGScrollLayer;
@protocol TBGScrollLayerDelegate

@optional

/** Called when scroll layer begins scrolling.
 * Usefull to cancel CCTouchDispatcher standardDelegates.
 */
- (void) scrollLayerScrollingStarted:(TBGScrollLayer *) sender;

/** Called at the end of moveToPage:
 */
- (void) scrollLayer: (TBGScrollLayer *) sender scrolledToPageNumber: (int) page;

@end

/** Vertical scrolling layer for items.
 *
 * It is a very clean and elegant subclass of CCLayer that lets you pass-in an array
 * of layers and it will then create a smooth scroller.
 * Every sub-layer should have the same size in current version.
 *
 * @version 0.1.01
 */
@interface TBGScrollLayer : CCLayer
{
    NSObject <TBGScrollLayerDelegate> *delegate_;
    
    // The screen coord of initial point the user starts their swipe.
    CGFloat startSwipe_;
    
    // The coord of initial position the user starts theri swipe.
    CGFloat startSwipeLayerPos_;
    
    // For what distance user must slide finger to start scrolling menu.
    CGFloat minimumTouchLengthToSlide_;
    
    // Internal state of scrollLayer (scrolling or idle).
    int state_;
    
    BOOL stealTouches_;
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    // Holds the touch that started the scroll
    UITouch *scrollTouch_;
#endif
    
    // Holds pages.
    NSMutableArray *layers_;
    
    // Holds current pages width offset.
    CGFloat pagesOffset_;
    
    // Holds the height of every page
    CGFloat pageHeight_;
    
    // Holds the width of every page
    CGFloat pageWidth_;
    
    // Holds the maximum upper position
    CGFloat maxVerticalPos_;
    
    // Holds the real responsible rect in the screen
    CGRect realBound;
    
    /*Decoration and slide bars*/
    // Scroll bars on the right
    CCSprite* scrollBar;
    CGFloat scrollBarPosY;
    
    // Scroll block that indicates the current position in whole scorll view content
    CCSprite* scrollBlock;
    CGFloat scrollBlockUpperBound;
    CGFloat scrollBlockLowerBound;
    
    // Decoration
    // Holds position to maintain their position fixed even in setPosition
    CCSprite* upperBound;
    CGFloat upperBoundPosY;
    CCSprite* lowerBound;
    CGFloat lowerBoundPosY;
}

@property (readwrite, assign) NSObject <TBGScrollLayerDelegate> *delegate;

#pragma mark Scroll Config Properties

/** Calibration property. Minimum moving touch length that is enough
 * to cancel menu items and start scrolling a layer.
 */
@property(readwrite, assign) CGFloat minimumTouchLengthToSlide;

/** If YES - when starting scrolling TBGScrollLayer will claim touches, that are
 * already claimed by others targetedTouchDelegates by calling CCTouchDispatcher#touchesCancelled
 * Usefull to have ability to scroll with touch above menus in pages.
 * If NO - scrolling will start, but no touches will be cancelled.
 * Default is YES.
 */
@property(readwrite) BOOL stealTouches;

#pragma mark Pages Control Properties

/** Offset, that can be used to let user see next/previous page. */
@property(readwrite) CGFloat pagesOffset;

/** Page height, this version requires that each page shares the same height and width */
@property(readonly) CGFloat pageHeight;
@property(readonly) CGFloat pageWidth;

/** Returns array of pages CCLayer's  */
@property(readonly) NSArray *pages;

#pragma mark Init/Creation

/** Creates new scrollLayer with given pages & width offset.
 * @param layers NSArray of CCLayers, that will be used as pages.
 * @param pageSize indicates the size of every page, now this version requires each page
 * share the same page size
 * @param widthOffset Length in X-coord, that describes length of possible pages
 * @param visibleRect indicates the real position and size on the screen
 * intersection. */
+(id) nodeWithLayers:(NSArray *)layers pageSize:(CGSize)pageSize pagesOffset: (int) pOffset visibleRect: (CGRect)rect;

/** Inits scrollLayer with given pages & width offset.
 * @param layers NSArray of CCLayers, that will be used as pages.
 * @param pageSize indicates the size of every page, now this version requires each page
 * share the same page size
 * @param pagesOffset Length in X-coord, that describes length of possible pages
 * @param visibleRect indicates the real position and size on the screen
 * intersection. */
-(id) initWithLayers:(NSArray *)layers pageSize:(CGSize)pageSize pagesOffset: (int) pOffset visibleRect: (CGRect)rect;

#pragma mark Misc
/**
 * Return the number of pages
 */
-(int) totalPagesCount;

#pragma mark Moving/Selecting Pages

/* Moves scrollLayer to page with given number.
 * Does nothing if number >= totalScreens or < 0.
 */
-(void) moveToPage:(int)page;

@end