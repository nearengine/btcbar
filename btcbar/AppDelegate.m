//
//  AppDelegate.m
//  btcbar
//

#import "AppDelegate.h"

@implementation AppDelegate


//
// ENTRY & EXIT
//

// Status item initialization
- (void)awakeFromNib
{
    // Load ticker preference from disk
    prefs = [NSUserDefaults standardUserDefaults];

    // Register update notifications for tickers
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleTickerNotification:)
     name:@"btcbar_ticker_update"
     object:nil];

    // Pass each ticker object into a dictionary, get first updates
    tickers = [NSMutableArray arrayWithObjects:
               [[BitFinexUSDFetcher alloc] init],
               [[BitStampUSDFetcher alloc] init],
               [[BTCeUSDFetcher alloc] init],
               [[CoinbaseUSDFetcher alloc] init],
               [[HuobiUSDFetcher alloc] init],
               [[OKCoinUSDFetcher alloc] init],
               [[WinkDexUSDFetcher alloc] init],
               nil];

    // If ticker preference does not exist, default to 0
    if (![prefs integerForKey:@"btcbar_ticker_index"])
        [prefs setInteger:0 forKey:@"btcbar_ticker_index"];
    currentFetcherTag = [prefs integerForKey:@"btcbar_ticker_index"];
    
    // Clean up legacy preference
    [prefs removeObjectForKey:@"btcbar_ticker"];

    // If ticker preference exceeds the bounds of `tickers`, default to 0
    if (currentFetcherTag < 0 || currentFetcherTag >= [tickers count])
        currentFetcherTag = 0;

    // Initialize main menu
    btcbarMainMenu = [[NSMenu alloc] initWithTitle:@"loading..."];

    // Add each loaded ticker object to main menu
    for(id <Fetcher> ticker in tickers)
    {
        NSMenuItem *new_menuitem = [[NSMenuItem alloc] initWithTitle:[ticker ticker_menu] action:@selector(menuActionSetTicker:) keyEquivalent:@""];
        new_menuitem.tag = [tickers indexOfObject:ticker];
        [btcbarMainMenu addItem:new_menuitem];
    }

    // Add the separator, Open in Browser, and Quit items to main menu
    [btcbarMainMenu addItem:[NSMenuItem separatorItem]];
    [btcbarMainMenu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(menuActionQuit:) keyEquivalent:@"q"]];

    // Set the default ticker's menu item state to checked
    [[btcbarMainMenu.itemArray objectAtIndex:currentFetcherTag] setState:NSOnState];

    // Initialize status bar item with flexible width
    btcbarStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    // Set menu options on click
    [btcbarStatusItem setMenu:btcbarMainMenu];

    // Setup timer to update all tickers every 60 seconds
    updateDataTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(updateDataTimerAction:) userInfo:nil repeats:YES];
}


//
// MENUITEM ACTIONS
//

// Action for menu items which change current ticker
- (void)menuActionSetTicker:(id)sender
{
    // Set all menu items to "off" state
    for (NSMenuItem *menuitem in btcbarMainMenu.itemArray)
        menuitem.state = NSOffState;

    // Set this menu item to "on" state
    [sender setState:NSOnState];

    // Update ticker preference
    currentFetcherTag = [sender tag];
    [prefs setInteger:currentFetcherTag forKey:@"btcbar_ticker"];
    [prefs synchronize];

    // Update the requested ticker immediately
    [[tickers objectAtIndex:currentFetcherTag] requestUpdate];

    // Force the status item value to update
    [[NSNotificationCenter defaultCenter] postNotificationName:@"btcbar_ticker_update" object:[tickers objectAtIndex:currentFetcherTag]];

}

// "Open in Browser" action
- (void)menuActionBrowser:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[(id <Fetcher>)[tickers objectAtIndex:currentFetcherTag] url]]];
}

// "Quit" action
- (void)menuActionQuit:(id)sender
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}


//
// CALLBACKS
//

// Handles Fetcher completion notifications
-(void)handleTickerNotification:(NSNotification *)pNotification
{
    if ([[pNotification object] ticker] != nil)
    {
        // Set the menu item of the notifying Fetcher to its latest ticker value
        [[[btcbarMainMenu itemArray] objectAtIndex:[tickers indexOfObject:[pNotification object]]] setTitle:[NSString stringWithFormat:@"[%@] %@",[[pNotification object] ticker], [[pNotification object] ticker_menu]]];
    }
    else
    {
        // Set the ticker value in the menu to the short error
        [[[btcbarMainMenu itemArray] objectAtIndex:[tickers indexOfObject:[pNotification object]]] setTitle:[NSString stringWithFormat:@"[%@] %@",[[pNotification object] error].localizedDescription, [[pNotification object] ticker_menu]]];
    }

    // If this notification is for the currently selected ticker, update the status item too
    if ([pNotification object] == [tickers objectAtIndex:currentFetcherTag])
    {
        if ([[pNotification object] ticker] == nil)
        {
            [btcbarStatusItem.button setTitle: @""];
            [btcbarStatusItem.button setToolTip: [NSString stringWithFormat: @"%@ Error: %@", [[pNotification object] ticker_menu], [[pNotification object] error].localizedFailureReason]];
        }
        else
        {
            // Set the status item to the current Fetcher's ticker
            NSMenuItem *new_menuItem = [[NSMenuItem alloc] initWithTitle:[(id <Fetcher>)[tickers objectAtIndex:currentFetcherTag] ticker] action:@selector(menuActionSetTicker:) keyEquivalent:@""];
            NSDictionary *attributes = @{
                                         NSFontAttributeName: [NSFont boldSystemFontOfSize:7]
                                         };
            NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:[new_menuItem title] attributes:attributes];
            [new_menuItem setAttributedTitle:attributedTitle];

            [btcbarStatusItem.button setAttributedTitle:attributedTitle];
            [btcbarStatusItem.button setToolTip: [[tickers objectAtIndex:currentFetcherTag] ticker_menu]];
        }
    }

}

// Requests for each Fetcher to update itself
- (void)updateDataTimerAction:(NSTimer *)timer
{
    for (id <Fetcher> ticker in tickers)
        [ticker requestUpdate];
}

@end
