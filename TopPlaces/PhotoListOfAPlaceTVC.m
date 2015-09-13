//
//  PhotoListOfAPlaceTVC.m
//  TopPlaces
//
//  Created by lordofming on 6/5/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "PhotoListOfAPlaceTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
const int MAX_NUM_OF_RECENTLY_VIEWED_PHOTOS = 20;

@interface PhotoListOfAPlaceTVC ()

@end

@implementation PhotoListOfAPlaceTVC

-(void)setPlace:(NSDictionary*)place
{
    if (!_place)
    {
        _place=[[NSDictionary alloc]init];
    }
     _place=place;
}

-(NSMutableArray *)photosOfAPlace
{
    if (!_photosOfAPlace)
    {
        _photosOfAPlace=[[NSMutableArray alloc]init];
    }
    return _photosOfAPlace;
}

-(NSMutableArray *)viewedPhotosArray
{
    if (!_viewedPhotosArray)
    {
        _viewedPhotosArray=[[NSMutableArray alloc]init];
    }
    return _viewedPhotosArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self fetchPhotosOfAPlace];
    
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    //NSLog(@"mutable copy from NSUserDefault in getter of viewedPhotosArray: %@",[[userdefault arrayForKey:@"Viewed Photos"]mutableCopy]);
    
    self.viewedPhotosArray = [[userdefault arrayForKey:@"Viewed Photos"]mutableCopy];
    
}

-(void)insertPhotoToFrontOfViewedPhotosArray:(NSDictionary *)photo
{
    if (![self.viewedPhotosArray containsObject:photo])
    {
        if ([self.viewedPhotosArray count] >= MAX_NUM_OF_RECENTLY_VIEWED_PHOTOS) {
            [self.viewedPhotosArray removeLastObject];
        }
    }
    else
    {
        [self.viewedPhotosArray removeObject:photo];
    }
    
    [self.viewedPhotosArray insertObject:photo atIndex:0];
}


//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}

-(IBAction)fetchPhotosOfAPlace
{
     [self.refreshControl beginRefreshing];
    
    id placeId=[self.place valueForKeyPath:FLICKR_PLACE_ID];
    
    NSURL *url= [FlickrFetcher URLforPhotosInPlace: placeId maxResults:50];
    
    //#warning Block Main Thread, which is used by Main queue --- fixed.
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,  ^{
        
        NSData *jsonResults=[NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults=[NSJSONSerialization JSONObjectWithData:jsonResults
                                                                          options:0
                                                                            error:NULL];
        //NSLog(@"Flickr results for photos of a particular place= %@", propertyListResults);
        NSArray *photos=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];//#define FLICKR_RESULTS_PHOTOS @"photos.photo"
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (NSDictionary *dic in photos)
            {
                NSMutableDictionary *mutableDic= [dic mutableCopy];
                [self.photosOfAPlace addObject:mutableDic];
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.photosOfAPlace count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    // Configure the cell...
    NSMutableDictionary *photo= self.photosOfAPlace[indexPath.row];//MutableArray of MutableDictionary?
    NSString *title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSString *description=[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if ([title isEqualToString:@""]) {
        title=description;
        description=@"";
    }
    if ([title isEqualToString:@""]) {
        title=@"Unknown";
        description=@"No Description";
    }
    

    [self.photosOfAPlace[indexPath.row] setObject:title forKey:FLICKR_PHOTO_TITLE];//PROBLEM!!! MUTATING UNMUTABLE NSDICTIONARY.
    
        //NSLog(@"OK so far in tableview");
    
    [self.photosOfAPlace[indexPath.row] setObject:description forKey:FLICKR_PHOTO_DESCRIPTION];
    
    cell.textLabel.text= title;
    cell.detailTextLabel.text=description;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail=self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail=[((UINavigationController *) detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
//        [self prepareImageViewController:detail toDisplayPhoto:self.photosOfAPlace[indexPath.row]];
        [self prepareImageViewController:detail forIndex:indexPath.row];
    }
}

#pragma mark - Navigation

-(void)prepareImageViewController: (ImageViewController *)ivc forIndex:(NSInteger)index
{
    NSMutableDictionary *photo= self.photosOfAPlace[index];
    
    ivc.imageURL=[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title= [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    [self insertPhotoToFrontOfViewedPhotosArray:photo];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.viewedPhotosArray forKey:@"Viewed Photos"];
    [userDefault synchronize];
    //NSLog(@"prepareImageviewController in PhotoListOfAPlaceTVC get called");
    //NSLog(@"self.viewedPhotosArray in PhotoListOfAPlaceTVC = %@",self.viewedPhotosArray);
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"Display Photo For PhotoListOfAPlace"]){
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]){
//                    [self prepareImageViewController:segue.destinationViewController forIndex:self.photosOfAPlace[indexPath.row]];
                    
                    [self prepareImageViewController:segue.destinationViewController forIndex:indexPath.row];
                    
                     ;
                }
            }
        }
    }
}

@end
