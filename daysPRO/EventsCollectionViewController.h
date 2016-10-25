//
//  EventsCollectionViewController.h
//  Time Left
//
//  Created by Salavat Khanov on 1/23/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Event+Helper.h"
#import "DataManager.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface EventsCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end
