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
    if (dictionary == nil) {
        return nil;
    }
    
    id newObject = [(Class<MBObject>)objectClass mb_modelWithDictionary:dictionary];
    return newObject;
}

+ (NSDictionary *)deserializeObjectIntoDictionary:(id<MBJSONSerializable>)object {
    NSDictionary *dictionaryFromModel = [(id<MBObject>)object mb_dictionaryFromModel];
    return dictionaryFromModel;
}

@end
