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













