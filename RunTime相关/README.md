# 数据结构

## 对象、类对象、元类对象

- 类对象：存储实例方法列表等信息
- 元类对象：存储类方法列表等信息

之间的联系，如下图所示：

![联系](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/Objcect.png)

## 消息传递

#### 1. `void objc_msgSend(void /* id self, SEL op, ...*/)`

![objc_msgSend](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/1.png)

#### 2. `void objc_msgSendSuper(void /* struct objc_super *super, SEL op, ...*/)`

```
struct objc_super {
    // 指定类的实例
    __unsafe_unretained id receiver; // -> self
}

```

![objc_msgSendSuper](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/2.png)

#### 3. 消息传递流程

![消息传递流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/%E6%B6%88%E6%81%AF%E4%BC%A0%E9%80%92%E6%B5%81%E7%A8%8B.png)

1. 缓存查找 - 即哈希查找

![缓存查找](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/%E7%BC%93%E5%AD%98%E6%9F%A5%E6%89%BE.png)

2. 当前类中查找

- 对于`已排序好`的列表，采用`二分查找`算法查找方法对应执行函数
- 对于`没有排序`的列表，采用`一般遍历`查找方法对应执行函数

3. 父类逐级查找

![父类逐级查找](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/%E7%88%B6%E7%B1%BB%E9%80%90%E7%BA%A7%E6%9F%A5%E6%89%BE.png)

#### 4. 问题：

```
#import "Mobile.h"

NS_ASSUME_NONNULL_BEGIN

@interface Phone : Mobile

@end

NS_ASSUME_NONNULL_END

// 分割线

#import "Phone.h"

@implementation Phone

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"self = %@", NSStringFromClass([self class]));
        NSLog(@"super = %@", NSStringFromClass([super class]));
    }
    return self;
}

@end

/**
  结果：
        self = Phone  
        super = Phone
*/

```






