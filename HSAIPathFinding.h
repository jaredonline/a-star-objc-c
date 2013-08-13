//
//  HSAIPathFinding.h
//
//  Created by Jared McFarland on 8/12/13.
//

#import <Foundation/Foundation.h>

#define HSAIManhattanHeuristic 1
#define HSAIDiagonalHeuristic  2
#define HSAIEuclidianHeuristic 3

@interface HSAIPathFindingNode : NSObject

@property (nonatomic) CGPoint   point;
@property (nonatomic) CGFloat   gScore;
@property (nonatomic) CGFloat   hScore;
@property (nonatomic) CGFloat   speed;

@property (nonatomic, retain) HSAIPathFindingNode *parent;

- (id)        initWithPosition: (CGPoint) position;
- (CGFloat)   fScore;
- (BOOL)      isEqualTo:(HSAIPathFindingNode *) object;

@end

@protocol HSAIPathFindingDelegate

- (BOOL) nodeIsPassable: (HSAIPathFindingNode *) node;
- (NSArray *) neighborsFor: (HSAIPathFindingNode *) node;

@optional
- (void) nodeWasAddedToOpenList: (HSAIPathFindingNode *) node;
- (void) nodeWasAddedToPath: (HSAIPathFindingNode *) node;

@end

@interface HSAIPathFinding : NSObject <HSAIPathFindingDelegate>

@property (nonatomic, retain) NSMutableArray *openList;
@property (nonatomic, retain) NSMutableArray *closedList;
@property (nonatomic, assign) id             delegate;

@property (nonatomic) NSInteger heuristic;

- (NSArray *)findPathFrom: (CGPoint)start to: (CGPoint)goal;
- (HSAIPathFindingNode *) cheapestNode;
- (CGFloat) heuristic: (HSAIPathFindingNode *)start to: (HSAIPathFindingNode *) end;
- (CGFloat) gScore: (HSAIPathFindingNode *) start to: (HSAIPathFindingNode *) end;

@end

@interface HSAIPathFindingHeuristic : NSObject

+ (NSInteger) diagonalHeuristic;
+ (NSInteger) manhattanHeuristic;
+ (NSInteger) euclidianHeuristic;

@end
