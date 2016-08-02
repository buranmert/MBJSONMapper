//
//  MBTestDataModel.h
//  MBJSONMapper
//
//  Created by Mert Buran on 7/31/16.
//  Copyright © 2016 Mert Buran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBJSONMapper/MBJSONSerializable.h>

@interface MBTestDataModel : NSObject <MBJSONSerializable>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *surname;
@property (nonatomic, copy, readonly) NSString *secondName;

@property (nonatomic, copy, readonly) NSString *nestedModelName;

@property (nonatomic, copy, readonly) MBTestDataModel *nestedModel;
@property (nonatomic, copy, readonly) NSArray<MBTestDataModel*> *nestedModels;

@end
