//
//  NSObject+MBJSONMapperExtension.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (MBJSONMapperExtension)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryFromModel;

@end
