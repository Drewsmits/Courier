# Courier

Courier is a simple network layer built on NSURLSession and various categories of convenience.

* Easy network activity display management
* Respond to changes in reachability
* Respond to 401 unauthorized errors
* Request logging
* Easily build NSURLRequests with proper encoding


## Getting Started

```objc
#import <Courier/Courier.h>

// Default config
NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

// Add additional headers
config.HTTPAdditionalHeaders = @{@"Accept" : @"application/json"};

// Be a good API citizen and limit to 1 HTTP connection per host
config.HTTPMaximumConnectionsPerHost = 1;

// Build session controller
CRSessionController *sessionController = [CRSessionController sessionControllerWithConfiguration:config 
                                                                                        delegate:controller];

// Build a POST request
NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:@"POST"
                                                                 path:@"https://service.com/api"
                                                             encoding:CR_URLJSONParameterEncoding
                                                        URLParameters:@{@"urlParam" : @"value"}
                                                   HTTPBodyParameters:@{@"bodyParam" : @"value"}
                                                               header:@{@"Header-Name" : @"value"}];


// Build a task
NSURLSessionDataTask *task = [sessionController dataTaskForRequest:request
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
                                                     if (response.success) {
                                                         // Hurrah!
                                                     }
                                                 }];

// Start task
[task resume];

```

## Externals

* [Reachability library](https://github.com/tonymillion/Reachability) was created and maintained by [Tony Million](https://github.com/tonymillion).
