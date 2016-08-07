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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    NSAssert([objectClass conformsToProtocol:@protocol(MBJSONSerializable)], @"MBJSONMapper:serializeDictionary:intoObjectOfClass: objectClass does NOT conform to MBJSONSerializable protocol!");
    id newObject = [objectClass performSelector:@selector(modelWithDictionary:) withObject:dictionary];
#pragma clang diagnostic pop
    return newObject;
}

+ (NSDictionary *)deserializeObjectIntoDictionary:(NSObject<MBJSONSerializable> *)object {
    NSAssert([object conformsToProtocol:@protocol(MBJSONSerializable)], @"MBJSONMapper:deserializeObjectIntoDictionary: object does NOT conform to MBJSONSerializable protocol!");
    NSAssert([object isKindOfClass:[NSObject class]], @"MBJSONMapper:deserializeObjectIntoDictionary object is NOT kind of NSObject class!");
    
    NSDictionary *dictionaryFromModel = [((NSObject<MBJSONSerializable> *)object) dictionaryFromModel];
    return dictionaryFromModel;
}

@end
