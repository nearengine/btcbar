//
//  HuobiCNYFetcher.h
//  btcbar
//
//  Created by lwei on 2/13/14.
//  Copyright (c) 2014 nearengine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fetcher.h"

@interface HuobiCNYFetcher : NSObject<Fetcher, NSURLConnectionDelegate>

@property (nonatomic) NSString* ticker;
@property (nonatomic) NSString* ticker_menu;
@property (nonatomic) NSString* url;
@property (nonatomic) NSError* error;
@property (nonatomic) NSMutableData *responseData;

@end
