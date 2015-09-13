//
//  TopPlacesFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by lordofming on 5/21/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "TopPlacesFlickrPhotosTVC.h"
#import "FlickrFetcher.h"
//#import "ImageViewController.h"
#import "PhotoListOfAPlaceTVC.h"

@interface TopPlacesFlickrPhotosTVC ()

@end

@implementation TopPlacesFlickrPhotosTVC

//@synthesize organizedPlaces=_organizedPlaces;
//-(void)setOrganizedPlaces:(NSMutableArray *)places
//{
//    if (!_organizedPlaces)
//    {
//        _organizedPlaces=[[NSMutableArray alloc]init];
//    }
//     _organizedPlaces=places;
//    //[self.tableView reloadData];
//}

-(NSMutableArray *)organizedPlaces
{
    if (!_organizedPlaces)
    {
        _organizedPlaces=[[NSMutableArray alloc]init];
    }
    //[self.tableView reloadData];
    return _organizedPlaces;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchTopPlaces];
}

-(IBAction)fetchTopPlaces
{
    [self.refreshControl beginRefreshing];
    
      NSURL *url=[FlickrFetcher URLforTopPlaces];
    
    //#warning Block Main Thread, which is used by Main queue --- fixed.
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,  ^{
        
        NSData *jsonResults=[NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults=[NSJSONSerialization JSONObjectWithData:jsonResults
                                                                          options:0
                                                                            error:NULL];
        
        NSLog(@"Flickr results in fetchQ of TopPlacesPhotosTVC = %@", propertyListResults);
        
        NSArray *places=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self organizePlaces:places];
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
            
            //Following message is for testing purpose only.
            [self buildListOfAllPlacesForDisplayInTableCell];
        });
    });
}

-(void)organizePlaces:(NSArray *)places
{
    for (NSDictionary *place in places)
    {
        NSString *country=[self extractCountryNameFromPlace:place];
        
        if ([self isTheCountryAlreadyAdded:country])
        {
            
            //   Two examples for alternative way of finding the dictionary in an array of dictionary:
            // 1.   NSPredicate *p = [NSPredicate predicateWithFormat:@"id = 291"]; //fiber
            //      NSArray *matchedDicts = [theArray filteredArrayUsingPredicate:p];
            
            // 2.    NSArray *data = [NSArray arrayWithObject:[NSMutableDictionary dictionaryWithObject:@"foo"
            //       forKey:@"BAR"]];
            //   NSArray *filtered = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(BAR == %@)", @"foo"]];
            
            for(NSMutableDictionary *dic in self.organizedPlaces)
            {
                if([dic objectForKey:country])
                {
                    [[dic objectForKey:country] addObject:place];
                }
            }
        }
        else
        {
            NSMutableDictionary *countryDic=[[NSMutableDictionary alloc] init];//dictionary for a particular country
            NSMutableArray *countryPlaces=[[NSMutableArray alloc]init];//places of a particular country
            [countryPlaces addObject:place];
            [countryDic setObject:countryPlaces forKey:country];
            [self.organizedPlaces addObject:countryDic];
        }
    }
}

-(BOOL)isTheCountryAlreadyAdded: (NSString *) country
{
    for(NSMutableDictionary *dic in self.organizedPlaces)
    {
        if([dic objectForKey:country] != nil)
        {
            return YES;
        }
    }
    return NO;
}

//For testing purpose only.
- (void)buildListOfAllPlacesForDisplayInTableCell
{
    self.listOfAllPlacesForDisplayInTableCell=[[NSMutableArray alloc]init];
    for (NSMutableDictionary *dic in self.organizedPlaces)
    {
        NSEnumerator *enumerator= [dic objectEnumerator];
        for (NSDictionary *place in [enumerator nextObject])
        {
            [self.listOfAllPlacesForDisplayInTableCell addObject:place];
        }
    }
    //NSLog(@"Right after buildListOfAllPlacesForDisplayInTableCell= %@", self.listOfAllPlacesForDisplayInTableCell);
}

-(NSString *)extractCountryNameFromPlace: (NSDictionary *)place
{
    NSString *fullPlaceName= [place valueForKeyPath: FLICKR_PLACE_NAME];
    NSArray *threePartsOfPlaceName = [fullPlaceName componentsSeparatedByString: @","];
    return [threePartsOfPlaceName lastObject];
}

-(NSString *)extractCityNameFromPlace: (NSDictionary *)place
{
    NSString *fullPlaceName= [place valueForKeyPath: FLICKR_PLACE_NAME];
    NSArray *threePartsOfPlaceName = [fullPlaceName componentsSeparatedByString: @","];
    return [threePartsOfPlaceName firstObject];
}

-(NSString *)extractStateNameFromPlace: (NSDictionary *)place
{
    NSString *fullPlaceName= [place valueForKeyPath: FLICKR_PLACE_NAME];
    NSArray *threePartsOfPlaceName = [fullPlaceName componentsSeparatedByString: @","];
    return [threePartsOfPlaceName objectAtIndex:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopPlacesCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *place=[self identifyAPlaceWithIndexPath:indexPath];
    cell.textLabel.text=[self extractCityNameFromPlace:place];
    cell.detailTextLabel.text=[self extractStateNameFromPlace:place];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.organizedPlaces count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    // use objectEnumerator to access the value of the only key-value pair in the dictionary of a particular country, because no identifier is available.
    NSEnumerator *enumerator= [[self.organizedPlaces objectAtIndex:section] objectEnumerator];
    return [[enumerator nextObject] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Use keyEnumerator to access key of the only key-value pair in the dictionary of a particular country, because no identifier is available.
    NSEnumerator *enumerator= [[self.organizedPlaces objectAtIndex:section] keyEnumerator];
    return [enumerator nextObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSDictionary *)identifyAPlaceWithIndexPath: (NSIndexPath *)indexPath
{
    NSMutableDictionary *country= self.organizedPlaces[indexPath.section];
    NSEnumerator *enumerator= [country objectEnumerator];
    return[enumerator nextObject] [indexPath.row];
}

#pragma mark -UITableViewDelegate

//This method is needed ONLY IF we are not seguing to another ViewController. Since We will segue for sure (regardless for iPhone or iPad),
//This method is not needed in this class.
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    id detail=self.splitViewController.viewControllers[1];
//
//    if ([detail isKindOfClass:[UINavigationController class]]){
//        detail=[((UINavigationController *) detail).viewControllers firstObject];
//    }
//
//    if ([detail isKindOfClass:[ImageViewController class]]) {
//        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
//    }
//}


//// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"Display Photos Of A Place"]){
                if ([segue.destinationViewController isKindOfClass:[PhotoListOfAPlaceTVC class]]){
                    
                    NSDictionary *chosenPlace=[self identifyAPlaceWithIndexPath:indexPath];
                    
                    ((PhotoListOfAPlaceTVC *)segue.destinationViewController).place=chosenPlace;
                    ((PhotoListOfAPlaceTVC *)segue.destinationViewController).title=[chosenPlace valueForKeyPath: FLICKR_PLACE_NAME];
                }
            }
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    //     Get the new view controller using [segue destinationViewController].
//    //     Pass the selected object to the new view controller.
//    if ([sender isKindOfClass:[UITableViewCell class]]) {
//        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
//        if (indexPath) {
//            if([segue.identifier isEqualToString:@"Display Photo"]){
//                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]){
//                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row]];
//                }
//            }
//        }
//    }
//}

#pragma mark - Navigation

//-(void)preparePhotoListOfAPlaceTVC: (PhotoListOfAPlaceTVC *)ploaptvc toDisplayPhotos:(NSMutableArray *) photos
//{
//
//    [FlickrFetcher URLforPhotosInPlace:(id)flickrPlaceId maxResults:(int)maxResults];
//    photosOfAPlace
//
//    ploaptvc.photosOfAPlace=[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
//    ivc.title=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
//
//    ploaptvc.photosOfAPlace
//}

#pragma mark - Navigation

//-(void)prepareImageViewController: (ImageViewController *)ivc toDisplayPhoto:(NSDictionary *) photo
//{
//    ivc.imageURL=[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
//    ivc.title=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
//}

@end
