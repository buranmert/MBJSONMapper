//
//  MBJSONMapperTests.m
//  MBJSONMapperTests
//
//  Created by Mert Buran on 07/31/2016.
//  Copyright (c) 2016 Mert Buran. All rights reserved.
//

@import XCTest;

#import <MBJSONMapper/MBJSONMapper.h>
#import "MBTestDataModel.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataModel {
    
    NSDictionary *nestedModelDict = dict(@"Nested", @"John", @"");
    NSArray *nestedModelDicts = @[dict(@"John", @"Dupont", @"1"),
                                  dict(@"John", @"Dupont", @"2"),
                                  dict(@"John", @"Dupont", @"3")];
    NSMutableDictionary *mutableTestModelDict = [dict(@"John", @"Appleseed", @"Hatice") mutableCopy];
    [mutableTestModelDict setObject:nestedModelDict forKey:@"nestedModel"];
    [mutableTestModelDict setObject:nestedModelDicts forKey:@"nestedModels"];
    NSDictionary *testModelDict = [mutableTestModelDict copy];
    MBTestDataModel *testModel = [MBJSONMapper serializeDictionary:testModelDict intoObjectOfClass:[MBTestDataModel class]];
    XCTAssertNotNil(testModel);
    XCTAssert([testModel.name isEqualToString:@"John"]);
    NSDictionary *deserializedTestModelDict = [MBJSONMapper deserializeObjectIntoDictionary:testModel];
    XCTAssert(deserializedTestModelDict.allKeys.count == testModelDict.allKeys.count);
}

- (void)testEmptyModel {
    NSDictionary *nilDict = nil;
    MBTestDataModel *nilModel = [MBJSONMapper serializeDictionary:nilDict intoObjectOfClass:[MBTestDataModel class]];
    XCTAssertNil(nilModel);
}

static NSDictionary* dict(NSString *name, NSString *surname, NSString *middleName) {
    return @{@"name": name,
             @"surname": surname,
             @"middleName": middleName};
}

@end

