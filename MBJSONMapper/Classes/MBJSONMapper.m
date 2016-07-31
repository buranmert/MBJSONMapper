//
//  MBJSONMapper.m
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <MBJSONMapper/MBJSONMapper.h>
#import <MBJSONMapper/NSObject+MBJSONMapperExtension.h>

@implementation MBJSONMapper

+ (id<MBJSONSerializable>)serializeDictionary:(NSDictionary *)dictionary
                            intoObjectOfClass:(Class<MBJSONSerializable>)objectClass {
    NSAssert([objectClass conformsToProtocol:@protocol(MBJSONSerializable)], @"MBJSONMapper:serializeDictionary:intoObjectOfClass: objectClass does NOT conform to MBJSONSerializable protocol!");
    id newObject = [objectClass performSelector:@selector(modelWithDictionary:) withObject:dictionary];
    return newObject;
}

+ (NSDictionary *)deserializeObjectIntoDictionary:(id<MBJSONSerializable>)object {
    NSAssert([object isKindOfClass:[NSObject class]], @"MBJSONMapper:deserializeObjectIntoDictionary object is NOT kind of NSObject class!");
    NSDictionary *dictionaryRepresentation = [((NSObject<MBJSONSerializable> *)object) rawDictionaryFromModel];
    return dictionaryRepresentation;
}

@end
