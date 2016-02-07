//
//  YodaController.h
//  YodaSpeak
//
//  Created by Jesse A on 2/7/16.
//  Copyright © 2016 Jesse A. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
@protocol YodaControllerDelegate;

@interface YodaController : AFHTTPSessionManager
@property (nonatomic, weak) id<YodaControllerDelegate>delegate;

+ (YodaController *)sharedYodaController;
- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)fetchYodaText:(NSString *)text;

@end

@protocol YodaControllerDelegate <NSObject>

@optional

- (void)YodaController:(YodaController *)controller didFetchYoda:(NSString *)yodaText;
- (void)YodaController:(YodaController *)controller didFailWithError:(NSError *)error;
@end

