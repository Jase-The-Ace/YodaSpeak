//
//  YodaModel.m
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "YodaModel.h"
#import "YodaSpoke.h"

@implementation YodaModel

+ (YodaModel *)sharedInstance {
    static YodaModel *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)saveData:(NSString *)text yodaText:(NSString *)yodaText {
    [CoreDataManager processAndSaveWithBlock:^{
        YodaSpoke *dbObject;
        dbObject = [YodaSpoke createEntityInContext:PROCESSING_CONTEXT];
        dbObject.text = text;
        dbObject.yodaText = yodaText;
        dbObject.date = [NSDate date];
    } completion:nil];
}

@end
