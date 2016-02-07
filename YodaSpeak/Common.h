//
//  Common.h
//  MysteryApplicationiOS
//
//  Created by Jesse A on 12/20/14.
//  Copyright (c) 2014 Jessicardo. All rights reserved.
//

#ifndef MysteryApplicationiOS_Common_h
#define MysteryApplicationiOS_Common_h

#define  YODA_API_ENDPOINT @"https://yoda.p.mashape.com/yoda"

#pragma mark Logging switches
#define LOG_LIFECYCLE 1
#define MYAPI_VERBOSE_LOGGING 0

#define TEMP_OBJECT_ID @-1

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing isEqual:[NSNull null]]) //JS addition for coredata
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline int iOSVersion (void) {
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSString *versionFirstNumber = [iosVersion substringToIndex:1];
    return [versionFirstNumber intValue];
}

static inline CGFloat screenScale() {
    CGFloat scale;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale=[[UIScreen mainScreen] scale];
    } else {
        scale=1; //only called in "old" iPads.
    }
    return scale;
}

static inline NSString *pathForDocumentsDirectory (void) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

static inline NSString *trim (NSString *string) {
    return [string stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
}

static inline NSString *concat(NSString *s1, NSString *s2) {
    return [NSString stringWithFormat:@"%@%@", s1, s2];
}

/**
 * Sort in natural order a - z
 *
 **/
static inline NSMutableArray *sort(NSMutableArray * array) {
    return [[array sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second) {
        return [first compare:second];
    }] mutableCopy];
}

/**
 * Sort in reverse order z - a
 *
 **/
static inline NSMutableArray *sortReverse(NSMutableArray * array) {
    return [[array sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second) {
        return [second compare:first];
    }] mutableCopy];
}

static inline NSString *formattedDate(NSDate *date, NSString *format) {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:format];
    NSString *formated = [DateFormatter stringFromDate:date];
    return formated;
}

#endif
