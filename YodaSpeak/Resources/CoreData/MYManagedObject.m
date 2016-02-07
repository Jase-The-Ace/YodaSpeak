//
//  PATManagedObject.m
//  PokeAText
//

#import "MYManagedObject.h"


@implementation MYManagedObject

@dynamic dirty;
@dynamic identifier;
@dynamic persistent;

- (void)copy:(MYManagedObject *)object {
    if ([object respondsToSelector:@selector(dirty)]) {
        self.dirty = object.dirty;
    }
    if ([object respondsToSelector:@selector(identifier)]) {
        self.identifier = object.identifier;
    }
    if ([object respondsToSelector:@selector(persistent)]) {
        self.persistent = object.persistent;
    }  
}

@end
