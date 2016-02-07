//
//  YodaModel.h
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "MyBaseModel.h"

@interface YodaModel : MyBaseModel

+ (YodaModel *)sharedInstance;

- (void)saveData:(NSString *)text yodaText:(NSString *)yodaText;

@end
