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
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.requestSerializer setValue:MASHAPE_KEY forHTTPHeaderField:@"X-Mashape-Key"];
        [self.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    }
    
    return self;
}


- (void)fetchYodaText:(NSString *)text {
    NSMutableDictionary *parameters = @{
                                        @"sentence":text
                                        }.mutableCopy;
    
    [self GET:@"yoda" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([self.delegate respondsToSelector:@selector(YodaController:didFetchYoda:)]) {
            [self.delegate YodaController:self didFetchYoda:responseString];
        }
        
        [[YodaModel sharedInstance] saveData:text yodaText:responseString];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(YodaController:didFailWithError:)]) {
            [self.delegate YodaController:self didFailWithError:error];
        }
    }];
}


@end
