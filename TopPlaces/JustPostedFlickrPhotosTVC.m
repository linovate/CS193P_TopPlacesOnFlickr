//
//  JustPostedFlickrPhotosTVC.m
//  Shutterbug
//
//  Created by lordofming on 5/18/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "JustPostedFlickrPhotosTVC.h"
#import "FlickrFetcher.h"
@interface JustPostedFlickrPhotosTVC ()

@end

@implementation JustPostedFlickrPhotosTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchPhotos];
}

-(IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing];
    
    
    NSURL *url=[FlickrFetcher URLforRecentGeoreferencedPhotos];
    
#warning Block Main Thread, which is used by Main queue.
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults=[NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults=[NSJSONSerialization JSONObjectWithData:jsonResults
                                                                          options:0
                                                                            error:NULL];
        NSLog(@"Flickr results= %@", propertyListResults);
        NSArray *photos=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];//#define FLICKR_RESULTS_PHOTOS @"photos.photo"
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photos=photos;
        });

    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
