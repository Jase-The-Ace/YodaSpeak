//
//  YodaSpoke+CoreDataProperties.h
//  YodaSpeak
//
//  Created by Jesse A on 2/6/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YodaSpoke.h"

NS_ASSUME_NONNULL_BEGIN

@interface YodaSpoke (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *yodaText;
@property (nullable, nonatomic, retain) NSDate *date;

@end

NS_ASSUME_NONNULL_END
