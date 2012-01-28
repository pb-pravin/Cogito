//
//  Constants.h
//  Author: Thomas Taylor
//
//  Constants used in the game
//
//  21/11/2011: Created class
//

#ifndef Cogito_Constants_h
#define Cogito_Constants_h

#define DEBUG_MODE              1

#define kFrameRate              60.0f

#define kDefaultLargeFont       @"bangla_dark.fnt"
#define kDefaultSmallFont       @"bangla_dark_small.fnt"

#define kRLearningRate          0.0f
#define kRLDiscountFactor       0.99f
#define kRLRandomFactor         4

#define kLemmingMovementAmount  20
#define kLemmingFallTime        0.85f
#define kLemmingRespawns        5
#define kLemmingTotal           1
#define kLemmingSpawnSpeed      1.5f

#define kUISpriteZValue         300
#define kTerrainZValue          50
#define kObstacleZValue         10

#define kLemmingSpriteZValue    100
#define kLemmingSpriteTagValue  0

#define kMainMenuTagValue       10
#define kSceneMenuTagValue      20

#endif