//
//  HuobiCNYFetcher.m
//  btcbar
//
//  Created by lwei on 2/13/14.
//  Copyright (c) 2014 nearengine. All rights reserved.
//

#import "HaobtcCNYFetcher.h"

@implementation HaobtcCNYFetcher

- (id)init
{
    if (self = [super init])
    {
        // Menu Item Name
        self.ticker_menu = @"HaobtcBTC";

        // Website location
        self.url = @"http://www.haobtc.com";

        // Immediately request first update
        [self requestUpdate];
    }

    return self;
}

// Override Ticker setter to trigger status item update
- (void)setTicker:(NSString *)tickerString
{
    // Update the ticker value
    _ticker = tickerString;

    // Trigger notification to update ticker
    [[NSNotificationCenter defaultCenter] postNotificationName:@"btcbar_ticker_update" object:self];
}

// Initiates an asyncronous HTTP connection
- (void)requestUpdate
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://haobtc.com/common/get_benchmark_price/"]];

    // Set the request's user agent
    [request addValue:@"btcbar/2.0 (HaobtcCNYFetcher)" forHTTPHeaderField:@"User-Agent"];

    // Initialize a connection from our request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    // Go go go
    [connection start];
}

// Initializes data storage on request response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
}

// Appends response data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

// Indiciate no caching
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

// Parse data after load
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseStr = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    if (!responseStr) {
        return;
    }

    // Parse the JSON into results
    NSError *jsonParsingError = nil;
    id results = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonParsingError];

    // Results parsed successfully from JSON
    if (results)
    {
        NSString *sell_price = [results objectForKey:@"sell_price"];
        NSString *buy_price = [results objectForKey:@"buy_price"];
        if (sell_price && buy_price) {
//            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//            NSString *resultsStatus = [numberFormatter stringFromNumber:sell_price];
//            resultsStatus = [NSString stringWithFormat:@"¥%@", resultsStatus];
//            
//            self.error = nil;
//            self.ticker = resultsStatus;
            
            NSString *sell_price_str = [NSString stringWithFormat:@"/%@",sell_price];
            NSString *buy_price_str = [NSString stringWithFormat:@"¥%@",buy_price];
            
            NSString *resultsStatus =  [buy_price_str stringByAppendingString:sell_price_str];
            
            NSLog(resultsStatus,nil);
            
            self.ticker = resultsStatus;
            
        }
        // Otherwise log an error...
        else
        {
            self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"API Error", NSLocalizedDescriptionKey, @"The JSON received did not contain a result or the API returned an error.", NSLocalizedFailureReasonErrorKey, nil]];
            self.ticker = nil;
        }
    }
    // JSON parsing failed
    else
    {
        self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"JSON Error", NSLocalizedDescriptionKey, @"Could not parse the JSON returned.", NSLocalizedFailureReasonErrorKey, nil]];
        self.ticker = nil;
    }
}

// HTTP request failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"Connection Error", NSLocalizedDescriptionKey, @"Could not connect to Huobi.", NSLocalizedFailureReasonErrorKey, nil]];
    self.ticker = nil;
}

@end
