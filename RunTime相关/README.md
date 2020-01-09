# Runtime相关

- 数据结构
- 对象、类对象、元类对象
- 消息传递
- 消息转发

---

## 一、数据结构

![数据结构](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/img/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84.png)

- `objc_object`：id

    - `isa_t`：关于`isa`操作相关
    - 弱引用相关
    - 关联对象相关
    - 内存管理相关

- `objc_class`：class，继承自objc_object

    - Class superClass
    - cache_t cache
    - class_data_bits_t bits
    
- `isa`指针，共用体`isa_t`

![isa指针](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/img/isa%E6%8C%87%E9%92%88.png)

- `isa`指向

    - 关于对象，其指向类对象
    - 关于类对象，其指向元类对象

> 实例 --isa--> class --isa--> meta class  

- `cache_t`

    用于快速查找方法执行函数，是可增量扩展的哈希表结构，是局部性原理的最佳运用
    
```
struct cache_t {
    struct bucket_t *_buckets; // 一个散列表，用来方法缓存，bucket_t类型，包含key以及方法实现IMP
    mask_t _mask; // 分配用来缓存bucket的总数
    mask_t _occupied; // 表明目前实际占用的缓存bucket的个数
｝
struct bucket_t {
    private:
    cache_key_t _key;
    IMP _imp;
 ｝
```

- `class_data_bits_t`：对`class_rw_t`的封装

```
struct class_rw_t {
     uint32_t flags;
     uint32_t version;

     const class_ro_t *ro;

     method_array_t methods;
     property_array_t properties;
     protocol_array_t protocols;

     Class firstSubclass;
     Class nextSiblingClass;

     char *demangledName;
｝
```

> `class_rw_t`

- 内容

    - 类的属性
    - 类的方法
    - 类遵循的协议
    
- 作用

    - 代表了类相关的读写信息
    - 对`class_ro_t`的封装
    
        - 代表了类的只读信息
        - 存储了编译器决定的属性、方法、遵循的协议
        
```
struct class_ro_t {
  uint32_t flags;
  uint32_t instanceStart;
  uint32_t instanceSize;
  #ifdef __LP64__
  uint32_t reserved;
  #endif

  const uint8_t * ivarLayout;
  
  const char * name;
  method_list_t * baseMethodList;
  protocol_list_t * baseProtocols;
  const ivar_list_t * ivars;

  const uint8_t * weakIvarLayout;
  property_list_t *baseProperties;

  method_list_t *baseMethods() const {
      return baseMethodList;
  }
};
```

- `method_t`：函数的四要素

    - 名称
    - 返回值
    - 参数
    - 函数体
    
```
struct method_t {
  SEL name;           // 名称
  const char *types;  // 返回值和参数
  IMP imp;            // 函数体
｝
```

---

## 二、对象、类对象、元类对象

- 类对象：存储实例方法列表等信息

- 元类对象：存储类方法列表等信息

之间的联系，如下图所示：

![联系](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunTime%E7%9B%B8%E5%85%B3/Objcect.png)

`superClass`是一层层集成的，到最后`NSObject`的`superClass`是`nil`；而`NSObject`的`isa`指向根元类，这个根元类的`isa`指向它自己，而它的`superClass`是`NSObject`，也就是最后形成一个环。

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

