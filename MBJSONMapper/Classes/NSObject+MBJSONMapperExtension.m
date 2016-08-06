//
//  NSObject+MBJSONMapperExtension.m
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <MBJSONMapper/NSObject+MBJSONMapperExtension.h>
#import <MBJSONMapper/MBJSONSerializable.h>
#import <objc/runtime.h>

@implementation NSObject (MBJSONMapperExtension)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    id model = [self new];
    if (model != nil) {
        [model configurePropertiesWithDictionary:dictionary];
    }
    return model;
}

- (void)configurePropertiesWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)]) {
        NSDictionary *mappingDictionary = [self safeProtocolMethod:@selector(keyPropertyMappingDictionary)];
        NSDictionary<NSString *,id> *mappedKeyedValues = mappingDictionary != nil ? mapKeysFromKeyedValues(keyedValues, mappingDictionary) : keyedValues;
        NSDictionary<NSString*, MBTransformationBlock> *transformationsMap = [self safeProtocolMethod:@selector(keyTransformationBlockDictionary)];
        for (NSString *key in mappedKeyedValues.allKeys) {
            if ([[self safeProtocolMethod:@selector(ignoredKeys)] containsObject:key]) {
                continue;
            }
            id obj = [mappedKeyedValues objectForKey:key];
            MBTransformationBlock transformationBlock = [transformationsMap objectForKey:key];
            id newObject = nil;
            if (transformationBlock == nil) {
                newObject = [self dataModelFromObject:obj forKeyPath:key];
            }
            else {
                newObject = transformationBlock(obj);
            }
            [self setValue:newObject forKeyPath:key];
        }
    }
}

#pragma mark - Helper constructors

- (id)dataModelFromObject:(id)obj forKeyPath:(NSString *)keyPath {
    if ([obj isEqual:[NSNull null]]) {
        return nil;
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        id newObject = [self dataModelFromDictionary:(NSDictionary *)obj forKeyPath:keyPath];
        return newObject;
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *newArray = [self dataModelsArrayFromArray:obj forKeyPath:keyPath];
        return newArray;
    }
    else {
        return obj;
    }
}

- (id)dataModelFromDictionary:(NSDictionary *)dictionary forKeyPath:(NSString *)keyPath {
    Class classForDict = [[self safeProtocolMethod:@selector(keyClassMappingDictionary)] objectForKey:keyPath];
    if (classForDict == nil) {
        return dictionary;
    }
    id newObject = [classForDict new];
    [newObject configurePropertiesWithDictionary:dictionary];
    return newObject;
}

- (NSArray *)dataModelsArrayFromArray:(NSArray *)array forKeyPath:(NSString *)keyPath {
    if ([[self safeProtocolMethod:@selector(keyClassMappingDictionary)] objectForKey:keyPath] == nil) {
        return array;
    }
    NSMutableArray *newObjects = [NSMutableArray array];
    for (id arrayObject in array) {
        [newObjects addObject:[self dataModelFromObject:arrayObject forKeyPath:keyPath]];
    }
    return [NSArray arrayWithArray:newObjects];
}

- (NSDictionary *)dictionaryFromModel {
    NSMutableDictionary *dictionaryRepresentation = [[self dictionaryRepresentation] mutableCopy];
    [[self safeProtocolMethod:@selector(keyClassMappingDictionary)] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        id nestedModel = [self valueForKeyPath:key];
        if ([nestedModel conformsToProtocol:@protocol(MBJSONSerializable)]) {
            NSDictionary *nestedDictionary = [nestedModel dictionaryFromModel];
            [dictionaryRepresentation setObject:nestedDictionary forKey:key];
        }
    }];
    [[self safeProtocolMethod:@selector(reverseKeyTransformationBlockDictionary)] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MBTransformationBlock  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self valueForKeyPath:key];
        if (value != nil) {
            id newValue = obj(value);
            [dictionaryRepresentation setObject:newValue forKey:key];
        }
    }];
    [[self safeProtocolMethod:@selector(keyPropertyMappingDictionary)] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key containsString:@"."]) {
            id value = [self valueForKeyPath:obj];
            if (value != nil) {
                [dictionaryRepresentation setObject:value forKey:key];
            }
        }
        [dictionaryRepresentation removeObjectForKey:obj];
    }];
    return [dictionaryRepresentation copy];
}

- (NSDictionary<NSString*, id> *)dictionaryRepresentation {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:outCount];
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *ivar = property_copyAttributeValue(property, "V");
        const char *dynamic = property_copyAttributeValue(property, "D");
        const char *readonly = property_copyAttributeValue(property, "R");
        if(propName && (ivar || (dynamic && !readonly))) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            id propertyValue = [self valueForKeyPath:propertyName];
            if (propertyValue) {
                [tempDict setObject:propertyValue forKey:propertyName];
            }
        }
    }
    free(properties);
    return [tempDict copy];
}

- (id)safeProtocolMethod:(SEL)selector {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:selector]) {
        return [self performSelector:selector];
    }
    return nil;
}

static NSDictionary<NSString *,id> *mapKeysFromKeyedValues(NSDictionary<NSString *,id> *keyedValues, NSDictionary<NSString*, NSString*> *mappingDictionary) {
    NSMutableDictionary *mappedDict = [keyedValues mutableCopy];
    [mappingDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        id mappedValue = [keyedValues valueForKeyPath:key];
        [mappedDict removeObjectForKey:key];
        if (mappedValue != nil) {
            [mappedDict setObject:mappedValue forKey:obj];
        }
    }];
    return [mappedDict copy];
}

@end
