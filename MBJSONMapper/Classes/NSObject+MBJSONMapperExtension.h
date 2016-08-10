//
//  NSObject+MBJSONMapperExtension.h
//  Pods
//
//  Created by Mert Buran on 7/31/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MBObject <NSObject>

+ (instancetype)mb_modelWithDictionary:(NSDictionary<NSString *,id>*)dictionary;
- (NSDictionary<NSString *,id>*)mb_dictionaryFromModel;

@end

@interface NSObject (MBJSONMapperExtension) <MBObject>
@end

NS_ASSUME_NONNULL_END
