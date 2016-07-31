//
//  MBJSONSerializable.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>

typedef id (^MBTransformationBlock)(id rawObject);

@protocol MBJSONSerializable <NSObject>

@optional

- (NSDictionary<NSString*, NSString*>*)keyPropertyMappingDictionary;
- (NSDictionary<NSString*, Class> *)keyClassMappingDictionary;
- (NSDictionary<NSString*, MBTransformationBlock> *)keyTransformationBlockDictionary;
- (NSArray<NSString*>*)ignoredKeys;
- (NSDictionary<NSString*, MBTransformationBlock> *)reverseKeyTransformationBlockDictionary;

@end
