//
//  ImageTableViewController.m
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import "ImageTableViewController.h"

// Models
#import "Image.h"

// Views
#import "ImageCell.h"

// Controllers
#import "AppDelegate.h"
#import "SessionController.h"

#import <Courier/NSMutableURLRequest+Courier.h>

@interface ImageTableViewController () <SMDataSourceViewController, SMDataSourceDelegate>

@property (strong) SMTableViewDataSource *storeMadDataSource;

@property (strong) SMStoreController *storeController;

@property (strong) SessionController *sessionController;

@property (strong) NSCache *imageCache;

@end

@implementation ImageTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.storeController = [[AppDelegate sharedInstance] storeController];
    [self.storeController reset];
    
    self.storeMadDataSource = [SMTableViewDataSource new];

    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    NSFetchRequest *allImageFetchRequset = [context fetchRequestForObjectClass:[Image class]];
    allImageFetchRequset.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"imageUrl" ascending:YES]];

    [self.storeMadDataSource setupWithTableViewController:self
                                             fetchRequest:allImageFetchRequset
                                                  context:context
                                       sectionNameKeyPath:nil
                                                cacheName:nil];
    // Respond to empty
    self.storeMadDataSource.dataSourceDelegate = self;

    [self.storeMadDataSource performFetch];
    
    self.sessionController = [SessionController new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.sessionController startTaskForRequestPath:@"http://10.0.1.3:9000/listOfImages"
                                             method:@"GET"
                                  completionHandler:^(NSInteger statusCode,
                                                      NSData *data,
                                                      NSURLResponse *response,
                                                      NSError *error) {
                                      if (statusCode == 200) {
                                          [self handleResponse:response
                                                          data:data];
                                      }
                                  }];
}

#pragma mark - JSON

- (void)handleResponse:(NSURLResponse *)response data:(NSData *)data
{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    [context performBlock:^{
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            for (id imageJsonObject in jsonObject) {
                if ([imageJsonObject isKindOfClass:[NSDictionary class]]) {
                    Image *image = [Image createInContext:context];
                    image.imageUrl = [(NSDictionary *)imageJsonObject valueForKey:@"imageUrl"];
                }
            }
        }
        
        [context save];
    }];
}

#pragma mark - IBAction

- (IBAction)toggleQueueSuspend:(id)sender
{
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    if (self.sessionController.isSuspended) {
        [self.sessionController resume];
        [item setTitle:@"Suspend"];
    } else {
        [self.sessionController suspend];
        [item setTitle:@"Resume"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.storeMadDataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storeMadDataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - SMTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Image *image = [self.storeMadDataSource objectAtIndexPath:indexPath];
        
    ImageCell *imageCell = (ImageCell *)cell;
    imageCell.imageUrlLabel.text = image.imageUrl;
    imageCell.thumbnailImageView.image = nil;
    
    [self.sessionController startTaskForRequestPath:image.imageUrl
                                             method:@"GET"
                                  completionHandler:^(NSInteger statusCode,
                                                      NSData *data,
                                                      NSURLResponse *response,
                                                      NSError *error) {
                                      if (statusCode == 200) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              imageCell.thumbnailImageView.image = [UIImage imageWithData:data];
                                          });
                                      }
                                  }];
}

#pragma mark - SMDataSource

- (void)dataSource:(SMDataSource *)dataSource
           isEmpty:(BOOL)empty
{
    if (empty) {
        self.title = @"Empty";
    } else {
        self.title = @"Images";
    }
}

#pragma mark - UITableViewDelelgate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

@end
