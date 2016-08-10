//
//  MBJSONMapper.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>
#import <MBJSONMapper/MBJSONSerializable.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBJSONMapper : NSObject

/**
 *  creates an instance of given class from NSDictionary
 *
 *  @param dictionary  JSON dictionary
 *  @param objectClass class of instance to be created
 *
 *  @return newly created objectClass instance
 */
+ (id<MBJSONSerializable>)serializeDictionary:(NSDictionary *)dictionary
                            intoObjectOfClass:(Class<MBJSONSerializable>)objectClass;

/**
 *  creates NSDictionary instance from given object
 *
 *  @param object to be converted into NSDictionary
 *
 *  @return newly created NSDictionary instance
 */
+ (NSDictionary *)deserializeObjectIntoDictionary:(id<MBJSONSerializable>)object;

@end

NS_ASSUME_NONNULL_END
