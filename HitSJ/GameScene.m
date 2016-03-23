//
//  GameScene.m
//  HitSJ
//
//  Created by zoolsher on 16/3/21.
//  Copyright (c) 2016年 ZooTech. All rights reserved.
//

#import "GameScene.h"
#import "Ball.h"
#define DOTSIZE 50
#define DOTNUM 200
#define EMPTYCOLOR 100
BOOL FIRST = NO;
typedef NS_OPTIONS(int, ColorType){
    GREEN,RED,BLUE
};
@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.colorMap = [NSArray arrayWithObjects:[NSColor blueColor],[NSColor greenColor],[NSColor redColor],[NSColor blackColor],nil];
    /* Setup your scene here */
    [self initMap];
    [self initDots];
    
}

-(void)initMap{

    self.physicsWorld.gravity = CGVectorMake(0, -10);
    int widthNumber = (int)self.frame.size.width/DOTSIZE ;
    int heightNumber = (int)self.frame.size.height/DOTSIZE ;
    self.widthNumber = widthNumber;
    self.heightNumber = heightNumber;
    
    self.balls = [NSMutableArray array];
    
    SKSpriteNode *node = [[SKSpriteNode alloc]initWithColor:[NSColor grayColor] size:CGSizeMake(widthNumber*DOTSIZE, heightNumber*DOTSIZE)];
    node.anchorPoint = CGPointMake(0.5, 0.5);
    node.name=@"nodeGray";
    node.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addChild:node];
    for(int w = 0; w<widthNumber;w++){
        for (int h = 0; h<heightNumber; h++) {
            if ((w+h)%2) {
                CGPoint p = node.frame.origin;
                p.x += w*DOTSIZE;
                p.y += h*DOTSIZE;
                [self drawDot:p];
                
            }
        }
    }
    self.background = node;
}


-(void)drawDot:(CGPoint)point{
    SKSpriteNode *node = [[SKSpriteNode alloc]initWithColor:[SKColor whiteColor] size:CGSizeMake(DOTSIZE,DOTSIZE)];
    node.anchorPoint = CGPointMake(0,0);
    node.position = point;
    node.name=@"nodeWhite";
    [self addChild:node];
}
-(void)initDots{
    /**
     * init the colorArray
     */
    self.colorArray = (int*)malloc(self.widthNumber*self.heightNumber*sizeof(int));
    for (int l = 0;l<self.widthNumber*self.heightNumber;l++){
        *(self.colorArray+l) = (int)EMPTYCOLOR;
    }
    for (int i = 0; i < DOTNUM; i++) {
        if (DOTNUM>self.widthNumber*self.heightNumber) {
            break;
        }
        NSLog(@"%f",floor(i*[self.colorMap count]/DOTNUM));
        *(self.colorArray + i) = floor(i*[self.colorMap count]/DOTNUM);
        
//        if (3*i<DOTNUM) {
//            *(self.colorArray+i) = GREEN;
//        }else if (1.5*i<DOTNUM){
//            *(self.colorArray+i) = RED;
//        }else{
//            *(self.colorArray+i) = BLUE;
//        }
    }
    /**
     * random break the colorArray
     */
    for (int j = 0; j<self.widthNumber*self.heightNumber; j++) {
        int swanper = arc4random_uniform(self.widthNumber*self.heightNumber-1);
        int temp = *(self.colorArray + j);
        *(self.colorArray +j) = *(self.colorArray + swanper);
        *(self.colorArray + swanper) = temp;
    }
    /**
     * init balls
     */
    for (int k = 0; k<self.widthNumber*self.heightNumber; k++) {
        Ball *ball;
        BOOL isContinue = NO;
        NSLog(@"%i",*(self.colorArray + k));
        if (*(self.colorArray + k)!=EMPTYCOLOR) {
            ball = [Ball initBallWithColor:(NSColor *)[self.colorMap objectAtIndex:*(self.colorArray + k)]];
        }else{
            isContinue = YES;
        }
        
//        switch (*(self.colorArray+k)) {
//            case GREEN:
//                ball = [Ball initBallWithColor:[SKColor greenColor]];
//                break;
//            case RED:
//                ball = [Ball initBallWithColor:[SKColor redColor]];
//                break;
//            case BLUE:
//                ball = [Ball initBallWithColor:[SKColor blueColor]];
//                break;
//            case EMPTYCOLOR:
//                isContinue = YES;
//            default:
//                isContinue = YES;
//        }
        if (isContinue) {
            continue;
        }else{
            ball.name=@"ball";
            ball.position = [self convertPointWithDotNumber:k];
            [self addChild:ball];
            [self.balls addObject:ball];
        }
    }
}

-(int *)colorArrayAccessWidth:(int)width andHeight:(int)height{
    return (self.colorArray+height*self.widthNumber + width);
}

-(CGPoint)convertPointWithWidth:(int)width withHeight:(int)height{
    CGPoint origin = self.background.frame.origin;
    CGFloat x = origin.x + width*DOTSIZE;
    CGFloat y = origin.y + height*DOTSIZE;
    return CGPointMake(x, y);
}

-(CGPoint)convertPointWithDotNumber:(int)dotNumber{
    int height = (int)dotNumber/self.widthNumber;
    int width = (int)dotNumber%self.widthNumber;
    return [self convertPointWithWidth:width withHeight:height];
}

-(void)mouseDown:(NSEvent *)theEvent {
    /* Called when a mouse click occurs */
    
    CGPoint location = [theEvent locationInNode:self];
    CGPoint orgion = self.background.frame.origin;
    int width = (location.x - orgion.x)/DOTSIZE;
    int height = (location.y - orgion.y)/DOTSIZE;
    int *color = [self colorArrayAccessWidth:width andHeight:height];
    
    
    /**
     * init the temp data for checking;
     */
    NSMutableArray<Ball *>* dirBall = [NSMutableArray array];
    NSArray<SKNode *>* nodes;
    CGPoint p;
    BOOL isBreak = NO;
    
    
    /**
     * if the click point is not EMPTYCOLOR then shit it
     */
    if (*color == EMPTYCOLOR) {
        /**
         *loop the upper Color
         */
        int tempH = height;
        int tempW = width;
        while ( true) {
            tempH++;
            /**
             *check if break out of bounds
             */
            if (tempH>=self.heightNumber) {
                break;
            }
            /**
             * check the one with color on it, then put the ball into dirBall;
             */
            switch (*[self colorArrayAccessWidth:tempW andHeight:tempH]) {
                case EMPTYCOLOR:
                    continue;
                    break;
                    
                default:
                    p = [self convertPointWithWidth:tempW
                                         withHeight:tempH];
                    p.x += 0.5*DOTSIZE;
                    p.y += 0.5*DOTSIZE;
                    nodes = [self nodesAtPoint:p];
                    for (SKNode *node in nodes) {
                        if ([node isKindOfClass:[Ball class]]) {
                            Ball *ball = (Ball *)node;
                            [dirBall addObject:ball];
                            isBreak = YES;
                            break;
                        }
                    }
                    break;
            }
            if (isBreak) {
                break;
            }
        }
        
        /**
         * check y--;
         */
        isBreak = NO;
        tempH = height;
        tempW = width;
        while (true) {
            tempH--;
            /**
             *check if break out of bounds
             */
            if (tempH<0) {
                break;
            }
            /**
             * check the one with color on it, then put the ball into dirBall;
             */
            switch (*[self colorArrayAccessWidth:tempW andHeight:tempH]) {
                case EMPTYCOLOR:
                    continue;
                    break;
                    
                default:
                    p = [self convertPointWithWidth:tempW
                                         withHeight:tempH];
                    p.x += 0.5*DOTSIZE;
                    p.y += 0.5*DOTSIZE;
                    nodes = [self nodesAtPoint:p];
                    for (SKNode *node in nodes) {
                        if ([node isKindOfClass:[Ball class]]) {
                            Ball *ball = (Ball *)node;
                            [dirBall addObject:ball];
                            isBreak = YES;
                            break;
                        }
                    }
                    break;
            }
            if (isBreak) {
                break;
            }
            
            
        }

        
        /**
         * check x--;
         */
        isBreak = NO;
        tempH = height;
        tempW = width;
        while (true) {
            tempW--;
            /**
             *check if break out of bounds
             */
            if (tempW<0) {
                break;
            }
            /**
             * check the one with color on it, then put the ball into dirBall;
             */
            switch (*[self colorArrayAccessWidth:tempW andHeight:tempH]) {
                case EMPTYCOLOR:
                    continue;
                    break;
                    
                default:
                    p = [self convertPointWithWidth:tempW
                                         withHeight:tempH];
                    p.x += 0.5*DOTSIZE;
                    p.y += 0.5*DOTSIZE;
                    nodes = [self nodesAtPoint:p];
                    for (SKNode *node in nodes) {
                        if ([node isKindOfClass:[Ball class]]) {
                            Ball *ball = (Ball *)node;
                            [dirBall addObject:ball];
                            isBreak = YES;
                            break;
                        }
                    }
                    break;
            }
            if (isBreak) {
                break;
            }
        }

        /**
         * check x++;
         */
        isBreak = NO;
        tempH = height;
        tempW = width;
        while (true) {
            tempW++;
            /**
             *check if break out of bounds
             */
            if (tempW>=self.widthNumber) {
                break;
            }
            /**
             * check the one with color on it, then put the ball into dirBall;
             */
            switch (*[self colorArrayAccessWidth:tempW andHeight:tempH]) {
                case EMPTYCOLOR:
                    continue;
                    break;
                    
                default:
                    p = [self convertPointWithWidth:tempW
                                         withHeight:tempH];
                    p.x += 0.5*DOTSIZE;
                    p.y += 0.5*DOTSIZE;
                    nodes = [self nodesAtPoint:p];
                    for (SKNode *node in nodes) {
                        if ([node isKindOfClass:[Ball class]]) {
                            Ball *ball = (Ball *)node;
                            [dirBall addObject:ball];
                            isBreak = YES;
                            break;
                        }
                    }
                    break;
            }
            if (isBreak) {
                break;
            }
        }
    }
    NSMutableDictionary<NSColor*,NSMutableArray<Ball *>*>*bucket = [NSMutableDictionary dictionary];
    for (Ball *ball in dirBall) {
        NSColor * color = ball.color;
        NSMutableArray<Ball*>* ballTemp = [bucket objectForKey:color];
        if(ballTemp == nil){
            ballTemp = [NSMutableArray array];
        }
        [ballTemp addObject:ball];
        [bucket setObject:ballTemp forKey:color];
    }


    [bucket enumerateKeysAndObjectsUsingBlock:^(NSColor * _Nonnull key, NSMutableArray<Ball *> * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj count]>1) {
            for (Ball * ball in obj) {
                CGPoint location = ball.position;
                CGPoint orgion = self.background.frame.origin;
                int width = (location.x - orgion.x)/DOTSIZE;
                int height = (location.y - orgion.y)/DOTSIZE;
                int *color = [self colorArrayAccessWidth:width andHeight:height];
                *color = EMPTYCOLOR;
                [ball fall];

            }
        }
        stop = NO;
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    if(FIRST == NO){
        FIRST = YES;
        NSLog(@"firstFrame");
    }

    /* Called before each frame is rendered */
    NSMutableArray<Ball *>*list = [NSMutableArray array];
    for(Ball *ball in self.balls){
        if (!CGRectContainsPoint(self.frame, ball.position)) {
            [ball removeFromParent];
            [list addObject:ball];
        }
    }
    [self.balls removeObjectsInArray:list];
    [list removeAllObjects];
}
@end
