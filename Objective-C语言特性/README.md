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
