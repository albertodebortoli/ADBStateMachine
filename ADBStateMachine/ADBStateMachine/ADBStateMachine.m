//
//  ADBStateMachine.m
//  ADBStateMachine
//
//  Created by Alberto De Bortoli on 09/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBStateMachine.h"

@interface ADBStateMachine ()

@property (atomic, copy) NSString *currentState;
@property (nonatomic, strong) NSMutableSet *allowedStates;
@property (nonatomic, strong) NSMutableSet *allowedEvents;
@property (nonatomic, strong) NSMutableDictionary *transitionsByEvent;

@end

@implementation ADBStateMachine
{
    dispatch_queue_t _lockQueue;
    dispatch_queue_t _workingQueue;
    dispatch_queue_t _callbackQueue;
}

- (instancetype)initWithInitialState:(NSString *)state callbackQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        _currentState = state;
        _allowedStates = [NSMutableSet set];
        _allowedEvents = [NSMutableSet set];
        _transitionsByEvent = [NSMutableDictionary dictionary];
        _lockQueue = dispatch_queue_create("com.albertodebortoli.statemachine.queue.lock", DISPATCH_QUEUE_SERIAL);
        _workingQueue = dispatch_queue_create("com.albertodebortoli.statemachine.queue.working", DISPATCH_QUEUE_SERIAL);
        _callbackQueue = queue ? : dispatch_get_main_queue();
    }
    
    return self;
}

- (void)addTransition:(ADBStateMachineTransition *)transition
{
    dispatch_sync(_lockQueue, ^{
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
    });
}

- (void)processEvent:(NSString *)event
{
    [self processEvent:event callback:nil];
}

- (void)processEvent:(NSString *)event callback:(dispatch_block_t)callback
{
    __block NSSet *transitions = nil;
    dispatch_sync(_lockQueue, ^{
        transitions = [self.transitionsByEvent[event] copy];
    });
    
    dispatch_async(_workingQueue, ^{
        for (ADBStateMachineTransition *transition in transitions) {
            if ([transition.fromState isEqualToString:self.currentState]) {

                // pre condition
                NSLog(@"Processing event '%@' from state '%@'", event, self.currentState);
                dispatch_async(_callbackQueue, ^{
                    [transition processPreBlock];
                });
                NSLog(@"Processed pre condition for event '%@' from state '%@' to state '%@'", event, transition.fromState, transition.toState);
                
                // change state atomically
                self.currentState = transition.toState;
                
                // post condition
                NSLog(@"Processed state changed from state '%@' to state '%@'", self.currentState, transition.toState);
                dispatch_async(_callbackQueue, ^{
                    [transition processPostBlock];
                });
                NSLog(@"Processed post condition for event '%@' from state '%@' to state '%@'", event, transition.fromState, transition.toState);
                
                if (callback) {
                    dispatch_async(_callbackQueue, ^{
                        callback();
                    });
                }
            }
        }
    });
}

@end
