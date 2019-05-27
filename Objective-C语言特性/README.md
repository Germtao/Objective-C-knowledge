# 关联对象

> 问题：能否给分类添加“成员变量”？ 能，通过关联对象添加。

`id objc_getAssociatedObject(id object, const void *key)`
`void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)`
`void objc_removAssociatedObjects(id object)`

### 本质

关联对象由`AssociationsManager`管理并在`AssociationsHashMap`存储。
所有对象的关联内容都在`同一个全局容器`中。

--- 

# KVO

重写的Setter添加的方法

- `- (void)willChangeValueForKey:(NSString *)key;`
- `- (void)didChangeValueForKey:(NSString *)key;`

```
// NSKVONotifying_A 的setter实现
- (void)setValue:(id)obj {
    [self willChangeValueForKey:@"keyPath"];
    // 调用父类实现, 也即原类的实现
    [super setValue:obj];
    [self didChangeValueForKey:@"keyPath"];
}

```

### 如何触发？

- 使用`setter`方法改变值，`KVO`才会生效
- 使用`etValue:forKey:`改变值，`KVO`才会生效
- 成员变量直接修改需手动添加`KVO`才会生效

--- 

# 修饰关键字

### copy关键字

源对象类型|拷贝方式|目标对象类型|拷贝类型(深/浅)
:---:|:---:|:---:|:---:
mutable对象|copy|不可变|深拷贝
mutable对象|mutableCopy|可变|深拷贝
immutable对象|copy|不可变|浅拷贝
immutable对象|mutableCopy|可变|深拷贝

> 总结：

- 可变对象的`copy`和`mutableCopy`都是深拷贝
- 不可变对象的`copy`是浅拷贝，`mutableCopy`是深拷贝
- `copy`方法返回的都是不可变对象

> 问题: `@property (copy) NSMutableArray *array;`会产生什么问题？

- 如果赋值过来的是`NSMutableArray`或者`NSArray`，`copy`之后都是`NSArray`

---

# 最后：Objective-C语言笔试题

1. `MRC`下如何重写`retain`修饰变量的`setter`方法？

```
@property (nonatomic, retain) id obj;

- (void)setObj:(id)obj {
    if (_obj != obj) { // 主要为了预防一些异常的处理
        [_obj release];
        _obj = [obj retain];
    }
}
```
