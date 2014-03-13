//
//  AppDelegate.m
//  QConCBHack
//
//  Created by Philipp Fehre on 28/02/14.
//  Copyright (c) 2014 couchbase. All rights reserved.
//

#import "AppDelegate.h"
#import "CouchbaseLite/CouchbaseLite.h"
#import "CouchbaseLite/CBLDocument.h"

@implementation AppDelegate

@synthesize repl = _repl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self setupReplication];
    NSLog(@"Created challenge doc was a %@.", ([self createChallengeDoc] ? @"success" : @"failure"));
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

# pragma CB Hack Challenge
- (CBLDatabase*)database
{
  NSError *error;
  CBLManager *manager = [CBLManager sharedInstance];
  if (!manager) {
    NSLog(@"Faild to load CBLManager");
    return nil;
  }

  NSString *dbName = @"my-challenge-db";
  if (![CBLManager isValidDatabaseName:dbName]) {
    NSLog(@"Database name is invalid %@", dbName);
    return nil;
  }

  CBLDatabase *db = [manager databaseNamed:dbName error:&error];
  if (error) {
    NSLog(@"Failed to open database because of %@", error);
    return nil;
  }

  return db;
}

- (void)setupReplication
{
  NSURLCredential *cred = [NSURLCredential credentialWithUser:@"philipp.fehre@gmail.com"
                                                     password:@"503e5e091a5c0b50746f52523579ae7b"
                                                  persistence:NSURLCredentialPersistencePermanent];
  NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:@"ec2-54-186-17-144.us-west-2.compute.amazonaws.com"
                                                                      port:4984
                                                                  protocol:@"http"
                                                                     realm:@"Couchbase Sync Gateway"
                                                      authenticationMethod:NSURLAuthenticationMethodDefault];
  [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential: cred forProtectionSpace: space];

  NSURL *url = [NSURL URLWithString:@"http://ec2-54-186-17-144.us-west-2.compute.amazonaws.com:4984/sync_gateway"];
  CBLReplication *repl = [self.database replicationToURL:url];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(traceSyncNotifications:)
                                               name:kCBLDatabaseChangeNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(traceSyncNotifications:)
                                               name:kCBLDatabaseChangeNotification
                                             object:nil];

  self.repl = repl;
  self.repl.continuous = YES;
  [repl start];
}

- (void)traceSyncNotifications:(NSNotification *)notification
{
  NSLog(@"Push changes %u completed %u", self.repl.changesCount, self.repl.completedChangesCount);
  NSLog(@"Push error? %@", self.repl.lastError);
}

- (BOOL)createChallengeDoc
{
  NSError *error;

  CBLDocument *doc = [self.database documentWithID:@"503e5e091a5c0b50746f52523579ae7b"];
  NSDictionary *properties = @{ @"type": @"rating",
                                @"owner": @"philipp.fehre@gmail.com",
                                @"Architecture": @{
                                   @"rating": @"A",
                                   @"comment": @"Loved it!"
                                 },
                                 @"Back end": @{
                                   @"rating": @"C",
                                   @"comment": @"Not a backend guy"
                                 },
                                 @"Front end": @{
                                   @"rating": @"B",
                                   @"comment": @"Cool!"
                                 },
                                 @"Process": @{
                                   @"rating": @"D",
                                   @"comment": @"meh"
                                 },
                                 @"Training": @{
                                   @"rating": @"A",
                                   @"comment": @"Love to get my hands dirty!"
                                 },
                                 @"Solution Track": @{
                                   @"rating": @"F",
                                   @"comment": @"Marketing..."
                                 }
                               };

  [doc putProperties:properties error:&error];
  if (error) {
    return NO;
  }

  return YES;
}

@end
