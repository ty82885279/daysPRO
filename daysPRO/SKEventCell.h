//
//  SKEventCell.h
//  Time Left
//
//  Created by Salavat Khanov on 1/23/14.
//  Copyright (c) 2014 Salavat Khanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKEventCellProgressView.h"

@interface SKEventCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet SKEventCellProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

- (void)startQuivering;
- (void)stopQuivering;

@end
