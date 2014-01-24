# Courier

Courier is a simple network layer built on NSURLSession and various categories of convenience.

* Easy network activity display management
* Respond to changes in reachability
* Respond to 401 unauthorized errors
* Request logging



## Getting Started

```objc

// Default config
NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

// Build session controller
CRSessionController *sessionController = [CRSessionController sessionControllerWithConfiguration:config sessionConfiguration
                                                                                  delegate:controller];

```