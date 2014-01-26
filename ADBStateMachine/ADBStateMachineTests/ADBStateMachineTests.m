//
//  ADBStateMachineTests.m
//  ADBStateMachineTests
//
//  Created by Alberto De Bortoli on 11/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "ADBStateMachine.h"

SPEC_BEGIN(ADBStateMachineSpec)

describe(@"The state machine", ^{

    NSString *initialState = @"Idle";
    __block ADBStateMachine *stateMachine = nil;
    __block ADBStateMachine *stateMachineWithCallBackQueue = nil;
    __block dispatch_queue_t callbackQueue = nil;
    __block BOOL preCondition;
    __block BOOL postCondition;
    
    beforeEach(^{
        stateMachine = [[ADBStateMachine alloc] initWithInitialState:initialState callbackQueue:nil];
        
        callbackQueue = dispatch_queue_create("com.albertodebortoli.statemachine.queue.callback", DISPATCH_QUEUE_SERIAL);
        stateMachineWithCallBackQueue = [[ADBStateMachine alloc] initWithInitialState:initialState callbackQueue:callbackQueue];
        
        ADBStateMachineTransition *t1 = [ADBStateMachineTransition transitionWithEvent:@"start"
                                                                             fromState:@"Idle"
                                                                               toState:@"Started"
                                                                              preBlock:^{
                                                                                  preCondition = YES;
                                                                              } postBlock:^{
                                                                                  postCondition = YES;
                                                                              }];
        ADBStateMachineTransition *t2 = [ADBStateMachineTransition transitionWithEvent:@"stop"
                                                                             fromState:@"Started"
                                                                               toState:@"Idle"
                                                                              preBlock:^{
                                                                                  preCondition = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                                                                                  [[dispatch_get_current_queue() should] equal:callbackQueue];
#pragma clang diagnostic pop
                                                                              }
                                                                             postBlock:^{
                                                                                 postCondition = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                                                                                 [[dispatch_get_current_queue() should] equal:callbackQueue];
#pragma clang diagnostic pop
                                                                             }];
        [stateMachineWithCallBackQueue addTransition:t2];
        
        [stateMachine addTransition:t1];
        preCondition = NO;
        postCondition = NO;
    });
    
    afterEach(^{
        stateMachine = nil;
        stateMachineWithCallBackQueue = nil;
        preCondition = NO;
        postCondition = NO;
        callbackQueue = nil;
    });
    
    context(@"when created with initial state", ^{
        it(@"returns a valid instance with the given state", ^{
            [[stateMachine.currentState should] equal:initialState];
        });
    });
    
    context(@"when sent an unknown or a not allowed event", ^{
        it(@"the state doesn't change", ^{
            [stateMachine processEvent:@"run"];
            [[expectFutureValue(stateMachine.currentState) shouldEventually] equal:initialState];
        });
    });
    
    context(@"when sent an allowed event", ^{
        it(@"the preblock is executed", ^{
            [stateMachine processEvent:@"start"];
            [[expectFutureValue(@(preCondition)) shouldEventually] equal:@YES];
        });

        it(@"the state changes", ^{
            [stateMachine processEvent:@"start"];
            [[expectFutureValue(stateMachine.currentState) shouldEventually] equal:@"Started"];
        });
        
    
        it(@"the postblock is executed", ^{
            [stateMachine processEvent:@"start"];
            [[expectFutureValue(@(postCondition)) shouldEventually] equal:@YES];
        });
    });
    
    context(@"when created with callback queue", ^{
        it(@"the preblock is executed in the callback queue", ^{
            [stateMachine processEvent:@"start"];
            [stateMachine processEvent:@"stop"];
            [[expectFutureValue(@(preCondition)) shouldEventually] equal:@YES];
        });
    });
    
    context(@"when created with callback queue", ^{
        it(@"the postblock is executed in the callback queue", ^{
            [stateMachine processEvent:@"start"];
            [stateMachine processEvent:@"stop"];
            [[expectFutureValue(@(postCondition)) shouldEventually] equal:@YES];
        });
    });
    
});

SPEC_END
