//
//  AppDelegate.h
//  QConCBHack
//
//  Created by Philipp Fehre on 28/02/14.
//  Copyright (c) 2014 couchbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBLReplication;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) CBLReplication *repl;

@end
