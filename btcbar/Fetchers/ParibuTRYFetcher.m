//
//  ParibuTRYFetcher.m
//  btcbar
//

#import "ParibuTRYFetcher.h"

@implementation ParibuTRYFetcher

- (id)init
{
    if (self = [super init])
    {
        // Menu Item Name
        self.ticker_menu = @"ParibuTRY";
        
        // Website location
        self.url = @"https://www.paribu.com/";
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.paribu.com/ticker"]];
    
    // Set the request's user agent
    [request addValue:@"btcbar/2.0 (ParibuTRYFetcher)" forHTTPHeaderField:@"User-Agent"];
    
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
        NSString *resultsStatus = [[[results objectForKey:@"BTC_TL"] objectForKey:@"last"] stringValue];

        // If API call succeeded update the ticker...
        if(resultsStatus)
        {
            NSDecimalNumber *resultsStatusNumber = [NSDecimalNumber decimalNumberWithString:resultsStatus];
            NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
            currencyStyle.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"tr_TR"];
            currencyStyle.numberStyle = NSNumberFormatterCurrencyStyle;
            self.ticker = [currencyStyle stringFromNumber:resultsStatusNumber];
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
    self.error = [NSError errorWithDomain:@"com.nearengine.btcbar" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"Connection Error", NSLocalizedDescriptionKey, @"Could not connect to Paribu.", NSLocalizedFailureReasonErrorKey, nil]];
    self.ticker = nil;
}

@end
