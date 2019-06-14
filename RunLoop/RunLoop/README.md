# RunLoop

- [概念](https://github.com/Germtao/Objective-C-knowledge/tree/master/RunLoop/RunLoop#%E6%A6%82%E5%BF%B5)
- 数据结构
- 事件循环机制
- RunLoop与NSTimer
- RunLoop与多线程

## 概念

通过内部维护的`事件循环`来对`事件/消息进行管理`的一个对象。

> **事件循环**是什么呢？

- 没有消息需要处理时, 休眠以避免资源占用

![1](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/用户态-内核态.png)

- 有消息需要处理时, 立刻被唤醒

![2](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/%E5%86%85%E6%A0%B8%E6%80%81-%E7%94%A8%E6%88%B7%E6%80%81.png)

> 总结：状态切换

![3](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/RunLoop%E6%A6%82%E5%BF%B5%E6%80%BB%E7%BB%93.png)

--- 

## 数据结构

`NSRunLoop`是`CFRunLoop`的封装, 提供了面向对象的API.

- `CFRunLoop`

![CFRunLoop](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/CFRunLoop.png)

- `CFRunLoopMode`

![CFRunLoopMode](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/CFRunLoopMode.png)

- `Source/Timer/Observer`

![Source/Timer/Observer](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/Source:Timer:Observer.png)

> **各个数据结构之间的关系？**

`n/m`：*代表多*

![数据结构关系](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B9%8B%E9%97%B4%E7%9A%84%E5%85%B3%E7%B3%BB.png)

> **RunLoop的Mode**

*`RunLoop`的各个`Mode`数据不共享*

![RunLoop的Mode](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/RunLoop%E7%9A%84Mode.png)

> **CommonMode 的特殊性** - *Timer同时加入两个Mode中*

NSRunLoopCommonModes

  - `CommonMode`不是实际存在的一种Mode
  
  - 是同步`Source/Timer/Observer`到多个Mode中的一种**技术方案**
  
  
















