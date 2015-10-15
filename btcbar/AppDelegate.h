//
//  AppDelegate.h
//  btcbar
//

#import <Cocoa/Cocoa.h>

#import "BitStampUSDFetcher.h"
#import "CoinbaseUSDFetcher.h"
#import "BTCeUSDFetcher.h"
#import "BitFinexUSDFetcher.h"
#import "WinkDexUSDFetcher.h"
#import "OKCoinCNYFetcher.h"
#import "HuobiCNYFetcher.h"
#import "Btc38.h"
#import "AstockFetcher.h"
#import "HaobtcCNYFetcher.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSMenu *btcbarMainMenu;
    NSInteger currentFetcherTag;
    
    NSStatusItem *btcbarStatusItem;
    
  //  NSTimer *updateViewTimer;
    NSTimer *updateDataTimer;
    
    NSMutableArray *tickers;
    NSUserDefaults *prefs;
}

- (void)menuActionSetTicker:(id)sender;
- (void)menuActionBrowser:(id)sender;
- (void)menuActionAbout:(id)sender;
- (void)menuActionQuit:(id)sender;

- (void)handleTickerNotification:(NSNotification *)pNotification;
- (void)updateDataTimerAction:(NSTimer*)timer;

@end
