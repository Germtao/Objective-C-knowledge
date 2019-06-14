# RunLoop

- 概念
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
