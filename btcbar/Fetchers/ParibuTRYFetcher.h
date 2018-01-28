//
//  ParibuTRYFetcher.h
//  btcbar
//

#import <Foundation/Foundation.h>
#import "Fetcher.h"

@interface ParibuTRYFetcher : NSObject<Fetcher, NSURLConnectionDelegate>

@property (nonatomic) NSString* ticker;
@property (nonatomic) NSString* ticker_menu;
@property (nonatomic) NSString* url;
@property (nonatomic) NSError* error;
@property (nonatomic) NSMutableData *responseData;

- (void)requestUpdate;

@end
