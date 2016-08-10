//
//  MBJSONSerializable.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  block to be used while JSON<>Object serialization
 *  example: NSString *updated_at_string >>> NSDate *updated_at
 *
 *  @param rawObject object to be transformed
 *
 *  @return transformed object
 */
typedef _Nonnull id (^MBTransformationBlock)(id rawObject);

@protocol MBJSONSerializable <NSObject>

@optional

/**
 *  JSON key >>> property name
 *  example: @"description" >>> NSStringFromSelector(@selector(modelDescription))
 *
 *  @return mapping dictionary
 */
- (NSDictionary<NSString*, NSString*>*)JSONKeyToPropertyMappingDictionary;

/**
 *  property name >>> property class
 *  example: NSStringFromSelector(@selector(small_thumbnail)) >>> AGTThumbnail.class
 *
 *  @return mapping dictionary
 */
- (NSDictionary<NSString*, Class> *)propertyToClassMappingDictionary;

/**
 *  property name >>> transformation block
 *  example: NSStringFromSelector(@selector(updated_at)) >>> a block that takes NSString and transforms into NSDate
 *
 *  @return name to block dictionary
 */
- (NSDictionary<NSString*, MBTransformationBlock> *)propertyToTransformationBlockDictionary;

/**
 *  JSON keys to be ignored by serializer
 *
 *  @return an array of JSON keys to be ignored
 */
- (NSArray<NSString*>*)ignoredJSONKeys;

/**
 *  property name >>> reverse transformation block
 *  example: NSStringFromSelector(@selector(updated_at)) >>> a block that takes NSDate and transforms into NSString
 *
 *  @return name to block dictionary
 */
- (NSDictionary<NSString*, MBTransformationBlock> *)propertyToReverseTransformationBlockDictionary;

@end

NS_ASSUME_NONNULL_END
