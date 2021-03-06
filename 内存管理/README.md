# 内存管理

## 内存布局

![内存布局](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%86%85%E5%AD%98%E5%B8%83%E5%B1%80.png)

- `stack(栈)`: 方法调用
- `heap(堆)`: 通过`alloc`等分配的对象
- `bss`: 未初始化的全局变量等
- `data`: 已初始化的全局变量等
- `text`: 程序代码

---

## 内存管理方案

系统针对不同的系统所提供的方案：

- `TaggedPointer`：针对一些小对象，如`NSNumber`等
- `NONPOINTER_ISA`：64位下的iOS应用
- `散列表`：其中包括了`引用计数表`和`弱引用表`

#### 散列表

- `Side Tables()结构`
![Side Tables()结构](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/SideTables()%E7%BB%93%E6%9E%84.png)
   
- `Side Table结构`
![Side Table结构](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/Side%20Table%E7%BB%93%E6%9E%84.png)

1. 自旋锁（Spinlock_t）
   - 是`忙等`的锁
   - 适用于轻量访问
   
2. 引用计数表（RefcountMap）- 理论上是Hash表

![引用计数表](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BC%95%E7%94%A8%E8%AE%A1%E6%95%B0%E8%A1%A8.png)
`size_t`:

![size_t](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/size_t.png)

3. 弱引用表

![弱引用表](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BC%B1%E5%BC%95%E7%94%A8%E8%A1%A8.png)
   
> *问题1：

![问题1](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E9%97%AE%E9%A2%981.png)

> *解决访问效率的方案：

![解决访问效率的方案](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%A7%A3%E5%86%B3%E8%AE%BF%E9%97%AE%E6%95%88%E7%8E%87%E7%9A%84%E6%96%B9%E6%A1%88.png)

#### 怎样快速实现分流？

![怎么快速实现分流?](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BF%AB%E9%80%9F%E5%AE%9E%E7%8E%B0%E5%88%86%E6%B5%81.png)

- `Hash`查找：提高查询效率

![Hash查找](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/Hash%E6%9F%A5%E6%89%BE.png)

---

## MRC - 手动引用计数

- alloc：实现**经过一系列调用，最终调用了C函数`calloc`。此时并没有设置`retainCount`为`1`。**
- `retain`：经过两次Hash查找，再+1
```
   // 实现：
   SideTable& table = SideTables()[this];
   size_t& refcntStorage = table.refcnts[this];
   // 引用计数+1操作
   refcntStorage += SIDE_TABLE_RC_ONE;
```
- `release`：
```
   // 实现：
   SideTable& table = SideTables()[this];
   RefcountMap::iterator it = table.refcnts.find(this);
   it->second -= SIDE_TABLE_RC_ONE;
```
- `retainCount`
```
   // 实现：
   SideTable& table = SideTables()[this];
   size_t& refcnt_result = 1;
   RefcountMap::iterator it = table.refcnts.find(this);
   refcnt_result += it->second >> SIDE_TABLE_RC_SHIFT;
```
- `autorelease`
- dealloc

**dealloc实现流程：**

![dealloc实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/dealloc.png)

   - `object_dispose()`内部实现
   
   ![object_dispose()内部实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/object_dispose()%E5%86%85%E9%83%A8%E5%AE%9E%E7%8E%B0.png)
   
   - `objc_destructInstance()`内部实现
   
   ![objc_destructInstance()内部实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/objc_destructInstance()%E5%86%85%E9%83%A8%E5%AE%9E%E7%8E%B0.png)
   
   - `clearDeallocating()`内部实现
   
   ![clearDeallocating()内部实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/clearDeallocating()%E5%86%85%E9%83%A8%E5%AE%9E%E7%8E%B0.png)

## ARC - 自动引用计数

- 是`LLVM（编译器）`和`RunTime`协作的结果
- 禁止手动调用`retain/release/retainCount/dealloc`
- 新增`weak`、`strong`属性关键字

#### 弱引用管理

![弱引用管理](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BC%B1%E5%BC%95%E7%94%A8%E7%AE%A1%E7%90%86.png)

![弱引用管理实现](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BC%B1%E5%BC%95%E7%94%A8%E7%AE%A1%E7%90%86%E5%AE%9E%E7%8E%B0.png)

> 如何添加weak对象到弱引用表？ 回答：可以通过弱引用对象进行Hash算法的计算来查找获取它的位置

---

## AutoreleasePool - 自动释放池

**问题：**
> - 实现原理是怎样的？
  答：在当次`runloop`将要结束时，调用`AutoreleasePoolPage::pop()`释放对象。
> - 为何可以嵌套使用？
  答：多层嵌套就是多次插入哨兵对象。
> - 什么场景需要手动插入？
  答：在`for`循环中，`alloc`图片数据等内存消耗较大的场景，需要手动插入`autoreleasePool`。


- `@autoreleasepool{}`

![autoreleasePool](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/autoreleasePool.png)

- `objc_autoreleasePush`

![objc_autoreleasePush](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/autoreleasePoolPush.png)

- `objc_autoreleasePop`

![objc_autoreleasePop](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/autoreleasePoolPop.png)

### 1. 数据结构

- 以`栈`为结点通过`双向链表`的形式组合而成 
- 和线程一一对应的

**双向链表**

![双向链表](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/%E5%8F%8C%E5%90%91%E9%93%BE%E8%A1%A8.png)

**AutoreleasePoolPage**

![AutoreleasePoolPage](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/autoreleasePoolPage.png)

**[obj autorelease]内部实现**

![[obj autorelease]内部实现流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E8%87%AA%E5%8A%A8%E9%87%8A%E6%94%BE%E6%B1%A0/%5Bobj%20autorelease%5D%20%E5%86%85%E9%83%A8%E5%AE%9E%E7%8E%B0.png)

**`AutoreleasePoolPage::pop`**

- 根据传入的哨兵对象找到对应位置
- 给上次`push`操作之后添加的对象依次发送`release`消息
- 回退`next`指针到正确的位置

---

## 循环引用

### 类别

- 自循环引用

![自循环引用](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/%E8%87%AA%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8.png)

- 相互循环引用

![相互循环引用](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/%E7%9B%B8%E4%BA%92%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8.png)

- 多循环引用

![多循环引用](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/%E5%A4%9A%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8.png)

### 考点

- 代理
- `Block`
- `NSTimer`
- 大环引用

### 如何破除循环引用？

- 避免产生循环引用
- 在合适的时机手动断环

### 具体的解决方案有哪些？

- `__weak`

![__weak方案](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/__weak%E6%96%B9%E6%A1%88.png)

- `__block`

  - `MRC`中，`__block`修饰对象不会增加其`retainCount（引用计数）`，避免了循环引用。
  - `ARC`中，`__block`修饰对象会被强引用，无法避免循环引用，需手动断环。

- `__unsafe_unretained` - 不推荐使用

  - 修饰对象不会增加其引用计数，避免了循环引用。
  - 如果被修饰对象在某一时机被释放，会产生`悬垂指针`！

### 循环引用示例

- `NSTimer`的循环引用示例

![NSTimer循环引用解决方案](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/NSTimer%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88.png)

[NSTimer循环引用解决方案](https://github.com/Germtao/Objective-C-knowledge/tree/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%BE%AA%E7%8E%AF%E5%BC%95%E7%94%A8/NSTimerDemo)








