# About Courier

## What makes a URL request?

***

### HTTP Session

A sequence of network request-response transactions.

### Request Method

HTTP defines methods to indicate the desired action to be performed on the identified remote resource.[^HTTP-wiki]

* __GET__: Requests a representation of the specified resource. Requests using GET should only retrieve data and should have no other effect.
* __POST__: Requests that the server accept the entity enclosed in the request as a new subordinate of the resource identified by the URI.
* __PUT__: Requests that the enclosed entity be stored under the supplied URI. If the URI refers to an already existing resource, it is modified; if the URI does not point to an existing resource, then the server can create the resource with that URI.
* __DELETE__: Deletes the specified resource.

### Request Header

### Request Response

The first line of the HTTP response is the status line and includes a status code and a textual reason phrase. See a [list of all HTTP status codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes).

## What makes a good network framework?

***

### Request Queues

All devices have limited bandwidth for fielding requests. This is especially true when designing for the iPhone, as you sometimes have spotty internet connections and extremely impatient users. As your user dives into your app, requests you made a moment ago may no longer be relevant. For example, if a user is scrolling through a list of Twitter users, what is the point of downloading profile images for users no longer on screen? In this case being responsive is better than being fast. You could write the fastest twitter profile image downloader of all time, but it will lose to the app that shows the user what is relevant first.

Courier is built on top of Conductor, which lets you manage request queues like a pro.

* Create and manage separate request queues
* Reprioritize a specific job
* Start/Stop/Pause/Cancel  jobs
* Continue requests when the app is in the background
* Retry requests if they fail

### Manage Your Headers

### Encode Your Data

### Provide Request Success/Failure Feedback

### Allow Flexible Requests

[^HTTP-wiki]: [Hypertext Transfer Protocol](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)