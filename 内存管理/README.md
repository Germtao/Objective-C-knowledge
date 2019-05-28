# 内存管理

## 内存布局

![内存布局](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86/%E5%86%85%E5%AD%98%E5%B8%83%E5%B1%80.png)

- `stack(栈)`: 方法调用
- `heap(堆)`: 通过`alloc`等分配的对象
- `bss`: 未初始化的全局变量等
- `data`: 已初始化的全局变量等
- `text`: 程序代码
