a-stat-objc-c
==============

A* Pathfinding Algorithm implemented in Objective-C

# Installation

You should clone this project and just copy/paste the files into your project, maybe under a new group.

# Usage

There are three things you need to worry about while using this library:

##`HSAIPathFindingNode`

The `HSAIPathFindingNode` contains all the logic for scoring a particular point, as well as comparing itself to other points. You shouldn't need to subclass this object, just use it as is.

##`HSAIPathFindingDelegate`

There are two required tasks for the `HSAIPathFindingDelegate`:

 - Figure out whether or not any given `HSAIPathFindingNode` is passable or not
 - Figure out the list of neighbors for any given `HSAIPathFindingNode`

In addition to the required delegate methods, there are two other methods available:

  - `nodeWasAddedToOpenList: (HSAIPathFindingNode *)node`: This is called whenever a node is added to the open list
  - `nodeWasAddedToPath: (HSAIPathFindingNode *)node`: This is called whenever a node is determined to be on the path

##`HSAIPathFinding`

You shouldn't need to subclass this either. 

###`HSAIPathFindingHeuristic`

There are three different ways to calculate the heuristic between any given node and the goal,

`[HSAIPathFindingHeuristic diagonalHeuristic]` - calculates the heuristic assuming 8 directions of travel
`[HSAIPathFindingHeuristic manhattanHeuristic]` - calculates the heuristic assuming 4 directions of travel
`[HSAIPathFindingHeuristic euclidianHeuristic]` - calculates the heuristic assuming any direction of travel

I've been using it like this:

```objective-c
// This is the class that will do the path finding
// MyPathFinder.h

#include <Foundation/Foundation.h>
#include "HSAIPathFinding.h"

@interface MyPathFinder : NSObject <HSAIPathFindingDelegate>
- (void) findPathFrom: (CGPoint) start to: (CGPoint): end;
@end

// MyPathFinder.m

@implementation MyPathFinder
- (void) findPathFrom: (CGPoint) start to: (CGPoint): end
{
  HSAIPathFinding *pathFinder = [[HSAIPathFinding alloc] init];
  pathFinder.delegate = self;
  pathFinder.heuristic = [HSAIPathFindingHeuristic diagonalHeuristic];

  [pathFinder findPathFrom: start to: end]; // returns an array of HSAIPathFindingNodes
}

- (BOOL) nodeIsPassable: (HSAIPathFindingNode *) node
{
  // The logic you use to figure out if a node is passable.
  return YES;
}

- (NSArray *) neighborsFor: (HSAIPathFindingNode *) node
{
  // The logic you use to figure out neighbors
  return [[NSArray alloc] init];
}

@end
```
