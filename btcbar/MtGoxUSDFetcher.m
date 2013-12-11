//
//  MtGoxUSDFetcher.m
//  btcbar
//

#import "MtGoxUSDFetcher.h"

@implementation MtGoxUSDFetcher

- (id) init
{
    if (self = [super init])
    {
        // Menu Item Name
        [self setTicker_menu:@"MtGoxUSD"];
        
        // Default ticker value
        [self setTicker:@""];
        
        // Website location
        [self setUrl:@"https://www.mtgox.com/"];
        
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://data.mtgox.com/api/2/BTCUSD/money/ticker_fast"]];
    
    // Set the request's user agent
    [request addValue:@"btcbar/2.0 (MtGoxUSDFetcher)" forHTTPHeaderField:@"User-Agent"];
    
    // Initialize a connection from our request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // Go go go
    [connection start];
}

// Initializes data storage on request response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc] init];
}

// Appends response data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

// Indiciate no caching
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

// Parse data after load
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Parse the JSON into results
    NSError *jsonParsingError = nil;
    NSDictionary *results = [[NSDictionary alloc] init];
    results = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&jsonParsingError];
    
    // Results parsed successfully from JSON
    if(results)
    {
        // Get API status
        NSString *resultsStatus = [results objectForKey:@"result"];
        
        // If API call succeeded update the ticker...
        if([resultsStatus isEqualToString:@"success"])
        {
            //NSLog(@"MtGoxFetcher: %@", [[[results objectForKey:@"data"] objectForKey:@"last"] objectForKey:@"display"]);
            [self setTicker:[[[results objectForKey:@"data"] objectForKey:@"last"] objectForKey:@"display"]];
        }
        // Otherwise log an error...
        else
        {
            NSLog(@"MtGoxUSDFetcher: api error");
            [self setTicker:@"api error"];
        }
    }
    // JSON parsing failed
    else
    {
        NSLog(@"MtGoxUSDFetcher: json error");
        [self setTicker:@"json error"];
    }
}

// HTTP request failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"MtGoxFetcher: %@", error);
    [self setTicker:@"connection error"];
}

@end
