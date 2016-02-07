//
//  NSDate+Helpers.m
//

#import "NSDate+Helpers.h"

#define HOUR_IN_SECS    60.0f * 60.0f
#define DAY_IN_SECS     HOUR_IN_SECS * 24.0f
#define WEEK_IN_SECS    DAY_IN_SECS * 7.0f

@implementation NSDate (Helpers)

- (BOOL)isToday {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];

    return [today isEqualToDate:otherDate];
}

- (BOOL)isAfterDate:(NSDate *)dateTwo {
    return ([self compare:dateTwo] == NSOrderedDescending);
}

- (BOOL)isEqualOrAfterDate:(NSDate *)dateTwo {
    return ([self compare:dateTwo] == NSOrderedDescending ||
            [self compare:dateTwo] == NSOrderedSame);
}

- (BOOL)isBeforeDate:(NSDate *)dateTwo {
    return ([self compare:dateTwo] == NSOrderedAscending);
}

- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    return ([self isEqualOrAfterDate:startDate] &&
            [self isBeforeDate:endDate]);
}

- (int)ceiledDayCountSinceStartDate:(NSDate *)startDate {
    NSTimeInterval time = [self timeIntervalSinceDate:startDate];
    float secsInDay = 60 * 60 * 24;
    float dayCount = time/secsInDay;
    return ceilf(dayCount);
}

- (int)flooredDayCountSinceStartDate:(NSDate *)startDate {
    NSTimeInterval time = [self timeIntervalSinceDate:startDate];
    float secsInDay = 60 * 60 * 24;
    float dayCount = time/secsInDay;
    return floorf(dayCount);
}

- (double)absoluteDateIntervalSinceStartDate:(NSDate *)startDate {
    NSTimeInterval time = [self timeIntervalSinceDate:startDate];
    double secsInDay = 60 * 60 * 24;
    return time / secsInDay;
}


- (NSDate *)dateByAddingSeconds:(NSNumber *)seconds minutes:(NSNumber *)minutes days:(NSNumber *)days months:(NSNumber *)months years:(NSNumber *)years {
    NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
    if (seconds != nil) {
        dateComponents.second = seconds.intValue;
    }
    if (minutes != nil) {
        dateComponents.minute = minutes.intValue;
    }
    if (days != nil) {
        dateComponents.day = days.intValue;
    }
    if (months != nil) {
        dateComponents.month = months.intValue;
    }
    if (years != nil) {
        dateComponents.year = years.intValue;
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];

    return [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

- (BOOL)isWeekend {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSUInteger weekdayOfDate = [components weekday];

    return (weekdayOfDate == weekdayRange.location || weekdayOfDate == weekdayRange.length);
}

- (BOOL)isWeekday {
    return ![self isWeekend];
}

- (BOOL)isWithinTheLastWeek {
    return ([[NSDate date] timeIntervalSinceDate:self] < WEEK_IN_SECS);
}

- (BOOL)isYesterday {
    NSDate *yesterday = [[NSDate date] dateByAddingSeconds:nil
                                                   minutes:nil
                                                      days:@(-1)
                                                    months:nil
                                                     years:nil];
    return [self isSameDayAs:yesterday];
}

- (BOOL)isTomorrow {
    NSDate *yesterday = [[NSDate date] dateByAddingSeconds:nil
                                                   minutes:nil
                                                      days:@(1)
                                                    months:nil
                                                     years:nil];
    return [self isSameDayAs:yesterday];
}

- (BOOL)isSameDayAs:(NSDate *)aDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSUInteger parts = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);

    NSDateComponents *thisDayComponents = [calendar components:parts fromDate:self];
    NSDateComponents *compareDayComponents = [calendar components:parts fromDate:aDate];

    return (thisDayComponents.year == compareDayComponents.year &&
            thisDayComponents.month == compareDayComponents.month &&
            thisDayComponents.day == compareDayComponents.day);
}

- (NSDate *)begginingOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                               fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;

    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                               fromDate:self];
    components.hour = 24;
    components.minute = 59;
    components.second = 59;

    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [calendar firstWeekday])];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    return beginningOfWeek;
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: (([calendar firstWeekday]+7) - [weekdayComponents weekday])];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    return beginningOfWeek;
}

- (NSDate *)lastWeek {
    NSDate *lastWeek = [self dateByAddingSeconds:@0 minutes:@0 days:@(-6) months:@0 years:@0];
    return lastWeek;
}

- (NSString *)formattedDate:(NSString *)format {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.dateFormat = format;
    return [df stringFromDate:self];
}

+ (NSString *)hoursAndMinutesStringFromMinutes:(unsigned)numMinutes {
    return numMinutes > 60
    ? [NSString stringWithFormat:@"%u hr %u min", (numMinutes - numMinutes % 60)/60, numMinutes % 60]
    : [NSString stringWithFormat:@"%u min", numMinutes];
}

@end
