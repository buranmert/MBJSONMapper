//
//  MBJSONMapperTests.m
//  MBJSONMapperTests
//
//  Created by Mert Buran on 07/31/2016.
//  Copyright (c) 2016 Mert Buran. All rights reserved.
//

@import XCTest;

#import <MBJSONMapper/MBJSONMapper.h>
#import "MBTestSubclassDataModel.h"

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
    [mutableTestModelDict setObject:@"subclass name" forKey:@"subclassName"];
    NSDictionary *testModelDict = [mutableTestModelDict copy];
    MBTestSubclassDataModel *testModel = [MBJSONMapper serializeDictionary:testModelDict
                                                         intoObjectOfClass:[MBTestSubclassDataModel class]];
    XCTAssertNotNil(testModel);
    XCTAssert([testModel.name isEqualToString:@"John"]);
    NSDictionary *deserializedTestModelDict = [MBJSONMapper deserializeObjectIntoDictionary:testModel];
    XCTAssert(deserializedTestModelDict.allKeys.count == testModelDict.allKeys.count);
    XCTAssert([[deserializedTestModelDict objectForKey:@"subclassName"] isEqualToString:@"subclass name"], @"subclass name: %@", [deserializedTestModelDict objectForKey:@"subclassName"]);
}

- (void)testEmptyModel {
    NSDictionary *nilDict = nil;
    MBTestDataModel *nilModel = [MBJSONMapper serializeDictionary:nilDict intoObjectOfClass:[MBTestDataModel class]];
    XCTAssertNil(nilModel);
}

- (void)testMutableProperty {
    NSMutableDictionary *mutableTestModelDict = [dict(@"John", @"Appleseed", @"Hatice") mutableCopy];
    NSMutableArray *testMutableArray = [NSMutableArray arrayWithObject:@"mutable 1"];
    [mutableTestModelDict setObject:testMutableArray forKey:@"mutableArray"];
    NSArray *control1 = [testMutableArray copy];
    MBTestSubclassDataModel *testModel = [MBJSONMapper serializeDictionary:[mutableTestModelDict copy]
                                                         intoObjectOfClass:[MBTestSubclassDataModel class]];
    [testMutableArray addObject:@"mutable 2"];
    NSArray *control2 = [testMutableArray copy];
    XCTAssert(testModel.mutableArray.count == control1.count, @"count: %lu", (unsigned long)testModel.mutableArray.count);
    XCTAssert(testModel.mutableArray.count != control2.count, @"count: %lu", (unsigned long)testModel.mutableArray.count);
}

static NSDictionary* dict(NSString *name, NSString *surname, NSString *middleName) {
    return @{@"name": name,
             @"surname": surname,
             @"middleName": middleName};
}

@end

