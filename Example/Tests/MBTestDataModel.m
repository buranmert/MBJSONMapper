//
//  MBTestDataModel.m
//  MBJSONMapper
//
//  Created by Mert Buran on 7/31/16.
//  Copyright © 2016 Mert Buran. All rights reserved.
//

#import "MBTestDataModel.h"

@implementation MBTestDataModel

- (NSDictionary<NSString*, NSString*> *)JSONKeyToPropertyMappingDictionary {
    return @{@"nestedModel.name": NSStringFromSelector(@selector(nestedModelName)),
             @"middleName":  NSStringFromSelector(@selector(secondName))};
}

- (NSDictionary<NSString*, Class> *)propertyToClassMappingDictionary {
    return @{NSStringFromSelector(@selector(nestedModel)): [MBTestDataModel class],
             NSStringFromSelector(@selector(nestedModels)): [MBTestDataModel class]};
}

@end
