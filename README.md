# About Courier

## What makes a URL request?

***

### Request Method

"HTTP defines methods (sometimes referred to as verbs) to indicate the desired action to be performed on the identified resource. What this resource represents, whether pre-existing data or data that is generated dynamically, depends on the implementation of the server. Often, the resource corresponds to a file or the output of an executable residing on the server."

* __GET__: Requests a representation of the specified resource. Requests using GET should only retrieve data and should have no other effect.
* __POST__: Requests that the server accept the entity enclosed in the request as a new subordinate of the resource identified by the URI.
* __PUT__: Requests that the enclosed entity be stored under the supplied URI. If the URI refers to an already existing resource, it is modified; if the URI does not point to an existing resource, then the server can create the resource with that URI.
* __DELETE__: Deletes the specified resource.

## What makes a good network framework?

***

### Request Queues
All devices have limited bandwidth for fielding requests. This is especially true when designing for the iPhone.