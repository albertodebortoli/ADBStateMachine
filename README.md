ADBStateMachine
===============

A proper thread-safe state machine for Objective-C.

Simple usage:

- import the files in the Classes folder in your project or install via CocoaPods adding `pod "ADBStateMachine"` to your Podfile
- import `ADBStateMachine.h` in your class
- create a state machine with the initial state and assign it to a property

```objective-c
self.stateMachine = [[ADBStateMachine alloc] initWithInitialState:@"Idle" callbackQueue:nil];
```

- create transitions and add them to the state machine (the state machine will automatically recognize the new states)

```objective-c
ADBStateMachineTransition *t1 = [[ADBStateMachineTransition alloc] initWithEvent:@"start"
                                                                       fromState:@"Idle"
                                                                         toState:@"Started"
                                                                        preBlock:^{
                                                                            NSLog(@"Gonna move from Idle to Started!");
                                                                        }
                                                                       postBlock:^{
                                                                            NSLog(@"Just moved from Idle to Started!");
                                                                        }];

ADBStateMachineTransition *t2 = [[ADBStateMachineTransition alloc] initWithEvent:@"pause"
                                                                       fromState:@"Started"
                                                                         toState:@"Idle"
                                                                        preBlock:nil
                                                                       postBlock:nil];
                                                                       
[stateMachine addTransition:t1];
[stateMachine addTransition:t2];
```

- process events like so

```objective-c
[stateMachine processEvent:@"start"];
[stateMachine processEvent:@"pause"];
```
