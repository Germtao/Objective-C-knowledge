# Runtime相关

## 对象、类对象、元类对象

- 类对象：存储实例方法列表等信息
- 元类对象：存储类方法列表等信息

之间的联系，如下图所示：

![联系](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/Objcect.png)

--- 

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

---

## 消息转发

流程图：

![消息转发流程图](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%B5%81%E7%A8%8B.png)

---

## Method-Swizzling

![Method-Swizzling](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/Method-Swizzling.png)

--- 

## 动态添加方法

> 问题: 是否用过 `performSelector:`？

主要是为了考察`runtime`动态添加方法.

```
void testIMP(void) {
    NSLog(@"test invoke...");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    // 如果调用的是test方法，打印日志
    if (sel == @selector(test)) {
        NSLog(@"%@ - resolveInstanceMethod:", NSStringFromClass([self class]));
        
        //  动态添加test方法的实现
        class_addMethod(self, @selector(test), testIMP, "v@:");
        
        return YES;
    } else {
        return [super resolveInstanceMethod:sel];
    }
}
```

---

## 动态方法解析

- @dynamic

   - 动态运行时语言将函数决议推迟到运行时
   - 编译时语言在编译期进行函数决议
 

# 最后：Runtime实战问题

1. `[obj foo]` 和 `objc_msgSend()`函数之间有什么关系？

> `[obj foo] --编译期之后--> objc_msgSend(obj, @selector(foo))`

2. `runtime` 如何通过 `Selector` 找到对应的 `IMP` 地址的？

> 先在`方法缓存`中查找对应selector的IMP， 如YES返回；如NO再从当前类中查找，如YES返回；如NO再从父类逐级查找。

3. 能否向`编译后`的类中增加实例变量？

> 不能，编译后的类已经完成了实例变量的布局。

4. 能否向`动态添加`的类中增加实例变量？

> 能，动态添加的类只要在它的注册类对方法之前去完成实例变量的添加。

