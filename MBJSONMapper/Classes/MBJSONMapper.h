//
//  MBJSONMapper.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>
#import <MBJSONMapper/MBJSONSerializable.h>

@interface MBJSONMapper : NSObject

+ (id<MBJSONSerializable>)serializeDictionary:(NSDictionary *)dictionary
                            intoObjectOfClass:(Class<MBJSONSerializable>)objectClass;

+ (NSDictionary *)deserializeObjectIntoDictionary:(NSObject<MBJSONSerializable> *)object;

@end
