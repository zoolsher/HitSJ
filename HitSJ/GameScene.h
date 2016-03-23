//
//  GameScene.h
//  HitSJ
//

//  Copyright (c) 2016年 ZooTech. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class Ball;
@interface GameScene : SKScene
@property (nonatomic) NSArray <NSColor *> * colorMap;
@property (assign,nonatomic) int *colorArray;
@property (assign,nonatomic) SKSpriteNode *background;
@property (nonatomic) NSMutableArray<Ball*>*balls;
@property (assign,nonatomic) int heightNumber;
@property (assign,nonatomic) int widthNumber;
@end
