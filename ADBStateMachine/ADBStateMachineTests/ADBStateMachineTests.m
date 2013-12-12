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
    __block BOOL preCondition;
    __block BOOL postCondition;
    
    beforeEach(^{
        stateMachine = [[ADBStateMachine alloc] initWithInitialState:initialState queue:nil];
        
        ADBStateMachineTransition *t1 = [ADBStateMachineTransition transitionWithEvent:@"start"
                                                                             fromState:@"Idle"
                                                                               toState:@"Started"
                                                                              preBlock:^{
                                                                                  preCondition = YES;
                                                                              } postBlock:^{
                                                                                  postCondition = YES;
                                                                              }];
        
        [stateMachine addTransition:t1];
        preCondition = NO;
        postCondition = NO;
    });
    
    afterEach(^{
        stateMachine = nil;
        preCondition = NO;
        postCondition = NO;
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
    
});

SPEC_END
