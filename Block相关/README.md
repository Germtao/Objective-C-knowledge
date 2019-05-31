# Block相关

- `Block`介绍
- 截获变量
- `__block`修饰符
- `Block`的内存管理
- `Block`的循环引用

## Block介绍

- `Block`是将`函数`及其执行`上下文`封装起来的`对象`

![Block的本质](https://github.com/Germtao/Objective-C-knowledge/blob/master/Block%E7%9B%B8%E5%85%B3/Block%E7%9A%84%E6%9C%AC%E8%B4%A8.png)

```
{    
    int multiplier = 6;
    int(^Block)(int) = ^int(int num) {
        return num * multiplier;
    };

    Block(2);
}
```

### Block的本质

> 源码解析：【`clang -rewrite-objc file.m`】查看编译之后的文件内容

```
static void _I_MyBlock_method(MyBlock * self, SEL _cmd) {

    int multiplier = 6;
    
    /**
     int(^Block)(int) = ^int(int num) {
         return num * multiplier;
     };
     */
    int(*Block)(int) = ((int (*)(int))&__MyBlock__method_block_impl_0((void *)__MyBlock__method_block_func_0, &__MyBlock__method_block_desc_0_DATA, multiplier));
    
    /**
     Block(2);
     */
    ((int (*)(__block_impl *, int))((__block_impl *)Block)->FuncPtr)((__block_impl *)Block, 2);
}
```

- `__MyBlock__method_block_impl_0`结构体

```
struct __MyBlock__method_block_impl_0 {
  struct __block_impl impl;
  struct __MyBlock__method_block_desc_0* Desc;
  int multiplier;
  __MyBlock__method_block_impl_0(void *fp, struct __MyBlock__method_block_desc_0 *desc, int _multiplier, int flags=0) : multiplier(_multiplier) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

- `__MyBlock__method_block_func_0`结构体

```
static int __MyBlock__method_block_func_0(struct __MyBlock__method_block_impl_0 *__cself, int num) {
  int multiplier = __cself->multiplier; // bound by copy

        return num * multiplier;
    }
```

- `__block_impl`结构体

```
struct __block_impl {
  void *isa; // isa指针, Block是对象的标志
  int Flags;
  int Reserved;
  void *FuncPtr; // 函数指针
};
```

---

## 截获变量

```
{
    int multiplier = 6;
    int(^Block)(int) = ^int(int num) {
        return num * multiplier;
    };
    multiplier = 4;
    NSLog(@"result is %d", Block(2));
}

/**
结果：result is 12

如果实静态局部变量(static int multiplier = 6), rusult is 8
*/
```

- 局部变量
  - 基本数据类型 - `截获其值`
  - 对象类型 - `连同所有权修饰符`一起截获
- 静态局部变量
  - 以`指针形式`截获
- 全局变量 & 静态全局变量
  - 不截获

### 源码解析

- 使用`【clang -rewrite-objc -fobjc-arc file.m】`命令获取编译后代码。

### __block修饰符

- 一般情况下，对被截获变量进行`赋值`操作需要添加`__block修饰符`。

![__block修饰符](https://github.com/Germtao/Objective-C-knowledge/blob/master/Block%E7%9B%B8%E5%85%B3/__block%E4%BF%AE%E9%A5%B0%E7%AC%A61.png)

> 对变量进行赋值时，是否需要`__block修饰符`？

- 需要：
   - 局部变量
     - 基本数据类型
     - 对象类型
     
- 不需要：
   - 静态局部变量
   - 全局变量
   - 静态全局变量
   
> `__block修饰符`一般面试题？

```
{
    __block int multiplier = 6;
    int(^Block)(int) = ^int(int num) {
        return num * multiplier;
    };
    multiplier = 4;
    NSLog(@"result is %d", Block(2));
}

/**
结果：result is 8
*/
```
   
- `__block`修饰的变量变成了`对象`

`__block int multiplier = 6;`编译成下方结构体

```
struct _Block_byref_multiplier_0 {
    void *_isa;
    __Block_byref_multiplier_0 *__forwarding;
    int __flags;
    int __size;
    int multiplier;
}
```
![__block修饰符](https://github.com/Germtao/Objective-C-knowledge/blob/master/Block%E7%9B%B8%E5%85%B3/__block%E4%BF%AE%E9%A5%B0%E7%AC%A62.png)

--- 



