//
//  YodaController.m
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import "YodaController.h"
#import "YodaModel.h"

@implementation YodaController

+ (YodaController *)sharedYodaController {
    static YodaController *_sharedYodaController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedYodaController = [[self alloc] initWithBaseURL:[NSURL URLWithString:YODA_API_ENDPOINT]];
    });
    
    return _sharedYodaController;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)fetchYodaText:(NSString *)text {
    NSMutableDictionary *parameters = @{
                                        @"message":text
                                        }.mutableCopy;
    
    [self GET:@"yoda" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([self.delegate respondsToSelector:@selector(YodaController:didFetchYoda:)]) {
            [self.delegate YodaController:self didFetchYoda:responseObject];
        }
        
        [[YodaModel sharedInstance] saveData:text yodaText:responseObject];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(YodaController:didFailWithError:)]) {
            [self.delegate YodaController:self didFailWithError:error];
        }
    }];
}


@end
