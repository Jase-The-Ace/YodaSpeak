//
//  PATManagedObject.h
//  PokeAText
//
@import CoreData;


@interface MYManagedObject : NSManagedObject

@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * persistent;

@end
