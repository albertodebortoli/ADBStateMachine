//
//  ADBStateMachineTransition.m
//  ADBStateMachine
//
//  Created by Alberto De Bortoli on 09/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBStateMachineTransition.h"

@interface ADBStateMachineTransition ()

@property (nonatomic, copy) NSString *fromState;
@property (nonatomic, copy) NSString *toState;
@property (nonatomic, copy) NSString *event;
@property (nonatomic, copy) dispatch_block_t preBlock;
@property (nonatomic, copy) dispatch_block_t postBlock;

@end

@implementation ADBStateMachineTransition

+ (instancetype)transitionWithEvent:(NSString *)event
                          fromState:(NSString *)fromState
                            toState:(NSString *)toState
                           preBlock:(dispatch_block_t)preBlock
                          postBlock:(dispatch_block_t)postBlock
{
    return [[self alloc] initWithEvent:event
                             fromState:fromState
                               toState:toState
                              preBlock:preBlock
                             postBlock:postBlock];
}

- (instancetype)initWithEvent:(NSString *)event
                    fromState:(NSString *)fromState
                      toState:(NSString *)toState
                     preBlock:(dispatch_block_t)preBlock
                    postBlock:(dispatch_block_t)postBlock
{
    self = [super init];
    if (self) {
        _event = [event copy];
        _fromState = [fromState copy];
        _toState = [toState copy];
        _preBlock = [preBlock copy];
        _postBlock = [postBlock copy];
    }
    
    return self;
}

- (void)processPreBlock
{
    if (self.preBlock) {
        self.preBlock();
    }
}

- (void)processPostBlock
{
    if (self.postBlock) {
        self.postBlock();
    }
}

@end
