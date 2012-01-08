//
//  TerrainLayer.m
//  Cogito
//
//  A generic 'terrain' layer.
//  each level inherits from this class
//
//  24/12/2011: Created class
//

#import "TerrainLayer.h"

@interface TerrainLayer()

-(void)loadTerrainFromPlist;

@end

@implementation TerrainLayer

#pragma mark -
#pragma mark Initialisation

/**
 * Initialises the layer
 * @return self
 */
-(id)init:(NSString*)_plist 
{    
	self = [super init];
    
	if (self != nil) 
	{
        plistFilename = _plist;
        
        terrain = [[CCArray alloc] init];
        obstacles = [[CCArray alloc] init];
		
        [self loadTerrainFromPlist];
	}
    
	return self;
}

/**
 * Initialises the terrain from the plist file
 */
-(void)loadTerrainFromPlist
{        
    // Get path to plist file
    NSString *filename = [NSString stringWithFormat:@"%@.plist", plistFilename];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:filename];
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) plistPath = [[NSBundle mainBundle] pathForResource:plistFilename ofType:@"plist"];
    
    // Read plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // if plistDictionary is empty, throw file not found error
    if(plistDictionary == nil) { CCLOG(@"%@.loadTerrainFromPlist: Error reading plist: %@ from %@", NSStringFromClass([self class]), plistFilename, plistPath); return; }
    
    for(NSDictionary *object in plistDictionary)
    {
        NSDictionary *objectDictionary = [plistDictionary objectForKey:object];
    
        // store the attributes shared by terrain and obstacles
        NSString *type = [objectDictionary objectForKey:@"type"];
        float x = [[objectDictionary objectForKey:@"x"] floatValue];
        float y = [[objectDictionary objectForKey:@"y"] floatValue];
        NSString *filename = [NSString stringWithFormat:@"%@.png", [objectDictionary objectForKey:@"filename"]];
        
        if([type isEqualToString:@"terrain"])
        {
            BOOL isWall = [[objectDictionary objectForKey:@"isWall"] boolValue];
            BOOL isCollideable = [[objectDictionary objectForKey:@"isCollideable"] boolValue];
            if([objectDictionary objectForKey:@"isCollideable"] == nil) isCollideable = YES;
                        
            Terrain *terrainObject = [[Terrain alloc] initWithPosition:ccp(x,y) andFilename:filename isWall:isWall];
            terrainObject.isCollideable = isCollideable;
            [self addChild:terrainObject];
            [terrain addObject:terrainObject];
        }
        else if([type isEqualToString:@"obstacle"])
        {
            GameObjectType gameObjectType;
            NSString *obstacleType = [objectDictionary objectForKey:@"obstacleType"];
            
            if([obstacleType isEqualToString:@"spikes"]) gameObjectType = kObstaclePit;
            else if([obstacleType isEqualToString:@"cage"]) gameObjectType = kObstacleCage;
            else if([obstacleType isEqualToString:@"water"]) gameObjectType = kObstacleWater;
            else if([obstacleType isEqualToString:@"stamper"]) gameObjectType = kObstacleStamper;
                        
            Obstacle *obstacleObject = [[Obstacle alloc] initObstacleType:gameObjectType withPosition:ccp(x,y) andFilename:filename];
            [obstacles addObject:obstacleObject];
            [self addChild:obstacleObject];
        }
    }
}


/**
 * Getters/Setters
 */

#pragma mark -
#pragma mark Getters/Setters

/**
 * Returns the list of terrain objects
 * @return terrain
 */
-(CCArray*)terrain
{
    return terrain;
}


/**
 * Returns the list of obstacle objects
 * @return obstacle
 */
-(CCArray*)obstacles
{
    return obstacles;
}

@end
