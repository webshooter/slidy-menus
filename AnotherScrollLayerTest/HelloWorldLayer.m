//
//  HelloWorldLayer.m
//  AnotherScrollLayerTest
//
//  Created by Randall Nickerson on 8/5/13.
//  Copyright Threadbare Games 2013. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "CCScrollLayer.h"
#import "MenuScrollLayer.h"
#import "ClippingNode.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) )
    {
        
        CGPoint screenCenter = ccp([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height/2);
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // main background layer and image
        CCLayerColor* bgLayer = [[CCLayerColor alloc] initWithColor:ccc4(255.0f, 0.0f, 0.0f, 255.0f)];
        CCSprite* bgImage = [CCSprite spriteWithFile:@"bgmain.png"];
        [bgImage setAnchorPoint:CGPointZero];
        [bgLayer addChild:bgImage];
        [self addChild:bgLayer];
        
        // content background
        CGSize contentBGLayerSize = CGSizeMake(1024, 500);
        CGPoint contentOrigin = ccp(0, (winSize.height - contentBGLayerSize.height)/2);
        CCLayerColor* contentBGLayer = [[CCLayerColor alloc] initWithColor:ccc4(255.0f, 255.0f, 255.0f, 80.0f)];
        [contentBGLayer setContentSize:contentBGLayerSize];
        [contentBGLayer setPosition:contentOrigin];
        [self addChild:contentBGLayer];
        
        // create clipping node
        float borderHoriztonal = 50.0f;
        float borderVertical   = 150.0f;
        CGSize clipNodeSize = CGSizeMake(winSize.width - (borderHoriztonal*2), winSize.height - (borderVertical*2));
        CGPoint clipNodeOrigin = ccp((winSize.width - clipNodeSize.width)/2, (winSize.height - clipNodeSize.height)/2);
        CGRect rect = CGRectMake(clipNodeOrigin.x, clipNodeOrigin.y, clipNodeSize.width, clipNodeSize.height);
        ClippingNode* clipNode = [ClippingNode clippingNodeWithRect:rect];
        [self addChild:clipNode];
        
        
        // setup layout variables
        int colCount = 3;
        int rowCount = 4;
        CCSprite* refSprite = [CCSprite spriteWithFile:@"scrollitem.png"];
        CGSize itemSize = CGSizeMake(refSprite.contentSize.width, refSprite.contentSize.height);
        float spacerHoriz = 50.0f;
        float spacerVert  = 30.0f;
        
        float offsetHoriz = itemSize.width + spacerHoriz;
        float offsetVert  = itemSize.height + spacerVert;
        
        float starterX = (winSize.width - ((itemSize.width * colCount) + (spacerHoriz * (colCount-1))))/2;
        float starterY = winSize.height - ((winSize.height - ((itemSize.height * rowCount) + (spacerVert* (rowCount-1))))/2);
        CGPoint starterPoint = ccp(starterX, starterY);

        // create pages
        NSMutableArray* pages = [[NSMutableArray alloc] init];
        int unitCount = 0;
        while (unitCount < 60)
        {
            CCLayerColor* layer = [[CCLayerColor alloc] initWithColor:ccc4(255.0f, 255.0f, 255.0f, 0.0f)];
            //
            for (int row=0; row<rowCount; row++)
            {
                for (int col=0; col<colCount; col++)
                {
                    CCSprite* scrollItem = [CCSprite spriteWithFile:@"scrollitem.png"];
                    [scrollItem setAnchorPoint:ccp(0.0f,1.0f)];
                    [scrollItem setPosition:ccp(starterPoint.x + (offsetHoriz * col), starterPoint.y - (offsetVert * row) )];
                    CCLabelTTF* scrollItemLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Item #%d", unitCount++] fontName:@"Marker Felt" fontSize:20.0f];
                    [scrollItemLabel setColor:ccBLACK];
                    [scrollItemLabel setPosition:ccp(itemSize.width/2, itemSize.height/2)];
                    [scrollItem addChild:scrollItemLabel];
                    [layer addChild:scrollItem];
                }
            }
            [pages addObject:layer];
        }
        
        // create scroller and add to clipping node
        CCScrollLayer* scroller = [CCScrollLayer nodeWithLayers:pages widthOffset:0];
        [clipNode addChild:scroller];
        
	}
	return self;
}

@end
