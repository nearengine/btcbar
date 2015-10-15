//
//  Btc38.m
//  btcbar
//
//  Created by phil on 15/4/16.
//  Copyright (c) 2015年 nearengine. All rights reserved.
//

#import "Btc38.h"

@implementation Btc38

- (id)init
{
    if (self = [super init])
    {
        // Menu Item Name
        self.ticker_menu = @"BTC38";
        
        // Website location
        self.url = @"http://btc38.com";
        
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.btc38.com/v1/ticker.php?c=all&mk_type=cny"]];
    
    // Set the request's user agent
    [request addValue:@"btcbar/2.0 (OkcoinCNYFetcher)" forHTTPHeaderField:@"User-Agent"];
    
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
    // Parse the JSON into results
    NSError *jsonParsingError = nil;
    NSDictionary *results = [[NSDictionary alloc] init];
    results = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonParsingError];
    
    // Results parsed successfully from JSON
    if(results)
    {
        // Get API status
        NSNumber *xrp=[[[results objectForKey:@"xrp"]objectForKey:@"ticker"] objectForKey:@"last"];
        NSNumber *bts=[[[results objectForKey:@"bts"]objectForKey:@"ticker"] objectForKey:@"last"];

        // If API call succeeded update the ticker...
        if(xrp)
        {
            NSString *xrpstring = [NSString stringWithFormat:@"XRP %lg", [xrp doubleValue]];
            NSString *btsstring = [NSString stringWithFormat:@" BTS %lg",[bts doubleValue]];
            
            NSString *resultsStatus =  [xrpstring stringByAppendingString:btsstring];
            
            NSLog(resultsStatus,nil);
            
            self.ticker = resultsStatus;

//            NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
//            currencyStyle.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//            currencyStyle.numberStyle = NSNumberFormatterCurrencyStyle;
//            resultsStatus = [currencyStyle stringFromNumber:[NSDecimalNumber decimalNumberWithString:resultsStatus]];
//            self.ticker = resultsStatus;
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
    self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"Connection Error", NSLocalizedDescriptionKey, @"Could not connect to BitStamp.", NSLocalizedFailureReasonErrorKey, nil]];
    self.ticker = nil;
}

@end

