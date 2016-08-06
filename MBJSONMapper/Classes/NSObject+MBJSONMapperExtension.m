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
        NSDictionary *mappingDictionary = [self safe_keyPropertyMappingDictionary];
        NSDictionary<NSString *,id> *mappedKeyedValues = mappingDictionary != nil ? mapKeysFromKeyedValues(keyedValues, mappingDictionary) : keyedValues;
        NSDictionary<NSString*, MBTransformationBlock> *transformationsMap = [self safe_keyTransformationBlockDictionary];
        for (NSString *key in mappedKeyedValues.allKeys) {
            if ([[self safe_ignoredKeys] containsObject:key]) {
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
    Class classForDict = [[self safe_keyClassMappingDictionary] objectForKey:keyPath];
    if (classForDict == nil) {
        return dictionary;
    }
    id newObject = [classForDict new];
    [newObject configurePropertiesWithDictionary:dictionary];
    return newObject;
}

- (NSArray *)dataModelsArrayFromArray:(NSArray *)array forKeyPath:(NSString *)keyPath {
    if ([[self safe_keyClassMappingDictionary] objectForKey:keyPath] == nil) {
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
    [[[self class] safe_keyClassMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        id nestedModel = [self valueForKeyPath:key];
        NSDictionary *nestedDictionary = [nestedModel respondsToSelector:@selector(dictionaryFromModel)] ? [nestedModel dictionaryFromModel] : [nestedModel dictionaryRepresentation];
        [dictionaryRepresentation setObject:nestedDictionary forKey:key];
    }];
    NSAssert([self safe_reverseKeyTransformationBlockDictionary].count == [self safe_keyTransformationBlockDictionary].count, @"MBJSONSerializable: keyTransformations and reverseKeyTransformations do not match!");
    [[self safe_reverseKeyTransformationBlockDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MBTransformationBlock  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self valueForKeyPath:key];
        id newValue = obj(value);
        [dictionaryRepresentation setObject:newValue forKey:key];
    }];
    [[self safe_keyPropertyMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key containsString:@"."]) {
            id value = [self valueForKeyPath:obj];
            [dictionaryRepresentation setObject:value forKey:key];
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
            [tempDict setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return [tempDict copy];
}


- (NSDictionary<NSString*, NSString*>*)safe_keyPropertyMappingDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(keyPropertyMappingDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) keyPropertyMappingDictionary];
    }
    return nil;
}

- (NSDictionary<NSString*, Class> *)safe_keyClassMappingDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(keyClassMappingDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) keyClassMappingDictionary];
    }
    return nil;
}

- (NSDictionary<NSString*, MBTransformationBlock> *)safe_keyTransformationBlockDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(keyTransformationBlockDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) keyTransformationBlockDictionary];
    }
    return nil;
}

- (NSArray<NSString*>*)safe_ignoredKeys {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(ignoredKeys)]) {
        return [((NSObject<MBJSONSerializable> *)self) ignoredKeys];
    }
    return nil;
}

- (NSDictionary<NSString*, MBTransformationBlock> *)safe_reverseKeyTransformationBlockDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(reverseKeyTransformationBlockDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) reverseKeyTransformationBlockDictionary];
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
