//
//  AstockFetcher.m
//  btcbar
//
//  Created by phil on 15/4/16.
//  Copyright (c) 2015年 nearengine. All rights reserved.
//

#import "AstockFetcher.h"

@implementation AstockFetcher


- (id)init
{
    if (self = [super init])
    {
        // Menu Item Name
        self.ticker_menu = @"China A stock";
        
        // Website location
        self.url = @"http://finance.sina.com.cn/realstock/";
        
        // Immediately rebquest first update
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://apistore.baidu.com/microservice/stock?stockid=000001"]];
    
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
        NSString *errMsg = [results objectForKey:@"errMsg"];
        NSLog(errMsg,nil);
        
        NSString *shanghai=[[[[results objectForKey:@"retData"]objectForKey:@"market"] objectForKey:@"shanghai"]objectForKey:@"curdot"];
        NSString *shenzhen=[[[[results objectForKey:@"retData"]objectForKey:@"market"] objectForKey:@"shenzhen"]objectForKey:@"curdot"];

        // If API call succeeded update the ticker...
        if(shanghai)
        {
            NSString *shanghaistring = [NSString stringWithFormat:@"ShangHai: %@",shanghai];
            NSString *shenzhenstring = [NSString stringWithFormat:@"  ShenZhen: %@",shenzhen];
            
            NSString *resultsStatus =  [shanghaistring stringByAppendingString:shenzhenstring];
            
            //NSLog(resultsStatus,nil);
            
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
    self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"Connection Error", NSLocalizedDescriptionKey, @"Could not connect to BitStamp.", NSLocalizedFailureReasonErrorKey, nil]];
    self.ticker = nil;
}


@end
