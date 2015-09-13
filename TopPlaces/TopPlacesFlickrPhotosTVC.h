//
//  TopPlacesFlickrPhotosTVC.h
//  TopPlaces
//
//  Created by lordofming on 5/21/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

//#import "FlickrPhotosTVC.h"

#import <UIKit/UIKit.h>
@interface TopPlacesFlickrPhotosTVC: UITableViewController

@property (nonatomic,strong) NSMutableArray *organizedPlaces; //Flickr places NSDictionary
@property (nonatomic,strong) NSMutableArray *listOfAllPlacesForDisplayInTableCell;

@end
