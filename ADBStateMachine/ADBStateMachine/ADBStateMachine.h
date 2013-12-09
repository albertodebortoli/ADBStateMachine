//
//  ADBStateMachine.h
//  ADBStateMachine
//
//  Created by Alberto De Bortoli on 09/12/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADBStateMachineTransition.h"

@interface ADBStateMachine : NSObject

@property (nonatomic, copy, readonly) NSString *currentState;

- (instancetype)initWithInitialState:(NSString *)state;

- (void)addTransition:(ADBStateMachineTransition *)transition;

- (void)processEvent:(NSString *)event;

@end
