# MBJSONMapper

[![Join the chat at https://gitter.im/MBJSONMapper/Lobby](https://badges.gitter.im/MBJSONMapper/Lobby.svg)](https://gitter.im/MBJSONMapper/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![CI Status](http://img.shields.io/travis/buranmert/MBJSONMapper.svg?style=flat)](https://travis-ci.org/buranmert/MBJSONMapper)
[![Version](https://img.shields.io/cocoapods/v/MBJSONMapper.svg?style=flat)](http://cocoapods.org/pods/MBJSONMapper)
[![License](https://img.shields.io/cocoapods/l/MBJSONMapper.svg?style=flat)](http://cocoapods.org/pods/MBJSONMapper)
[![Platform](https://img.shields.io/cocoapods/p/MBJSONMapper.svg?style=flat)](http://cocoapods.org/pods/MBJSONMapper)

## Why yet another JSON<>Object library???

I looked at other libraries but none of them seemed simple/minimal enough to me. The whole idea of this library is being as small as possible:

1. 2 public headers
    1. 1 protocol
    2. 1 adapter
2. Total line count of .m files: 186

## Usage

### Basic usage

#### JSON

```javascript
{
    "middleName" = "Hatice"
    "name" = "John"
    "surname" = "Appleseed"
}
```

#### TestDataModel.h
```objective-c
#import <MBJSONMapper/MBJSONSerializable.h>

@interface TestDataModel : NSObject <MBJSONSerializable>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *middleName;
@property (nonatomic, copy, readonly) NSString *surname;

@end
```

#### TestDataModel.m

```objective-c
@implementation TestDataModel
// Nothing!
@end
```

### Advanced usage

#### JSON

```javascript
{
    "isItTrue" = 1
    "middleName" = "Hatice"
    "name" = "John"
    "surname" = "Appleseed"
    "nestedModel" =     {
        "middleName" = ""
        "name" = "Nested"
        "surname" = "John"
    }
    "nestedModels" =     (
                {
            "middleName" = "1"
            "name" = "John"
            "surname" = "Dupont"
        },
                {
            "middleName" = "2"
            "name" = "John"
            "surname" = "Dupont"
        },
                {
            "middleName" = "3"
            "name" = "John"
            "surname" = "Dupont"
        }
    )
}
```

#### TestDataModel.h
```objective-c
#import <MBJSONMapper/MBJSONSerializable.h>

@interface TestDataModel : NSObject <MBJSONSerializable>

@property (nonatomic, readonly) BOOL isItTrue;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *surname;
@property (nonatomic, copy, readonly) NSString *secondName;

@property (nonatomic, copy, readonly) NSString *nestedModelName;

@property (nonatomic, copy, readonly) TestDataModel *nestedModel;
@property (nonatomic, copy, readonly) NSArray<TestDataModel*> *nestedModels;

@end
```

#### TestDataModel.m

```objective-c
@implementation TestDataModel

- (NSDictionary<NSString*, NSString*> *)keyPropertyMappingDictionary {
    return @{@"nestedModel.name": NSStringFromSelector(@selector(nestedModelName)),
             @"middleName":  NSStringFromSelector(@selector(secondName))};
}

- (NSDictionary<NSString*, Class> *)keyClassMappingDictionary {
    return @{NSStringFromSelector(@selector(nestedModel)): [TestDataModel class],
             NSStringFromSelector(@selector(nestedModels)): [TestDataModel class]};
}

@end
```

That's all folks!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MBJSONMapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MBJSONMapper"
```

## Author

Mert Buran, buranmert@gmail.com

## License

MBJSONMapper is available under the MIT license. See the LICENSE file for more info.
