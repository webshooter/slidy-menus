//
//  MenuScrollLayer.m
//  AnotherScrollLayerTest
//
//  Created by Randall Nickerson on 9/7/13.
//  Copyright (c) 2013 Threadbare Games. All rights reserved.
//

#import "MenuScrollLayer.h"
#import "CCNode+clipVisit.h"

@implementation MenuScrollLayer

-(void)visit
{
    float x = 0;
    float y = [[CCDirector sharedDirector] winSize].height - 100;
    visibleRect = CGRectMake(x, 100, 500, 300);
    
    [self preVisitWithClippingRect:visibleRect];
    [super visit];
    [self postVisit];
    
//    glEnable(GL_SCISSOR_TEST);
//    
//    glScissor(100, 100, 500, 300);
//    
//    [super visit];
//    
//    glDisable(GL_SCISSOR_TEST);
    
}

@end
