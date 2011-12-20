//
//  GameplayLayer.m
//  Author: Thomas Taylor
//
//  The main layer in the game, handles 
//  the main 'gameplay' elements
//
//  13/11/2011: Created class
//

#import "GameplayLayer.h"
#import "Obstacle.h"

#import "Utils.h"

@interface GameplayLayer()

-(void)initDisplay;
-(void)update:(ccTime)deltaTime;
-(NSString*)getUpdatedDisplayString;
-(void)addLemming;
-(void)createLemmingAtLocation:(CGPoint)spawnLocation withHealth:(int)health withZValue:(int)zValue withID:(int)ID;
-(void)onSettingsButtonPressed;
-(void)incrementGameTimer;

@end

@implementation GameplayLayer

#pragma mark -
#pragma mark Memory Allocation

-(void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Initialisation

/**
 * Initialises the layer
 * @return self
 */
-(id)init 
{        
    CCLOG(@"GameplayLayer.init");
    
    self = [super init];
 
    if (self != nil) 
    {
        self.isTouchEnabled = YES; // enable touch
    
        srandom(time(NULL)); // set up a random number generator

        // reset the relevant data
        [[LemmingManager sharedLemmingManager] reset];
        [[GameManager sharedGameManager] resetSecondCounter];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Lemming_atlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Lemming_atlas.png"];
        
        [self addChild:sceneSpriteBatchNode z:0];
        [self initDisplay]; // set up the labels/buttons
        
        [self schedule:@selector(addLemming) interval:kLemmingSpawnSpeed]; // create some lemmings
        [self scheduleUpdate]; // set the update method to be called every frame
    }
            
    return self;
}

/**
 * Creates the in-game 'menu'
 * Initialises any buttons and labels in the layer
 */
-(void)initDisplay
{    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCMenuItem *settingsButton = [CCMenuItemImage itemFromNormalImage:@"settings.png" selectedImage:@"settings_down.png" target:self selector:@selector(onSettingsButtonPressed)];
    settingsButton.position = ccp(screenSize.width*0.91, screenSize.height*0.12f);
    
    gameplayMenu = [CCMenu menuWithItems:settingsButton, nil];
    gameplayMenu.position = CGPointZero;
    
    [self addChild:gameplayMenu];
    
    // now add the label
    
    // SET TEXT ALIGNMENT
    
    displayText = [CCLabelBMFont labelWithString:[self getUpdatedDisplayString] fntFile:@"bangla_dark.fnt"];
    
    [displayText setAnchorPoint:ccp(1, 1)];
    [displayText setPosition:ccp(screenSize.width-20, screenSize.height-20)];
    
    [self addChild:displayText];
}

#pragma mark -
#pragma mark Update

/**
 * Method called every frame
 */ 
-(void)update:(ccTime)deltaTime
{
    CCArray *gameObjects = [sceneSpriteBatchNode children];
        
    for (Lemming *tempLemming in gameObjects) 
    {
        [tempLemming updateStateWithDeltaTime:deltaTime andListOfGameObjects:gameObjects];
    }
    
    //update the display text
    [displayText setString:[self getUpdatedDisplayString]];
    
    [self incrementGameTimer];
}

/**
 *
 */
-(NSString*)getUpdatedDisplayString
{
    return [NSString stringWithFormat:@"saved: %i\nkilled: %i\ntime: %@", 
                            [[LemmingManager sharedLemmingManager] lemmingsSaved],
                            [[LemmingManager sharedLemmingManager] lemmingsKilled],
                            [[GameManager sharedGameManager] getGameTimeInMins]];
}

#pragma mark -
#pragma mark Object Creation

/**
 * Adds a lemming to the scene
 */
-(void)addLemming
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    int lemmingCount = [LemmingManager sharedLemmingManager].lemmingCount;
    
    [self createLemmingAtLocation:ccp(screenSize.width*kLemmingSpawnXPos, screenSize.height*kLemmingSpawnYPos) withHealth:100 withZValue:(lemmingCount+10) withID:lemmingCount];
}

/**
 * Creates a new Lemming object
 * @param withHealth
 * @param atLocation
 * @param withZvalue
 */
-(void)createLemmingAtLocation:(CGPoint)spawnLocation withHealth:(int)health withZValue:(int)zValue withID:(int)ID  
{
    if (![[LemmingManager sharedLemmingManager] lemmingsMaxed]) 
    {
        Lemming *lemming = [[Lemming alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Lemming_idle_1.png"]];
        lemming.ID = ID;
        lemming.health = health;
        
        if(COCOS2D_DEBUG > 1)
        {
            CCLabelBMFont *debugLabel = [CCLabelBMFont labelWithString:@"NoneNone" fntFile:@"helvetica_blue_small.fnt"];
            [self addChild:debugLabel];
            [lemming setDebugLabel:debugLabel];
        }
        
        [[LemmingManager sharedLemmingManager] addLemming:lemming]; 
        
        [lemming setPosition:spawnLocation]; 
        [sceneSpriteBatchNode addChild:lemming z:zValue tag:kLemmingSpriteTagValue];
        [lemming release];
    }
    else [self unschedule:@selector(addLemming)];
}

#pragma mark -

/**
 * Called when settings button's pressed
 */
-(void)onSettingsButtonPressed
{
    CCLOG(@"GameplayLayer.onSettingsButtonPressed");
    
    CCArray *gameObjects = [sceneSpriteBatchNode children];
    
    for (Lemming *tempLemming in gameObjects) 
    {
        if([tempLemming state] == kStateIdle) [tempLemming changeState:kStateWalking];
        else if([tempLemming state] == kStateWalking) [tempLemming changeState:kStateFloating];
        else if([tempLemming state] == kStateFloating) tempLemming.health = 0;
        else 
        {
            tempLemming.health = 100;
            [tempLemming changeState:kStateIdle];
        }
    }
}

/**
 * Called every frame, increments the game timer
 */
-(void)incrementGameTimer
{
    if(frameCounter == kFrameRate)
    {
        [[GameManager sharedGameManager] incrementSecondCounter];  
        frameCounter = 0;
    }
    else frameCounter++;
}

@end
