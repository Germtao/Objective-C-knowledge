# Objective-C 语言特性

- [分类(Category)](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/README.md#%E4%B8%80%E5%88%86%E7%B1%BB)
- [扩展(Extension)](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/README.md#%E4%BA%8C%E6%89%A9%E5%B1%95)
- [代理(Delegate)](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/README.md#%E4%B8%89delegate)
- 通知(NSNotification)
- KVO(key-value observing)
- KVC(key-value coding)
- 属性关键字

---

### 一、分类

#### 1. 分类的作用？

- 声明私有方法
- 分解体积大的类文件
- 把`framework`的私有方法分开

#### 2. 分类的特点

- 运行时决议，可以为系统类添加分类

在运行时，将`Category`中的`实例方法列表`、`协议列表`、`属性列表`添加到主类中后（所以Category中的方法在方法列表中的位置是在主类的同名方法之前的）；然后，会递归调用所有类的`load`方法，这一切都是在`main`函数之前执行的。

#### 3. 分类可以添加哪些内容？

- 实例方法
- 类方法
- 协议
- 属性：添加`getter`和`setter`方法，并没有实例变量，*添加实例变量需要用关联对象*

#### 4. 如果工程里有两个分类`A`和`B`，两个分类中有一个同名的方法，哪个方法最终生效？

取决于分类的编译顺序，最后编译的那个分类的同名方法最终生效，而之前的都会被覆盖掉。

这里并不是真正的覆盖，因为其余方法仍然存在，只是访问不到，因为在动态添加类的方法的时候是倒序遍历方法列表的，而最后编译的分类的方法会放在方法列表前面，访问的时候就会先被访问到，同理如果声明了一个和原类方法同名的方法，也会覆盖掉原类的方法。

#### 5. 如果声明了两个同名的分类会怎样？

会**报错**，所以第三方的分类，一般都带有命名前缀

#### 6. 分类能添加成员变量吗？

不能。

只能通过关联对象(`objc_setAssociatedObject`)来模拟实现成员变量，但其实质是关联内容，所有对象的关联内容都放在`同一个全局容器`哈希表中:`AssociationsHashMap`，由`AssociationsManager`统一管理。

- `id objc_getAssociatedObject(id object, const void *key)`
- `void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)`
- `void objc_removAssociatedObjects(id object)`

--- 

## 二、扩展

#### 1. 扩展的作用

- 声明私有属性
- 声明方法（没什么意义）
- 声明私有成员变量

#### 2. 扩展的特点

- 编译时决议，只能以声明的形式存在，多数情况下寄生在宿主类的`.m`中，不能为系统类添加扩展。

---

## 三、Delegate

![Delegate流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/img/Delegate.png)

- 代理是一种设计模式，以`@protocol`形式体现，一般是**一对一传递**。
- 一般以`weak`关键词以规避**循环引用**。

--- 

## 四、NSNotification

- 使用观察者模式来实现的用于跨层传递信息的机制。传递方式是**一对多**的。

> 如果实现通知机制？

![实现机制](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/img/NSNotification.png)

---

# KVO（Key-value observing）

- 观察者模式的另一实现
- 使用了`isa`混写(`isa-swizzling`)来实现KVO

![KVO实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/Objective-C%E8%AF%AD%E8%A8%80%E7%89%B9%E6%80%A7/img/KVO.png)

#### 如何触发？

- 使用`setter`方法改变值，`KVO`才会生效
- 使用`setValue:forKey:`改变值，`KVO`才会生效
- 成员变量直接修改需手动添加`KVO`才会生效

> 那么通过直接赋值成员变量会触发`KVO`吗？

不会，因为不会调用`setter`方法，需要加上`willChangeValueForKey`和`didChangeValueForKey`方法来手动触发才行。

```
// NSKVONotifying_A 的setter实现
- (void)setValue:(id)obj {
    [self willChangeValueForKey:@"keyPath"];
    // 调用父类实现, 也即原类的实现
    [super setValue:obj];
    [self didChangeValueForKey:@"keyPath"];
}

```
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
