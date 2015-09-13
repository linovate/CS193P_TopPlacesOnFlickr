//
//  PhotoListOfAPlaceTVC.h
//  TopPlaces
//
//  Created by lordofming on 6/5/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListOfAPlaceTVC : UITableViewController

@property (nonatomic,strong) NSMutableArray *photosOfAPlace;
@property (nonatomic,strong) NSDictionary *place;
@property (nonatomic,strong) NSMutableArray *photoTitlesArray;
@property (nonatomic,strong) NSMutableArray *viewedPhotosArray;

@end
