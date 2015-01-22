//
//  OKCoinCYNFetcher.h
//  btcbar
//
//  Created by Tim Daubenschütz on 22/01/15.
//  Copyright (c) 2015 nearengine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fetcher.h"

@interface OKCoinCYNFetcher : NSObject<Fetcher, NSURLConnectionDelegate>

@property (nonatomic) NSString* ticker;
@property (nonatomic) NSString* ticker_menu;
@property (nonatomic) NSString* url;
@property (nonatomic) NSError* error;
@property (nonatomic) NSMutableData *responseData;

- (void)requestUpdate;

@end
