//
//  CoreDataManager.h
//

#import <Foundation/Foundation.h>

#define VERBOSE_LOGGING MYAPI_VERBOSE_LOGGING
#define ENFORCE_BACKGROUND_PROCESSING 1
#define STORE_NAME @"YodaSpeak"
#define MAIN_THREAD_CONTEXT [CoreDataManager oldSchoolNotificatonContext]
#define PROCESSING_CONTEXT [CoreDataManager privateWriterContext]
#define __is_testing [CoreDataManager isTesting]

#define MOCDidMergeNotification @"MOCDidMergeNotification"

typedef void (^CompletionBlock)(void);

@interface CoreDataManager : NSObject

+ (void)setupForTesting;
+ (BOOL)isTesting;
+ (BOOL)isBackgroundThread;
+ (NSManagedObjectContext *)privateWriterContext;
+ (NSManagedObjectContext *)mainThreadContext;
+ (NSManagedObjectContext *)processingContext;
+ (NSManagedObjectContext *)oldSchoolNotificatonContext;
+ (dispatch_queue_t)backgroundQueue;

+ (void)resetPersistentStore;

+ (void)processAndSaveWithBlock:(void (^)(void))block
              completion:(CompletionBlock)completion;

@end

@interface NSManagedObject(Helpers)
+ (NSString *)modelName;
+ (NSString *)mixedCaseModelName;
+ (BOOL)isValidRow:(NSDictionary *)row;

+ (NSArray *)all;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (BOOL)save;
+ (id)createEntityInContext:(NSManagedObjectContext *)context;
+ (void)deleteAllAndSave:(BOOL)save;
+ (void)deleteAllAndSave:(BOOL)save withCompletion:(CompletionBlock)completion;
+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (id)findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (id)findByAttributeBetween:(NSString *)attribute withStartValue:(id)startSearchValue  withEndValue:(id)endSearchValue inContext:(NSManagedObjectContext *)context;
+ (id)findByAttributes:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context;
+ (id)findByAttributesFirstLike:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context;
- (void)saveWithCompletion:(CompletionBlock)completion;
- (void)saveSyncronous;
- (void)deleteObjectAndSave:(BOOL)save;
- (id)objectInContext:(NSManagedObjectContext *)context;
+ (NSManagedObjectContext *)currentContext;
@end

@interface NSManagedObjectContext(Helpers)
- (void)saveContextAndParentWithCompletion:(CompletionBlock)completion;
- (void)saveSyncronous;
@end