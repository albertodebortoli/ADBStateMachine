//
//  ADBStateMachine.m
//  ADBStateMachine
//
//  Created by Alberto De Bortoli on 09/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBStateMachine.h"

@interface ADBStateMachine ()

@property (nonatomic, copy) NSString *currentState;
@property (nonatomic, strong) NSMutableSet *allowedStates;
@property (nonatomic, strong) NSMutableSet *allowedEvents;
@property (nonatomic, strong) NSMutableDictionary *transitionsByEvent;

@end

@implementation ADBStateMachine
{
    dispatch_queue_t _lockQueue;
}

- (instancetype)initWithInitialState:(NSString *)state queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _currentState = state;
        _allowedStates = [NSMutableSet set];
        _allowedEvents = [NSMutableSet set];
        _transitionsByEvent = [NSMutableDictionary dictionary];
        _lockQueue = queue ? queue : dispatch_get_main_queue();
    }
    
    return self;
}

- (void)addTransition:(ADBStateMachineTransition *)transition
{
    [self.allowedEvents addObject:transition.event];
    [self.allowedStates addObject:transition.fromState];
    [self.allowedStates addObject:transition.toState];
    
    NSMutableSet *transistionsByEvent = self.transitionsByEvent[transition.event];
    if (!transistionsByEvent) {
        transistionsByEvent = [NSMutableSet set];
    }
    // check if there is already a transition from the given fromState using the given event
    [transistionsByEvent addObject:transition];
    self.transitionsByEvent[transition.event] = transistionsByEvent;
}

- (void)processEvent:(NSString *)event
{
    NSSet *transitions = self.transitionsByEvent[event];
    
    for (ADBStateMachineTransition *transition in transitions) {
        if ([transition.fromState isEqualToString:self.currentState]) {
            dispatch_async(_lockQueue, ^{
                NSLog(@"Processing event '%@' from state '%@'", event, self.currentState);
                [transition processPreBlock];
                NSLog(@"Processed pre condition for event '%@' from state '%@' to state '%@'", event, transition.fromState, transition.toState);
                self.currentState = transition.toState;
                NSLog(@"Processed state changed from state '%@' to state '%@'", self.currentState, transition.toState);
                [transition processPostBlock];
                NSLog(@"Processed post condition for event '%@' from state '%@' to state '%@'", event, transition.fromState, transition.toState);
            });
        }
    }
}

@end
