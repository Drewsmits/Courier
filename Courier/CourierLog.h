//
//  CourierLog.h
//  Courier
//
//  Created by Andrew Smith on 2/3/14.
//  Copyright (c) 2014 Andrew B. Smith. All rights reserved.
//

#ifndef Courier_CourierLog_h
#define Courier_CourierLog_h

#define COURIER_LOG 0

#if DEBUG && COURIER_LOG
    #define CourierLogInfo(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
    #define CourierLogWarning(...) NSLog(@"\n!!!!\n%s %@\n!!!!\n", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
    #define CourierLogInfo(...) do { } while (0)
    #define CourierLogWarning(...) do { } while (0)
#endif

#endif
