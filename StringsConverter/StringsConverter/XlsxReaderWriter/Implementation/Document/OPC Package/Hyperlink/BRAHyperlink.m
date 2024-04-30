#import "BRAHyperlink.h"

@implementation BRAHyperlink

- (instancetype)initWithId:(NSString *)identifier type:(NSString *)relationshipType andTarget:(NSString *)relationTarget inParentDirectory:(NSString *)parentDirectory {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.target = relationTarget;
    }

    return self;
}

- (void)loadAttributes {
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [super dictionaryRepresentation].mutableCopy;

    dictionaryRepresentation[@"Id"] = _identifier;
    dictionaryRepresentation[@"Target"] = _target;
    dictionaryRepresentation[@"TargetMode"] = @"External";

    [super setDictionaryRepresentation:dictionaryRepresentation];
   return dictionaryRepresentation;
}

- (NSString *)type {
    return @"http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> : %@", [self class], self, _target];
}

@end
