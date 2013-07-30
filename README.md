# Courier

## Introduction

Courier is a simple network layer inspired by ASIHTTPRequest and AFNetworking. The main difference is that Courier is much lighter weight and hopefully easier to understand. Easily opt in to Courier's built in operation management through using (Conductor)[http://github.com/Drewsmits/Conductor), or do it yourself.



## What makes a good network framework?

***

### Request Queues

All devices have limited bandwidth for sending requests. This is especially true when designing for the mobile devices, as the end of your request pipeline is one antenna. as you sometimes have spotty internet connections and extremely impatient users. As your user dives into your app, requests you made a moment ago may no longer be relevant. For example, if a user is scrolling through a list of Twitter users, what is the point of downloading profile images for users no longer on screen? In this case being responsive is better than being fast. You could write the fastest twitter profile image downloader of all time, but it will lose to the app that shows the user what is relevant first.

Courier is built on top of Conductor, which lets you manage request queues like a pro.

* Create and manage separate request queues
* Reprioritize a specific job
* Start/Stop/Pause/Cancel  jobs
* Continue requests when the app is in the background
* Retry requests if they fail

### Manage Your Headers

Typically you use the same request header for all your Apps requests. However, there are times when you may need to change things like Content-Type on the fly. Allow the "dont make me think" users to set it and forget it, but also allow injection of new or different fields before the request goes out.

### Encode Your Data

In my experience, there are two common encoding types that APIs use; form url and JSON. When submitting parameters, it's nice to use key/value structures to build your request, and then have the network framework turn it into whatever it needs to to talk to the API. 

### Provide Request Success/Failure Feedback

### Allow Flexible Requests

[Hypertext Transfer Protocol]: http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol
[list of all HTTP status codes]: http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
