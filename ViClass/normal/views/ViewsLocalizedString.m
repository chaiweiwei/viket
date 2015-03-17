//
//  ViewsLocalizedString.m
//  GWCClub
//
//  Created by yulong chen on 13-3-14.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ViewsLocalizedString.h"
#import "ALDUtils.h"

NSString * ViewsLocalizedStringFormat(NSString *key,NSString *defValue);

// Handle localized strings stored in a bundle

NSString * ViewsLocalizedStringFormat(NSString *key,NSString *defValue)
{
    static NSBundle *viewsBundle = nil;
    if (viewsBundle == nil) {
        NSBundle *viewBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"views" ofType:@"bundle"]];
        viewsBundle = [NSBundle bundleWithPath:[viewBundle pathForResource:[[NSLocale preferredLanguages] objectAtIndex:0] ofType:@"lproj"]];
        if (viewsBundle == nil) {
            // If there is no localized strings for default language, select english language
            viewsBundle = [NSBundle bundleWithPath:[viewBundle pathForResource:@"en" ofType:@"lproj"]];
        }
    }
    if (defValue==nil) {
        defValue=key;
    }
    return [viewsBundle localizedStringForKey:key value:defValue table:nil];
}

NSString* ViewsLocalizedString(NSString *defValue,NSString *key, ...) 
{
	// Localize the format
	NSString *localizedStringFormat = ViewsLocalizedStringFormat(key,defValue);
	
	va_list args;
    va_start(args, key);
    NSString *string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
    va_end(args);
	return ALDReturnAutoreleased(string);
}