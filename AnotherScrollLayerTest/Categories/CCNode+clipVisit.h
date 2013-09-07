//
//  CCNode+clipVisit.m
//  AnotherScrollLayerTest
//
//  Created by Randall Nickerson on 8/5/13.
//  Copyright Threadbare Games 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCNode (clipVisit)
{
	//
}

-(void)preVisitWithClippingRect:(CGRect)rect;
-(void)postVisit;

@end