//
//  ImageViewController.m
//  Imaginarium
//
//  Created by lordofming on 5/16/15.
//  Copyright (c) 2015 lordofming. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView=scrollView;
    _scrollView.minimumZoomScale=0.2;
    _scrollView.maximumZoomScale=2.0;
    _scrollView.delegate=self;
    self.scrollView.contentSize=self.image? self.image.size:CGSizeZero;
}

//This method specifies the UIView object that should be zoomed in the Scroll View.
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// 1st get called, then imageURL 's getter get callled, both in prepareForSegue
-(void)setImageURL:(NSURL *)imageURL
{
    _imageURL=imageURL;
   // self.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
    [self startDownLoadingImage];
}

-(void)startDownLoadingImage
{
    self.image=nil;
    if (self.imageURL) {
        
        [self.spinner startAnimating];
        NSURLRequest *request= [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration= [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session=[NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task=
        [session downloadTaskWithRequest:request
                       completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                           if (!error) {
                               if ([request.URL isEqual:self.imageURL]) {
                                   UIImage *image= [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                   dispatch_async(dispatch_get_main_queue(), ^{self.image = image;});
                                   //alternative way to do the line above, i.e. dispatch_async...:
                                   //[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                               }
                           }  
                       }];
        [task resume];
    }
}

-(UIImageView *)imageView
{
    if(!_imageView) _imageView=[[UIImageView alloc]init];
    return _imageView;
}
// The reason to put @synthesize when both getter and setter are overriden is that we need to create instance
// variable (e.g._image in this case). However, since neither the overriden getter nor setter use/refer to _image,
// there is no need to use @synthesize to create _image in this case.

-(UIImage *)image
{
    return self.imageView.image;
}

//2nd get called in prepareForSegue
-(void)setImage:(UIImage *)image
{
    self.scrollView.zoomScale=1.0;
    self.imageView.image=image;
    //[self.imageView sizeToFit]; //replaced by following line of code:
    self.imageView.frame=CGRectMake(0,0, image.size.width,image.size.height);
    
    //Following line of code get called in prepareForSegue, which is called BEFORE outlets (e.g.property scrollView)
    //are set. In other words, scrollView is nil (and this line does nothing) when prepareForSegue is called. So we have to write this line of code again in setter of scrollView.
    self.scrollView.contentSize=self.image? self.image.size:CGSizeZero;
    [self.spinner stopAnimating];
}

//This get called after prepareForSegue (in ViewController) finishes.
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    
    
}

#pragma mark - UISplitViewControllerDelegate

-(void)awakeFromNib
{
    self.splitViewController.delegate=self;
}

//-(BOOL)splitViewController:(UISplitViewController *)svc
//  shouldHideViewController:(UIViewController *)vc
//             inOrientation:(UIInterfaceOrientation)orientation
//{
//    return UIInterfaceOrientationIsPortrait(orientation);
//}
//
//-(void)splitViewController:(UISplitViewController *)svc
//    willHideViewController:(UIViewController *)aViewController
//         withBarButtonItem:(UIBarButtonItem *)barButtonItem
//      forPopoverController:(UIPopoverController *)pc
//
//{
//    barButtonItem.title=aViewController.title;
//    self.navigationItem.leftBarButtonItem=barButtonItem;
//}
//
//-(void)splitViewController:(UISplitViewController *)svc
//    willShowViewController:(UIViewController *)aViewController
// invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
//
//{
//    self.navigationItem.leftBarButtonItem=nil;
//}


//copied from solution
// auto-hide the master view in portrait mode in iPad version
-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode{
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    }
}

@end
