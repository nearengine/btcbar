//
//  Btc38.h
//  btcbar
//
//  Created by phil on 15/4/16.
//  Copyright (c) 2015年 nearengine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fetcher.h"


@interface Btc38 :NSObject<Fetcher, NSURLConnectionDelegate>

@property (nonatomic) NSString* ticker;
@property (nonatomic) NSString* ticker_menu;
@property (nonatomic) NSString* url;
@property (nonatomic) NSError* error;
@property (nonatomic) NSMutableData *responseData;

- (void)requestUpdate;

@end
