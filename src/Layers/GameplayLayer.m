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

@implementation GameplayLayer

-(void)dealloc
{
    [settingsButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialisation

-(id)init 
{    
    self = [super init];
 
    if (self != nil) 
    {
        CGSize windowSize = [CCDirector sharedDirector].winSize;
    
        self.isTouchEnabled = YES; // enable touch
    
        srandom(time(NULL)); // set up a random number generator
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Lemming_atlas.plist"];
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Lemming_atlas.png"];
        
        [self addChild:sceneSpriteBatchNode z:0];
        [self initButtons]; // set up the buttons
    
        //
        //
        //
        // instantiate lemming manager
        //
        //
        //
        
        /*
         * Create a few lemmings...
         */
        for (int i = 0; i < 25; i++) 
            [self createObjectofType:kLemmingType withHealth: 100 atLocation:ccp(windowSize.width*0.07f, windowSize.height*0.90f) withZValue: (i+10)];
        
        //Obstacle *testObstacle = [[Obstacle alloc] init:kObstaclePit];
        
        [self scheduleUpdate]; // set the update method to be called every frame
    }
    
    return self;
}

-(void)initButtons
{
    CCLOG(@"GameplayLayer.initButtons");
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGRect settingsButtonDimensions = CGRectMake(0, 0, 64.0f, 64.0f);
    CGPoint settingsButtonPosition = ccp(screenSize.width*0.90, screenSize.width*0.10f);
    
    SneakyButtonSkinnedBase *settingsButtonBase = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
    settingsButtonBase.position = settingsButtonPosition;
    settingsButtonBase.defaultSprite = [CCSprite spriteWithFile:@"settings.png"];
    settingsButtonBase.activatedSprite = [CCSprite spriteWithFile:@"settings.png"];
    settingsButtonBase.pressSprite = [CCSprite spriteWithFile:@"settings_down.png"];
    settingsButtonBase.button = [[SneakyButton alloc] initWithRect:settingsButtonDimensions];
    
    settingsButton = [settingsButtonBase.button retain];
    settingsButton.isToggleable = YES;
    
    [self addChild:settingsButtonBase];
}

#pragma mark -
#pragma mark Update

-(void)update:(ccTime)deltaTime
{
    CCArray *gameObjects = [sceneSpriteBatchNode children];
    
    for (Lemming *tempLemming in gameObjects) 
        [tempLemming updateStateWithDeltaTime:deltaTime andListOfGameObjects:gameObjects];
    
    [self checkButtons];
}

#pragma mark -
#pragma mark Object Creation

-(void)createObjectofType:(GameObjectType)objectType withHealth:(int)health atLocation:(CGPoint)spawnLocation withZValue:(int)zValue
{
    if(objectType == kLemmingType)
    {
        Lemming *lemming = [[Lemming alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Lemming_idle_1.png"]];
        [lemming setPosition:spawnLocation]; 
        [sceneSpriteBatchNode addChild:lemming z:zValue tag:kLemmingSpriteTagValue];
        [lemming release];
    }
    else CCLOG(@"GameplayLayer.createObjectofType: ObjectType not supported");
}

#pragma mark -

-(void)checkButtons
{
    if (settingsButton.active) 
    {
        CCLOG(@"Settings button pressed...");
        
        CCArray *gameObjects = [sceneSpriteBatchNode children];
        
        for (Lemming *tempLemming in gameObjects) 
            if([tempLemming state] == kStateIdle) [tempLemming changeState:kStateWalking];
            else if([tempLemming state] == kStateWalking) [tempLemming changeState:kStateFloating];
            else if([tempLemming state] == kStateFloating) tempLemming.health = 0;
            else 
            {
                tempLemming.health = 100;
                [tempLemming changeState:kStateIdle];
            }
        
        /*
         * Need to open settings screen
         * - on screen open, pause the game
         * - on screen close, update the state of the system 
         * based on which settings have been changed (if any)
         */
    }
}

@end
