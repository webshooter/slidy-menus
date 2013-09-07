//
//  CCNode+clipVisit.m
//  AnotherScrollLayerTest
//
//  Created by Randall Nickerson on 8/5/13.
//  Copyright Threadbare Games 2013. All rights reserved.
//

#import "CCNode+clipVisit.h"

@implementation CCNode(clipVisit)

-(void)preVisitWithClippingRect:(CGRect)clipRect 
{
	if (!self.visible)
	{
		return;
	}
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

	glEnable(GL_SCISSOR_TEST);

	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	CGPoint origin = [self convertToWorldSpaceAR:clipRect.origin];
	CGPoint topRight = [self convertToWorldSpaceAR:ccpAdd(clipRect.origin, ccp(clipRect.size.width, clipRect.size.height))];
	CGRect scissorRect = CGRectMake(origin.x, origin.y, topRight.x-origin.x, topRight.y-origin.y);

	// transform the clipping rectangle to adjust to the current screen
	// orientation: the rectangle that has to be passed into glScissor is
	// always based on the coordinate system as if the device was held with the
	// home button at the bottom. the transformations account for different
	// device orientations and adjust the clipping rectangle to what the user
	// expects to happen.
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
	switch (orientation) {
		
		case UIDeviceOrientationPortraitUpsideDown:
			scissorRect.origin.x = size.width-scissorRect.size.width-scissorRect.origin.x;
			scissorRect.origin.y = size.height-scissorRect.size.height-scissorRect.origin.y;
			break;
		
        
        case UIDeviceOrientationLandscapeLeft:
		{
//            NSLog(@"LandscapeLeft [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
			float tmp = scissorRect.origin.x;
			scissorRect.origin.x = scissorRect.origin.y;
			scissorRect.origin.y = size.width-scissorRect.size.width-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
		break;
		
        
        case UIDeviceOrientationLandscapeRight:
		{
//            NSLog(@"LandscapeRight [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
			float tmp = scissorRect.origin.y;
			scissorRect.origin.y = scissorRect.origin.x;
			scissorRect.origin.x = size.height-scissorRect.size.height-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
		break;
        
        
        case UIDeviceOrientationPortrait:
//            NSLog(@"Portrait [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
            break;
        case UIDeviceOrientationUnknown:
//            NSLog(@"Unknown [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
            break;
        case UIDeviceOrientationFaceDown:
//            NSLog(@"FaceDown [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
            break;
        case UIDeviceOrientationFaceUp:
//            NSLog(@"FaceUp [%@] [%@]", NSStringFromCGPoint(origin), NSStringFromCGPoint(topRight));
            break;
            
	}

	// Handle Retina
	scissorRect = CC_RECT_POINTS_TO_PIXELS(scissorRect);

	glScissor((GLint) scissorRect.origin.x, (GLint) scissorRect.origin.y,
	(GLint) scissorRect.size.width, (GLint) scissorRect.size.height);
}

-(void)postVisit 
{
	glDisable(GL_SCISSOR_TEST);
}

@end