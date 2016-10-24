//
//  SKPushManager.h
//  Time Left
//
//  Created by Salavat Khanov on 1/31/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKEvent.h"
#import "SKEvent+Helper.h"

@interface SKPushManager : NSObject

- (void)registerForModelUpdateNotifications;

@end
