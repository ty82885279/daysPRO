//
//  PushManager.h
//  Time Left
//
//  Created by Salavat Khanov on 1/31/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Event+Helper.h"

@interface PushManager : NSObject

- (void)registerForModelUpdateNotifications;

@end
