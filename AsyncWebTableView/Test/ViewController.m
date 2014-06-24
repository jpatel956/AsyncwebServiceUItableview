//
//  ViewController.m
//  Test
//
//  Created by indianic on 24/06/14.
//  Copyright (c) 2014 indianic. All rights reserved.
//

#import "ViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [self callwebServicetoFetchData];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
        });
    });
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ++++++++++++++++ UitableView Methods ++++++++++++++++++
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [arrayTemp count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"general"];
    
    UILabel* lblTitle = (UILabel*)[cell.contentView viewWithTag:10];
    lblTitle.text = [[arrayTemp objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    UIImageView* imgPhoto = (UIImageView*)[cell.contentView viewWithTag:11];
    
    __block UIActivityIndicatorView *activityIndicator;

    __weak UIImageView *weakImageView = imgPhoto;
    [weakImageView setImageWithURL:[NSURL URLWithString:[[arrayTemp objectAtIndex:indexPath.row] valueForKey:@"skin"]] placeholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         if (!activityIndicator)
         {
             [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
             activityIndicator.center = weakImageView.center;
             [activityIndicator startAnimating];
         }
     }
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         [activityIndicator removeFromSuperview];
         activityIndicator = nil;
     }];

    
    
    return cell;
}
-(void)callwebServicetoFetchData {
    
    NSString* strURL = @"";//http://staging.google.com/chattfly/web_service/client.php
    NSURL * nsUrl1 = [NSURL URLWithString:strURL];
    NSMutableURLRequest * request  = [NSMutableURLRequest requestWithURL:nsUrl1];
    //post_data_string={"method":"purchased_skin_list","body":[{"user_id":"1","android":"hd"}]}
    
    NSString* strBody = @"{\"method\":\"chat_list\",\"body\":[{\"user_id\":\"1\",\"latitude\":\"23.0271829\",\"longitude\":\"72.50846209\"}]}";
    
    NSString *requestString = [NSString stringWithFormat:@"post_data_string=%@",strBody,nil];
    requestString=[requestString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    const char *utfYourString = [requestString UTF8String];
    
    NSMutableData *requestData = [NSMutableData dataWithBytes:utfYourString length:strlen(utfYourString)];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: requestData];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData* data, NSError * connectionError)
    {
        if (data.length > 0) {
            
            NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            
            arrayTemp = [NSMutableArray arrayWithArray:[[[greeting valueForKey:@"data"] valueForKey:@"result"] valueForKey:@"joinable"]];
            
            [tblGeneral reloadData];
            
        }
        
     
    }];
    
    
}
@end
