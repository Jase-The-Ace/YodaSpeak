//
//  NSDate+Helpers.h

#import <Foundation/Foundation.h>

@interface NSDate (Helpers)

- (BOOL)isToday;
- (BOOL)isAfterDate:(NSDate *)dateTwo;
- (BOOL)isEqualOrAfterDate:(NSDate *)dateTwo;
- (BOOL)isBeforeDate:(NSDate *)dateTwo;
- (BOOL)isBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
- (int)ceiledDayCountSinceStartDate:(NSDate *)startDate;
- (int)flooredDayCountSinceStartDate:(NSDate *)startDate;
- (double)absoluteDateIntervalSinceStartDate:(NSDate *)startDate;
- (NSDate *)dateByAddingSeconds:(NSNumber *)seconds minutes:(NSNumber *)minutes days:(NSNumber *)days months:(NSNumber *)months years:(NSNumber *)years;
- (BOOL)isWeekend;
- (BOOL)isWeekday;
- (BOOL)isWithinTheLastWeek;
- (BOOL)isYesterday;
- (BOOL)isTomorrow;
- (BOOL)isSameDayAs:(NSDate *)aDate;
- (NSDate *)begginingOfDay;
- (NSDate *)endOfDay;
- (NSDate *)beginningOfWeek;
- (NSDate *)endOfWeek;
- (NSDate *)lastWeek;
- (NSString *)formattedDate:(NSString *)format;
+ (NSString *)hoursAndMinutesStringFromMinutes:(unsigned)numMinutes;

@end
