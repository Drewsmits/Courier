//
//  ViewController.m
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import "ViewController.h"
#import <Courier/NSMutableURLRequest+Courier.h>

#import "SessionController.h"

@interface ViewController ()

@property (weak) IBOutlet UILabel *pingLabel;

@property (strong) SessionController *sessionController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sessionController = [SessionController new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)ping:(id)sender
{
    [self.sessionController startTaskForRequestPath:@"http://10.0.1.3:9000/ping/200"
                                             method:@"GET"
                                  completionHandler:^(NSInteger statusCode, NSData *data, NSURLResponse *response, NSError *error) {
                                      if (error) {
                                          NSLog(@"error: %@", error);
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self showPing:statusCode];
                                      });
                                  }];
}

- (void)showPing:(NSInteger)ping
{
    self.pingLabel.text = [NSString stringWithFormat:@"%i", ping];
}

@end
