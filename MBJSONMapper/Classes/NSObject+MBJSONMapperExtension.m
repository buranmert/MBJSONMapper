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

#pragma mark - Public methods

+ (instancetype)mb_modelWithDictionary:(NSDictionary<NSString *,id>*)dictionary {
    id model = [self new];
    if (model != nil) {
        [model configurePropertiesWithDictionary:dictionary];
    }
    return model;
}

- (NSDictionary<NSString *,id>*)mb_dictionaryFromModel {
    NSMutableDictionary *dictionaryRepresentation = [self dictionaryRepresentation];
    [[self safe_keyClassMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        id nestedModel = [self valueForKeyPath:key];
        if ([nestedModel conformsToProtocol:@protocol(MBJSONSerializable)]) {
            NSDictionary *nestedDictionary = [nestedModel mb_dictionaryFromModel];
            [dictionaryRepresentation setObject:nestedDictionary forKey:key];
        }
    }];
    [[self safe_reverseKeyTransformationBlockDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MBTransformationBlock  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self valueForKeyPath:key];
        if (value != nil) {
            id newValue = obj(value);
            [dictionaryRepresentation setObject:newValue forKey:key];
        }
    }];
    [[self safe_JSONKeyToPropertyMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
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

#pragma mark - Dictionary>>>Object

- (void)configurePropertiesWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)]) {
        NSDictionary *mappingDictionary = [self safe_JSONKeyToPropertyMappingDictionary];
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
                if ([newObject conformsToProtocol:@protocol(NSCopying)]) {
                    newObject = [newObject copy];
                }
            }
            else {
                newObject = transformationBlock(obj);
            }
            [self setValue:newObject forKeyPath:key];
        }
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSDictionary<NSString*, NSString*> *map = [self safe_JSONKeyToPropertyMappingDictionary];
    __block NSString *JSONKey = key;
    [map enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                 usingBlock:^(NSString * _Nonnull mappedJSONKey, NSString * _Nonnull propertyName, BOOL * _Nonnull stop) {
                                     if ([key isEqualToString:propertyName]) {
                                         JSONKey = mappedJSONKey;
                                         *stop = YES;
                                     }
                                 }];
    NSLog(@"MBJSONMapper: WARNING!!!\n%@ setValue: \"%@\" fromJSONKey: \"%@\" forUndefinedKey: \"%@\"", NSStringFromClass(self.class), [value description], JSONKey, key);
}

#pragma mark - Helper property constructors

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

#pragma mark - Object>>>Dictionary

- (NSMutableDictionary<NSString*, id> *)dictionaryRepresentation {
    Class class = self.class;
    NSMutableDictionary *recursiveDictionaryRepresentation = [NSMutableDictionary dictionary];
    while (class != NSObject.class) {
        [recursiveDictionaryRepresentation addEntriesFromDictionary:[self dictionaryRepresentationForSubclass:class]];
        class = class.superclass;
    }
    return recursiveDictionaryRepresentation;
}

- (NSDictionary<NSString*, id> *)dictionaryRepresentationForSubclass:(Class)subclass {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(subclass, &outCount);
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

#pragma mark - Key mapping

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

#pragma mark - Protocol methods

- (NSDictionary<NSString*, NSString*>*)safe_JSONKeyToPropertyMappingDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(JSONKeyToPropertyMappingDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) JSONKeyToPropertyMappingDictionary];
    }
    return nil;
}

- (NSDictionary<NSString*, Class> *)safe_keyClassMappingDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(propertyToClassMappingDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) propertyToClassMappingDictionary];
    }
    return nil;
}

- (NSDictionary<NSString*, MBTransformationBlock> *)safe_keyTransformationBlockDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(propertyToTransformationBlockDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) propertyToTransformationBlockDictionary];
    }
    return nil;
}

- (NSArray<NSString*>*)safe_ignoredKeys {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(ignoredJSONKeys)]) {
        return [((NSObject<MBJSONSerializable> *)self) ignoredJSONKeys];
    }
    return nil;
}

- (NSDictionary<NSString*, MBTransformationBlock> *)safe_reverseKeyTransformationBlockDictionary {
    if ([self conformsToProtocol:@protocol(MBJSONSerializable)] &&
        [self respondsToSelector:@selector(propertyToReverseTransformationBlockDictionary)]) {
        return [((NSObject<MBJSONSerializable> *)self) propertyToReverseTransformationBlockDictionary];
    }
    return nil;
}

@end
