//
//  NSString+helpers.m
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)

- (int)indexOfSubstring:(NSString *)substring {
    // check for a substring
    // return the index of the first character in the substring
    // return -1 if the substring is not in the string

    NSRange textRange;
    textRange =[self rangeOfString:substring];
    if(textRange.location != NSNotFound) {
        for (int i = 0; i < self.length - substring.length; i++) {
            if ([[self substringWithRange:NSMakeRange(i, substring.length)] isEqualToString:substring]) {
                return i;
            }
        }
    } else {
        return -1;
    }
    return -1;
}

- (BOOL)containsSubstring:(NSString *)substring {
    NSRange textRange;
    textRange = [self rangeOfString:substring];
    return  (textRange.location != NSNotFound);
}

- (BOOL) validateEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isTrueValue {
    return [trim(self.lowercaseString) isEqualToString:@"true"];
}
- (BOOL)isFalseValue {
    return [trim(self.lowercaseString) isEqualToString:@"false"];
}

- (NSString *)removeLastCharacter {
    if ([self length] > 0) {
        return [self substringToIndex:[self length] - 1];
    }
    return @"";
}

- (NSString *)removeFirstCharacter {
    if ([self length] > 0) {
        return [self substringFromIndex:1];
    }
    return @"";
}


- (NSString *)lastCharacter {
    if ([self length] > 0) {
        return [self substringFromIndex:[self length] - 1];
    }
    return @"";
}

- (NSString *)firstCharacter {
    if ([self length] > 0) {
        return [self substringToIndex:1];
    }
    return @"";
}

- (NSString *)fileNameWithExtension {
    return [self lastPathComponent];
}

- (NSString *)camelCaseFromSnakeCase {
    NSArray *components = [self componentsSeparatedByString:@"_"];
    NSMutableString *camelCaseStr = [NSMutableString stringWithString:components[0]];
    if (components.count > 1) {
        for (int i = 1; i<components.count; i++) {
            NSString *thisComponent = components[i];
            [camelCaseStr appendString:thisComponent.capitalizedString];
        }
    }
    return camelCaseStr;
}

- (NSString *)snakeCaseFromCamelCase {
    NSMutableString *snakeCase = [NSMutableString string];
    
    [snakeCase appendString:[self substringWithRange:NSMakeRange(0, 1)]];
    for (NSInteger i=1; i<self.length; i++){
        NSString *ch = [self substringWithRange:NSMakeRange(i, 1)];
        if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
            [snakeCase appendString:@"_"];
        }
        [snakeCase appendString:ch];
    }
    return snakeCase.lowercaseString;
}

- (NSString *)camelCaseFromMultipleWords {
    NSMutableString *camelCase = [NSMutableString string];
    
    [camelCase appendString:[self substringWithRange:NSMakeRange(0, 1)].lowercaseString];
    BOOL capitalizeMe = NO;
    for (NSInteger i=1; i<self.length; i++){
        NSString *ch = [self substringWithRange:NSMakeRange(i, 1)];
        if ([ch isEqualToString:@" "]) {
            capitalizeMe = YES;
        } else if (!capitalizeMe) {
            [camelCase appendString:ch];
        } else {
            // uppercase
            [camelCase appendString:ch.capitalizedString];
        }
    }
    return camelCase;
}

- (NSString *)separateWordsFromSnakeCase {
    return [[self componentsSeparatedByString:@"_"] componentsJoinedByString:@" "];
}

- (NSString *)separateWordsFromCamelCase {
    return [[self snakeCaseFromCamelCase] separateWordsFromSnakeCase];
}

- (NSString *)capitalizeEachWord {
    NSArray *eachWord = [self componentsSeparatedByString:@" "];
    NSMutableArray *cappedWords = [NSMutableArray array];
    for (NSString *word in eachWord) {
        [cappedWords addObject:word.capitalizedString];
    }
    return [cappedWords componentsJoinedByString:@" "];
}

- (NSString *)snakeCaseFromMultipleWords {
    return [[self componentsSeparatedByString:@" "] componentsJoinedByString:@"_"].lowercaseString;
}

- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)characterSet {
    return [[self componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
}

- (NSString *)insertString:(NSString *)string atIndex:(unsigned int)index {
    NSString *firstSegment = [self substringToIndex:index];
    NSString *lastSegment = [self substringFromIndex:index];
    return [[NSString stringWithFormat:@"%@%@%@", firstSegment, string, lastSegment] copy];
}

- (NSString *)numbersOnlyString {
    NSCharacterSet *charSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[self componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
}

- (NSString *)capitalizeFirstLetter {
    if (self.length == 0) {
        return [self copy];
    }
    
    NSString *firstLetter = [self substringToIndex:1];
    NSString *restOfString = (self.length > 1) ? [self substringFromIndex:1] : @"";
    
    return [[firstLetter uppercaseString] stringByAppendingString:restOfString];
}

@end
