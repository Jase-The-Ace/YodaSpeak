 //
//  CoreDataManager.m
//

#import "CoreDataManager.h"

#define BACKGROUND_THREAD_NAME "com.numi.coreDataProcessing"
#define ENFORCE_THREADING YES

static NSMutableArray *_completionBlocks;

@interface CoreDataManager()
@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *privateWriteThreadManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *processingThreadManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *oldSchoolNotificatonManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) dispatch_queue_t backgroundQ;

- (void)resetContexts;
- (void)resetStore;

@end

@implementation CoreDataManager

@synthesize mainThreadManagedObjectContext=_mainThreadManagedObjectContext;
@synthesize privateWriteThreadManagedObjectContext=_privateWriteThreadManagedObjectContext;
@synthesize processingThreadManagedObjectContext=_processingThreadManagedObjectContext;
@synthesize oldSchoolNotificatonManagedObjectContext=_oldSchoolNotificatonManagedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

static BOOL _testing = NO;
+ (void)setupForTesting {
    _testing = YES;
}
+ (BOOL)isTesting {
    return _testing;
}

+ (BOOL)isBackgroundThread {
    if (!ENFORCE_THREADING) {
        return YES;
    }
    if (_testing) {
        return YES;
    }
    
    return ![NSThread isMainThread];
}

+ (CoreDataManager *)sharedManager {
    static CoreDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CoreDataManager alloc] init];
        [sharedManager onStart];
    });
    return sharedManager;
}

- (void)onStart {
    // allocate the contexts in order
    [self privateWriteThreadManagedObjectContext];
    [self mainThreadManagedObjectContext];
    [self processingThreadManagedObjectContext];
    [self oldSchoolNotificatonManagedObjectContext];
}

#pragma mark Exposed methods

// special queue used when processing on the private writer context
+ (dispatch_queue_t)backgroundQueue {
    return [[CoreDataManager sharedManager] backgroundQ];
}

// this is the master parent context
// used for writing data to the persistent store (writing to disk)
// this uses NSPrivateQueueConcurrencyType
+ (NSManagedObjectContext *)privateWriterContext {
    return [CoreDataManager sharedManager].privateWriteThreadManagedObjectContext;
}

// this is a child of privateWriterContext
// used for propogating changes to UI
// this uses NSMainQueueConcurrencyType
+ (NSManagedObjectContext *)mainThreadContext {
    return [CoreDataManager sharedManager].mainThreadManagedObjectContext;
}

// this is a a child of mainThreadContext
// used for processing ManagedObjects
// creating new objects or modifying objects on a background thread
// saving this context, recursively saves until it reaches the privateWriterContext
+ (NSManagedObjectContext *)processingContext {
    return [CoreDataManager sharedManager].processingThreadManagedObjectContext;
}

// special case for using the old school
// NSNotication based method for propagating Core Data changes
+ (NSManagedObjectContext *)oldSchoolNotificatonContext {
    return [CoreDataManager sharedManager].oldSchoolNotificatonManagedObjectContext;
}

// do process on _backgroundQ

+ (void)processAndSaveWithBlock:(void (^)(void))block
              completion:(CompletionBlock)completion {
    // enter background thread
    dispatch_async([CoreDataManager backgroundQueue], ^{
        // do the processing
        block();
        // store the completion block
        // to be called on main thread after MOC merge is finished
        if (_completionBlocks == nil) {
            _completionBlocks = [NSMutableArray array];
        }
        if (completion) {
            [_completionBlocks addObject:completion];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MOCDidSave)
                                                     name:MOCDidMergeNotification
                                                   object:nil];
        // save
        [PROCESSING_CONTEXT saveSyncronous];
    });
}

+ (void)MOCDidSave {
    if (_completionBlocks.count > 0) {
        CompletionBlock block = _completionBlocks[0];
        [_completionBlocks removeObject:block];
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#pragma private methods

- (dispatch_queue_t)backgroundQ {
    if (_testing) {
        return dispatch_get_main_queue();
    }
    if (_backgroundQ == nil) {
        _backgroundQ = dispatch_queue_create(BACKGROUND_THREAD_NAME, NULL);
    }
    return _backgroundQ;
}

#pragma mark Create contexts
- (NSManagedObjectContext *)privateWriteThreadManagedObjectContext {
    if (_privateWriteThreadManagedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator != nil) {
            NSLog(@"HERE NOW2");
            if (_testing) {
                _privateWriteThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            } else {
                _privateWriteThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            }
            _privateWriteThreadManagedObjectContext.persistentStoreCoordinator = coordinator;
        }
    }
    return _privateWriteThreadManagedObjectContext;
}

- (NSManagedObjectContext *)mainThreadManagedObjectContext {
    if (_mainThreadManagedObjectContext == nil) {
        _mainThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainThreadManagedObjectContext.parentContext = self.privateWriteThreadManagedObjectContext;
    }
    return _mainThreadManagedObjectContext;
}

- (NSManagedObjectContext *)processingThreadManagedObjectContext {
    if (_processingThreadManagedObjectContext == nil) {
        _processingThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _processingThreadManagedObjectContext.parentContext = self.mainThreadManagedObjectContext;
    }
    return _processingThreadManagedObjectContext;
}

- (NSManagedObjectContext *)oldSchoolNotificatonManagedObjectContext {
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (_oldSchoolNotificatonManagedObjectContext == nil) {
        _oldSchoolNotificatonManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _oldSchoolNotificatonManagedObjectContext.persistentStoreCoordinator = coordinator;

        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.privateWriteThreadManagedObjectContext];
        
        // if we have called the Class method to create this context
        // we need to register for the notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self.privateWriteThreadManagedObjectContext];
    }

    return _oldSchoolNotificatonManagedObjectContext;
}

// if we want to use a separate context for NSFetchedResultsController instances
// we will notify them using the old school style to update UI
- (void)backgroundContextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (notification.object == self.privateWriteThreadManagedObjectContext) {
            if (VERBOSE_LOGGING) {
                NSLog(@"Merging contexts");
            }
            [self.oldSchoolNotificatonManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName:MOCDidMergeNotification object:nil];
        }
    });
}

#pragma mark Core Data stack

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:STORE_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *path = [STORE_NAME stringByAppendingString:@".sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:path];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // this allows for easy persistent store migration
    // when small changing are made the the MOG
    NSDictionary *options = @{
    NSMigratePersistentStoresAutomaticallyOption : @YES,
    NSInferMappingModelAutomaticallyOption : @YES
    };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [CoreDataManager resetPersistentStore];
//        abort();
    }
    
    return _persistentStoreCoordinator;
}

+ (void)resetPersistentStore {
    [[CoreDataManager sharedManager] resetStore];
}

- (void)resetStore {
    [self resetContexts];
    
    NSString *path = [STORE_NAME stringByAppendingString:@".sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        NSLog(@"***WARNING**** no persistent store");
        return;
    }
    NSPersistentStore *store = [_persistentStoreCoordinator persistentStoreForURL:storeURL];
    NSError *error;
    NSPersistentStoreCoordinator *storeCoordinator = _persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    // recreate the store
    _persistentStoreCoordinator = nil;
    [self persistentStoreCoordinator];
    [[CoreDataManager sharedManager] onStart];
}

- (void)resetContexts {
    CoreDataManager *manager = [CoreDataManager sharedManager];
    manager.processingThreadManagedObjectContext = nil;
    manager.mainThreadManagedObjectContext = nil;
    manager.oldSchoolNotificatonManagedObjectContext = nil;
    manager.privateWriteThreadManagedObjectContext = nil;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

#pragma mark Core Data Model helpers

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation NSManagedObject (Helpers)

- (void)saveWithCompletion:(CompletionBlock)completion {
    [self.managedObjectContext saveContextAndParentWithCompletion:[completion copy]];
}

- (void)saveSyncronous {
    NSManagedObjectContext *context = self.managedObjectContext;
    [context saveSyncronous];
}

- (void)deleteObjectAndSave:(BOOL)save {
    NSManagedObjectContext *context = self.managedObjectContext;
    [context deleteObject:self];
    if (save) {
        [self saveSyncronous];
    }
}

- (NSString *)description {
    if ([self respondsToSelector:@selector(name)]) {
        return [self performSelector:@selector(name)];
    }
    
    return [NSManagedObject modelName];
}

+ (NSString *)modelName {
    return [NSString stringWithFormat:@"%@", [self class]];
}

+ (id)createEntityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self modelName] inManagedObjectContext:context];
}

- (id)objectInContext:(NSManagedObjectContext *)context {
    if (context == self.managedObjectContext) {
        return self;
    }
    return [context objectWithID:self.objectID];
}

+ (void)deleteAllAndSave:(BOOL)save {
    [self deleteAllAndSave:save withCompletion:nil];
}

+ (void)deleteAllAndSave:(BOOL)save withCompletion:(CompletionBlock)completion {
    dispatch_async([CoreDataManager backgroundQueue], ^{
        NSManagedObjectContext *thisContext = nil;
        for (NSManagedObject *managedObject in [self all]) {
            thisContext = managedObject.managedObjectContext;
            [managedObject deleteObjectAndSave:NO];
        }
        if (save) {
            [thisContext saveSyncronous];
        }

        if (completion) {
            completion();
        }
    });
}

+ (NSString *)mixedCaseModelName {
    return [[self modelName] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[self modelName] substringToIndex:1] lowercaseString]];
}

+ (NSString *)plistFile {
    return [[NSBundle mainBundle] pathForResource:[self modelName] ofType:@"plist"];
}

+ (BOOL)isValidRow:(NSDictionary *)row {
    return [row count] > 0;
}

+ (BOOL)save {
    [PROCESSING_CONTEXT saveSyncronous];
    return YES;
}

+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:[self modelName] inManagedObjectContext:context];
	
	[request setEntity:entity];
    
	NSError *error = nil;
	NSArray *fetchResults = [context executeFetchRequest:request error:&error];
	request = nil;
	
	return fetchResults;
}

+ (NSArray *)all {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:[self modelName] inManagedObjectContext:[self currentContext]];
	
	[request setEntity:entity];
    
	NSError *error = nil;
	NSArray *fetchResults = [[self currentContext] executeFetchRequest:request error:&error];
	request = nil;
	
	return fetchResults;
}

+ (NSManagedObjectContext *)currentContext {
    if ([NSThread isMainThread]) {
        return MAIN_THREAD_CONTEXT;
    } else {
        return PROCESSING_CONTEXT;
    }
}

+ (NSFetchRequest *) requestFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self modelName] inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue]];
    [request setFetchLimit:1];
    
    return request;
}

+ (NSFetchRequest *) requestFirstByAttributeBetween:(NSString *)attribute withStartValue:(id)startSearchValue withEndValue:(id)endSearchValue inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self modelName] inManagedObjectContext:context]];

    NSArray *predicates = @[
                            [NSPredicate predicateWithFormat:@"%K >= %@", attribute, startSearchValue],
                            [NSPredicate predicateWithFormat:@"%K < %@", attribute, endSearchValue]
                            ];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [request setPredicate:compoundPredicate];
    [request setFetchLimit:1];

    return request;
}

+ (NSFetchRequest *) requestFirstByAttributes:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self modelName] inManagedObjectContext:context]];

    NSMutableArray *predicates = [NSMutableArray array];
    for (int i = 0; i < attributes.count; i++) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"%K = %@", attributes[i], searchValues[i]]];
    }
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [request setPredicate:compoundPredicate];
    [request setFetchLimit:1];

    return request;
}

/**
 * Use like on first object, then equals on the rest
 */
+ (NSFetchRequest *) requestFirstByAttributesFirstLike:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[self modelName] inManagedObjectContext:context]];

    NSMutableArray *predicates = [NSMutableArray array];
    for (int i = 0; i < attributes.count; i++) {
        if (i == 0) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"%K like[cd] %@", attributes[i], [NSString stringWithFormat:@"*%@*", searchValues[i]]]];
        } else {
            [predicates addObject:[NSPredicate predicateWithFormat:@"%K = %@", attributes[i], searchValues[i]]];
        }
    }
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [request setPredicate:compoundPredicate];
    [request setFetchLimit:1];

    return request;
}


+ (id)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttribute:attribute withValue:searchValue inContext:context];
	[request setFetchLimit:1];

    NSError *error = nil;

	NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil) {
        NSLog(@"Error = %@", error);
    }
	if ([results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (id)findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttribute:attribute withValue:searchValue inContext:context];
	[request setFetchLimit:0];

    NSError *error = nil;

	NSArray *results = [context executeFetchRequest:request error:&error];
	if ([results count] == 0)
	{
		return nil;
	}
	return results;
}

+ (id)findByAttributeBetween:(NSString *)attribute withStartValue:(id)startSearchValue  withEndValue:(id)endSearchValue inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttributeBetween:attribute withStartValue:startSearchValue withEndValue:endSearchValue inContext:context];
	[request setFetchLimit:0];
	
    NSError *error = nil;
    
	NSArray *results = [context executeFetchRequest:request error:&error];
	if ([results count] == 0)
	{
		return nil;
	}
	return results;
}

+ (id)findByAttributes:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttributes:attributes withValues:searchValues inContext:context];
	[request setFetchLimit:0];

    NSError *error = nil;

	NSArray *results = [context executeFetchRequest:request error:&error];
	if ([results count] == 0)
	{
		return nil;
	}
	return results;
}

+ (id)findByAttributesFirstLike:(NSArray *)attributes withValues:(NSArray *)searchValues inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self requestFirstByAttributesFirstLike:attributes withValues:searchValues inContext:context];
	[request setFetchLimit:0];

    NSError *error = nil;

	NSArray *results = [context executeFetchRequest:request error:&error];
	if ([results count] == 0)
	{
		return nil;
	}
	return results;
}

@end

@implementation NSManagedObjectContext(Helpers)

- (void)saveContextAndParentWithCompletion:(CompletionBlock)completion {
    __block NSError *error = nil;
    if (![self save:&error]) {
        // handle error
        NSLog(@"Error saving - %@", error.localizedDescription);
    } else {
        if (VERBOSE_LOGGING) {
            if (self == [CoreDataManager privateWriterContext]) {
                NSLog(@"\n***\nCONTEXT WITH COMPLETION\nSAVED PRIVATE WRITER\n***");
            }
        }
    }
    if (self.parentContext != nil) {
        [self.parentContext saveContextAndParentWithCompletion:[completion copy]];
    } else {
        completion();
    }
}

- (void)saveSyncronous {
    NSManagedObjectContext *context = self;
    
#ifdef DEBUG
    if (context == PROCESSING_CONTEXT && ENFORCE_BACKGROUND_PROCESSING && !_testing) {
        // dispatch_queue_get_label()
        // is deprecated, so we are just supressing the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // check to see if this is background thread, if not, exit
        const char* label = dispatch_queue_get_label(dispatch_get_current_queue());
        if (![[NSString stringWithUTF8String:label] isEqualToString:[NSString stringWithUTF8String:BACKGROUND_THREAD_NAME]]) {
            NSLog(@"***WARNING*** illegal save on thread %@", [NSString stringWithUTF8String:label]);
            exit(-1);
        }
    }
#pragma clang diagnostic pop
#endif

    while (context != nil) {
        NSError *error = nil;
        [context save:&error];
        if (error != nil) {
            NSLog(@"Error = %@", error.localizedDescription);
            context.mergePolicy = NSOverwriteMergePolicy;
            
            error = nil;
            [context save:&error];
            if (error != nil) {
                NSLog(@"%s, %@", __PRETTY_FUNCTION__, error);
            }
        } else if (context.mergePolicy == NSOverwriteMergePolicy) {
            context.mergePolicy = NSErrorMergePolicy;
        }
        if (VERBOSE_LOGGING) { 
            if (context == [CoreDataManager privateWriterContext]) {
                NSLog(@"\n***\nSYNCRONOUS\nSAVED PRIVATE WRITER\n***");
            }
        }
        context = context.parentContext;
    }
}

@end
