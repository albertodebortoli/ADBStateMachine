//
//  ADBStateMachineTransition.h
//  ADBStateMachine
//
//  Created by Alberto De Bortoli on 09/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADBStateMachineTransition : NSObject

@property (nonatomic, copy, readonly) NSString *fromState;
@property (nonatomic, copy, readonly) NSString *toState;
@property (nonatomic, copy, readonly) NSString *event;

- (instancetype)initWithEvent:(NSString *)event
                    fromState:(NSString *)fromState
                      toState:(NSString *)toState
                     preBlock:(dispatch_block_t)preBlock
                    postBlock:(dispatch_block_t)postBlock;

- (void)processPreBlock;
- (void)processPostBlock;

@end
