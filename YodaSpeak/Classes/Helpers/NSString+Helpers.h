//
//  NSString+helpers.ha
//

#import <Foundation/Foundation.h>

@interface NSString (Helpers)

- (int)indexOfSubstring:(NSString *)substring;
- (BOOL)containsSubstring:(NSString *)substring;
- (BOOL)validateEmail;
- (BOOL)isTrueValue;
- (BOOL)isFalseValue;
- (NSString *)removeLastCharacter;
- (NSString *)removeFirstCharacter;
- (NSString *)lastCharacter;
- (NSString *)firstCharacter;
- (NSString *)fileNameWithExtension;
- (NSString *)camelCaseFromSnakeCase;
- (NSString *)snakeCaseFromCamelCase;
- (NSString *)separateWordsFromSnakeCase;
- (NSString *)separateWordsFromCamelCase;
- (NSString *)capitalizeEachWord;
- (NSString *)snakeCaseFromMultipleWords;
- (NSString *)camelCaseFromMultipleWords;
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)insertString:(NSString *)string atIndex:(unsigned int)index;
- (NSString *)numbersOnlyString;
- (NSString *)capitalizeFirstLetter;

@end
