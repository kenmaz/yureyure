//
//  KMZViewController.m
//  YureYure
//
//  Created by Matsumae Kentaro on 12/02/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KMZViewController.h"
#import "KMZAppDelegate.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@implementation KMZViewController
@synthesize yureLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setYureLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showYureMsg {
    self.yureLabel.hidden = NO;
}

- (void)showFailedYureMsg {
    self.yureLabel.text = @"ゆれゆれ失敗";
    self.yureLabel.hidden = NO;
}

- (IBAction)pushYureButton:(id)sender {
    
    ACAccountStore* store = [[ACAccountStore alloc] init];
    ACAccountType* twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [store requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError* error) {
        if (!granted) {
            NSLog(@"not granted");
        } 
        else {
            NSArray* twitterAccounts = [store accountsWithAccountType:twitterAccountType];
            if ([twitterAccounts count] > 0) {
                ACAccount* account = [twitterAccounts objectAtIndex:0];
                
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                [params setObject:@"ゆれゆれ #(((o_o)))" forKey:@"status"];
                
                NSURL* url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                TWRequest* req = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodPOST];
                [req setAccount:account];
                
                [req performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (!responseData) {
                        NSLog(@"error: %@", error);
                    }
                    else {
                        NSError* jsonError;
                        NSDictionary* res = [NSJSONSerialization JSONObjectWithData:responseData 
                                                                       options:NSJSONReadingMutableLeaves 
                                                                         error:&jsonError];
                        if (res) {
                            NSLog(@"success: %@", res);
                            if ([res objectForKey:@"error"]) {
                                [self performSelectorOnMainThread:@selector(showFailedYureMsg) 
                                                       withObject:nil 
                                                    waitUntilDone:NO];

                            } else {
                                [self performSelectorOnMainThread:@selector(showYureMsg) 
                                                       withObject:nil 
                                                    waitUntilDone:NO];
                            }
                        }
                        else {
                            NSLog(@"error:%@", jsonError);
                            [self performSelectorOnMainThread:@selector(showFailedYureMsg) 
                                                   withObject:nil 
                                                waitUntilDone:NO];
                        }
                    }
                }];
                
            } 
            else {
                NSLog(@"no twitter account");
            }
        }
    }];
    
    
    
    
}

@end
