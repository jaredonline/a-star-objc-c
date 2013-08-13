//
//  HSAIPathFinding.m
//
//  Created by Jared McFarland on 8/12/13.
//

#import "HSAIPathFinding.h"

@implementation HSAIPathFindingNode

@synthesize point  = _point;
@synthesize gScore = _gScore;
@synthesize hScore = _hScore;
@synthesize parent = _parent;

- (id) initWithPosition:(CGPoint)position
{
  if (self = [super init]) {
    _point = position;
  }
  
  return self;
}

- (CGFloat) fScore
{
  return _gScore + _hScore;
}

- (BOOL) isEqualTo:(HSAIPathFindingNode *)object
{
  if (self.point.x == object.point.x && self.point.y == object.point.y)
    return true;
  else
    return false;
}

- (NSString *) description
{
  NSString *score = [NSString stringWithFormat:@"g: %.1f\th:%.1f\tf%.1f", self.gScore, self.hScore, [self fScore]];
  return [NSString stringWithFormat:@"{%d, %d}\t%@", (int)self.point.x, (int)self.point.y, score];
}
@end

@interface HSAIPathFinding ()

- (CGFloat) manhattanHeuristic: (HSAIPathFindingNode *) start to:(HSAIPathFindingNode *) end;
- (CGFloat) diagonalHeuristic: (HSAIPathFindingNode *) start to:(HSAIPathFindingNode *) end;
- (CGFloat) euclidianHeuristic: (HSAIPathFindingNode *) start to:(HSAIPathFindingNode *) end;
- (HSAIPathFindingNode *) node: (HSAIPathFindingNode *) target inList: (NSMutableArray *) list;
- (void)    removeNode: (HSAIPathFindingNode *) target fromList: (NSMutableArray *) list;

@end

@implementation HSAIPathFinding

@synthesize openList   = _openList;
@synthesize closedList = _closedList;
@synthesize heuristic  = _heuristic;
@synthesize delegate   = _delegate;

- (NSArray *)findPathFrom:(CGPoint)start to:(CGPoint)goal
{
  if (_heuristic == 0) {
    _heuristic = [HSAIPathFindingHeuristic diagonalHeuristic];
  }
  
  if (_delegate == nil) {
    _delegate = self;
  }
  
  HSAIPathFindingNode *startNode = [[HSAIPathFindingNode alloc] initWithPosition: start];
  HSAIPathFindingNode *endNode   = [[HSAIPathFindingNode alloc] initWithPosition: goal];
  
  startNode.gScore = 0;
  startNode.speed  = 0;
  startNode.hScore = [self heuristic: startNode to: endNode];
  
  _openList   = [[NSMutableArray alloc] initWithObjects:startNode, nil];
  _closedList = [[NSMutableArray alloc] init];
  
  HSAIPathFindingNode *current = [self cheapestNode];
  
  while (![current isEqualTo: endNode]) {
    [_closedList addObject: current];
    [self removeNode: current fromList: _openList];
    
    for (HSAIPathFindingNode * neighbor in [_delegate neighborsFor: current]) {
      if ([_delegate nodeIsPassable: neighbor])
      {
        
        CGFloat moveCost = [self gScore: neighbor to: current];
        CGFloat hCost    = [self heuristic: neighbor to: endNode];
        
        neighbor.speed  = moveCost;
        neighbor.gScore = current.gScore + neighbor.speed;
        neighbor.hScore = hCost;
        neighbor.parent = current;
        
        HSAIPathFindingNode *nodeInList = nil;
        
        if ((nodeInList = [self node: neighbor inList: _openList]) != nil) {
          if (neighbor.gScore < nodeInList.gScore) {
            [_openList removeObject: nodeInList];
            [_openList addObject: neighbor];
          }
        } else if ((nodeInList = [self node: neighbor inList: _closedList]) != nil) {
          if (neighbor.gScore < nodeInList.gScore) {
            [_closedList removeObject: nodeInList];
            [_openList   addObject: neighbor];
          }
        } else {
          if ([_delegate respondsToSelector:@selector(nodeWasAddedToOpenList:)]) {
            [_delegate nodeWasAddedToOpenList: neighbor];
          }
          [_openList addObject: neighbor];
        }
      }
    }
    
    current = [self cheapestNode];
  }
  
  NSMutableArray *path = [[NSMutableArray alloc] init];
  while (current.parent != nil) {
    [path insertObject: current atIndex:0];
    if ([_delegate respondsToSelector:@selector(nodeWasAddedToPath:)]) {
      [_delegate nodeWasAddedToPath: current];
    }
    current = current.parent;
  }
  
  return [NSArray arrayWithArray: path];
}

- (HSAIPathFindingNode *) cheapestNode
{
  HSAIPathFindingNode *cheapest = [self.openList objectAtIndex:0];
  
  for (HSAIPathFindingNode * node in self.openList) {
    if ([node fScore] < [cheapest fScore])
      cheapest = node;
  }
  
  return cheapest;
}

- (void) removeNode:(HSAIPathFindingNode *)target fromList:(NSMutableArray *)list
{
  HSAIPathFindingNode *node = [self node:target inList:list];
  if (node != nil) {
    [list removeObject: node];
  }
}

- (HSAIPathFindingNode *) node:(HSAIPathFindingNode *)target inList:(NSMutableArray *)list
{
  HSAIPathFindingNode *retNode = nil;
  for (HSAIPathFindingNode *node in list) {
    if ([target isEqualTo: node])
      retNode = node;
  }
  
  return retNode;
}

# pragma mark HSAIPathFindingDelegate methods

- (BOOL) nodeIsPassable:(HSAIPathFindingNode *)node
{
  return YES;
}

- (NSArray *) neighborsFor:(HSAIPathFindingNode *)node
{
  return [[NSArray alloc] init];
}

# pragma mark Heuristic methods

- (CGFloat) gScore:(HSAIPathFindingNode *)start to:(HSAIPathFindingNode *)end {
  NSInteger dx = abs((int)start.point.x - (int)end.point.x);
  NSInteger dy = abs((int)start.point.y - (int)end.point.y);
  
  return sqrt((dx * dx) + (dy * dy));
}

- (CGFloat) heuristic: (HSAIPathFindingNode *)start to: (HSAIPathFindingNode *) end
{
  if (_heuristic == [HSAIPathFindingHeuristic manhattanHeuristic]) {
    return [self manhattanHeuristic:start to:end];
  } else if (_heuristic == [HSAIPathFindingHeuristic diagonalHeuristic]) {
    return [self diagonalHeuristic:start to:end];
  } else if (_heuristic == [HSAIPathFindingHeuristic euclidianHeuristic]) {
    return [self euclidianHeuristic:start to:end];
  } else {
    return 0.0;
  }
}

- (CGFloat) diagonalHeuristic:(HSAIPathFindingNode *)start to:(HSAIPathFindingNode *)end
{
  NSInteger dx  = abs((int)start.point.x - (int)end.point.x);
  NSInteger dy  = abs((int)start.point.y - (int)end.point.y);
  NSInteger min = MIN(dx, dy);
  NSInteger max = MAX(dx, dy);
  CGFloat   d2  = sqrt(2);
  
  return (min * d2) + (max - min);
}

- (CGFloat) manhattanHeuristic:(HSAIPathFindingNode *)start to:(HSAIPathFindingNode *)end
{
  NSInteger dx = abs((int)start.point.x - (int)end.point.x);
  NSInteger dy = abs((int)start.point.y - (int)end.point.y);
  
  return dy + dx;
}

- (CGFloat) euclidianHeuristic:(HSAIPathFindingNode *)start to:(HSAIPathFindingNode *)end
{
  NSInteger dx = abs((int)start.point.x - (int)end.point.x);
  NSInteger dy = abs((int)start.point.y - (int)end.point.y);
  
  return sqrt((dx * dx) + (dy * dy));
}

@end


@implementation HSAIPathFindingHeuristic

+ (NSInteger) diagonalHeuristic
{
  return HSAIDiagonalHeuristic;
}

+ (NSInteger) manhattanHeuristic
{
  return HSAIManhattanHeuristic;
}

+ (NSInteger) euclidianHeuristic
{
  return HSAIEuclidianHeuristic;
}

@end
