//
//  RecentlyViewedPhotosTVC.m
//  TopPlaces
//
//  Created by lordofming on 6/5/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "RecentlyViewedPhotosTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface RecentlyViewedPhotosTVC ()

@end

@implementation RecentlyViewedPhotosTVC

- (void)setViewedPhotos:(NSArray *) photos
{
    if (!_viewedPhotos)
    {
        _viewedPhotos=[[NSArray alloc]init];
    }
      _viewedPhotos=photos;
}

-(IBAction)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.refreshControl beginRefreshing]; //Not really necessary and appropriate.
    
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    self.viewedPhotos = [userdefault arrayForKey:@"Viewed Photos"];
    //    self.viewedPhotos = [userdefault objectForKey:@"Viewed Photos"];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];//Not really necessary and appropriate.

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
    return [self.viewedPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *photo= self.viewedPhotos[indexPath.row];
    cell.textLabel.text=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text=[photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

#pragma mark -UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail=self.splitViewController.viewControllers[1];
    
    if ([detail isKindOfClass:[UINavigationController class]]){
        detail=[((UINavigationController *) detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:self.viewedPhotos[indexPath.row]];
    }
}

#pragma mark - Navigation

-(void)prepareImageViewController: (ImageViewController *)ivc toDisplayPhoto:(NSDictionary *) photo
{
    ivc.imageURL=[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"Display Photo"]){
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]){
                    [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.viewedPhotos [indexPath.row]];
                }
            }
        }
    }
}



@end
