## 多线程

如果不考虑其他任何因素和技术，多线程有百害而无一利，只能浪费时间，降低程序效率。

是的，我很清醒的写下这句话。

试想一下，一个任务由十个子任务组成。现在有两种方式完成这个任务：

> 1. 建十个线程，把每个子任务放在对应的线程中执行。执行完一个线程中的任务就切换到另一个线程。
2. 把十个任务放在一个线程里，按顺序执行。

```
操作系统的基础知识：线程，是执行程序最基本的单元，它有自己的栈和寄存器。具体些，线程就是“一个CPU执行的一条无分叉的命令列”
```

> 对于第一种方法，在十个线程之间来回切换，就意味着有十组栈和寄存器中的值需要不断地被备份、替换。 而对于对于第二种方法，只有一组寄存器和栈存在，显然效率完胜前者。

### 并发 & 并行

通过刚才的分析，多线程本身会带来效率上的损失。准确来说，在处理并发任务时，多线程不仅不能提高效率，反而还会降低程序效率。

所谓的`并发（concurrent）`，要注意和`并行（parallelism）`的区别。

> `并发`指的是一种现象，一种经常出现，无可避免的现象。它描述的是`多个任务同时发生，需要被处理`这一现象。它的侧重点在于`发生`。

比如有很多人排队等待检票，这一现象就可以理解为并发。

> `并行`指的是一种技术，一个同时处理多个任务的技术。它描述了`一种能够同时处理多个任务的能力`，侧重点在于`运行`。

比如景点开放了多个检票窗口，同一时间内能服务多个游客。这种情况可以理解为并行。

并行的反义词就是`串行`，表示任务必须按顺序来，一个一个执行，前一个执行完了才能执行后一个。

> `多线程` 就是采用了 `并行` 这种技术，从而提高执行效率，因为有多个线程，所以计算机的多个CPU可以同时工作，同时处理不同线程内的指令。

### 小结

```
`并发`是一种现象，面对这一现象，我们首先创建多个线程，真正加快程序运行速度的，是`并行`技术。也就是让多个CPU同时工作。而多线程，是为了让多个CPU同时工作成为可能。
```

### 同步 & 异步

> `同步` 就是我们平时调用的哪些方法。比如在第一行调用`foo()`方法，那么程序运行到第二行的时候，foo方法肯定是执行完了。

> `异步` 就是允许在执行某一个任务时，函数立刻返回，但是真正要执行的任务稍后完成。

比如我们在点击保存按钮之后，要先把数据写到磁盘，然后更新UI。同步方法就是等到数据保存完再更新UI，而异步则是立刻从保存数据的方法返回并向后执行代码，同时真正用来保存数据的指令将在稍后执行。

#### 区别 & 联系

###### 区别

```
假设现在有三个任务需要处理。假设单个CPU处理它们分别需要3、1、1秒。

`并行`与`串行`，其实讨论的是处理这三个任务的速度问题。如果三个CPU`并行`处理，那么一共只需要3秒。相比于`串行`处理，节约了2秒。

`同步`与`异步`，其实描述的是任务之间先后顺序问题。假设需要三秒的那个是保存数据的任务，而另外两个是UI相关的任务。那么通过异步执行第一个任务，我们省去了3秒钟的卡顿时间。
```

###### 联系

```
对于`同步执行`的三个任务来说，系统`倾向于`在同一个线程里执行它们。因为即使开了三个线程，也得等他们分别在各自的线程中完成。并不能减少总的处理时间，反而徒增了线程切换。

对于`异步执行`的三个任务来说，系统`倾向于`在三个新的线程里执行他们。因为这样可以最大程度的利用CPU性能，提升程序运行效率。
```

### 小结

```
由此得出结论，在需要同时处理IO和UI的情况下，真正起作用的是异步，而不是多线程。可以不用多线程（因为处理UI非常快），但不能不用异步（否则的话至少要等IO结束）。
注意到我把“倾向于”这三个加粗了，也就是说异步方法并不一定永远在新线程里面执行，反之亦然。在接下来关于GCD的部分会对此做出解释。
```

## GCD

### 1. GCD 简介

`GCD` 以 `block` 为基本单位，一个 `block` 中的代码可以为一个任务。下文中提到任务，可以理解为执行某个 `block`。

同时，`GCD` 中有两大最重要的概念：

- 队列
- 执行方式

使用 `block` 的过程，概括来说就是把 `block` 放进合适的队列，并选择合适的执行方式去执行 `block` 的过程。

#### 队列可以分为三类：

- 串行队列：先进先出，也就是先进入队列的任务先出队列，每次只执行一个任务
- 并行队列：先进先出，但可以形成多个任务并发
- 主队列：一个特殊的串行队列，而且队列中的任务一定会在主线程中执行

#### 执行方式有一下两种基本方式：

- 同步执行
- 异步执行

关于同步异步、并行串行和线程的关系，可以由下表概括：

/Users/tao/Desktop/1.png

可以看到，同步方法不一定在本线程，异步方法方法也不一定新开线程（考虑主队列）。

然而事实上，在本文一开始就揭开了“多线程”的神秘面纱，所以在编程时，更应该考虑的是：

> 同步 or 异步

以及

> 并行 or 串行

而非仅仅考虑是否新开线程。

当然，了解任务运行在那个线程中也是为了更加深入的理解整个程序的运行情况，尤其是接下来要讨论的死锁问题。

### 2. GCD 死锁问题

在使用GCD的过程中，如果 `向当前串行队列中同步派发一个任务`，就会导致死锁。

举个🌰解释一下：

```
dispatch_queue_t mainQueue = dispatch_get_main_queue();

id block = ^{
NSLog(@"%@", [NSThread currentThread]);
};

// 向当前串行队列中同步派发一个任务, 死锁
dispatch_sync(mainQueue, block);
```

这段代码就会导致死锁，因为我们目前在主队列中，又将要同步地添加一个 `block` 到主队列(串行)中。

#### 理论分析

```
我们知道 `dispatch_sync` 表示同步的执行任务，也就是说执行 `dispatch_sync` 后，当前队列会阻塞。而`dispatch_sync` 中的block如果要在当前队列中执行，就得等待当前队列程执行完成。

在上面这个例子中，主队列在执行 `dispatch_sync`，随后队列中新增一个任务 `block`。因为主队列是同步队列，所以`block` 要等 `dispatch_sync` 执行完才能执行，但是 `dispatch_sync` 是同步派发，要等 `block` 执行完才算是结束。在主队列中的两个任务互相等待，导致了死锁。
```

#### 解决方案

```
其实在通常情况下我们不必要用 `dispatch_sync`，因为 `dispatch_async` 能够更好的利用CPU，提升程序运行速度。
只有当我们需要保证队列中的任务必须顺序执行时，才考虑使用 `dispatch_sync`。在使用 `dispatch_sync` 的时候应该分析当前处于哪个队列，以及任务会提交到哪个队列。
```

### 3. GCD 常用函数

#### dispatch_group

了解完队列之后，很自然的会有一个想法：我们怎么知道所有任务都已经执行完了呢？

在单个串行队列中，这个不是问题，因为只要把回调 `block` 添加到队列末尾即可。

但是对于并行队列，以及多个串行、并行队列混合的情况，就需要使用 `dispatch_group` 了。

```
// 创建线程组
dispatch_group_t group = dispatch_group_create();
dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

// 组异步执行
dispatch_group_async(group, serialQueue, ^{
for (int i = 0; i < 2; i++) {
NSLog(@"group-serial - %@", [NSThread currentThread]);
}
});

dispatch_group_async(group, serialQueue, ^{
for (int i = 0; i < 3; i++) {
NSLog(@"group-02-serial - %@", [NSThread currentThread]);
}
});

// 把第三个参数block传入第二个参数队列中去。
// 而且可以保证第三个参数block执行时，group中的所有任务已经全部完成
dispatch_group_notify(group, serialQueue, ^{
NSLog(@"Finished - %@", [NSThread currentThread]);
});
```

###### dispatch_group_wait

`dispatch_group_wait(group: dispatch_group_t, _ timeout: dispatch_time_t) -> Int`

第一个参数表示要等待的group，第二个则表示等待时间。返回值表示经过指定的等待时间，属于这个group的任务是否已经全部执行完，如果是则返回0，否则返回非0。

第二个 `dispatch_time_t` 类型的参数还有两个特殊值：`DISPATCH_TIME_NOW` 和 `DISPATCH_TIME_FOREVER`。


#### barrier

- 通过 `dispatch_barrier_async` 添加的block会等到之前添加所有的block执行完毕再执行
- 在 `dispatch_barrier_async` 之后添加的block会等到 `dispatch_barrier_async` 添加的block执行完毕再执行

```
- (void)barrier {
dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
dispatch_async(queue, ^{
// dosth1;
});
dispatch_async(queue, ^{
// dosth2;
});
dispatch_barrier_async(queue, ^{
// doBarrier;
});
dispatch_async(queue, ^{
// dosth4;
});
dispatch_async(queue, ^{
// dosth5;
});
}
```

#### 信号量 (dispatch_semaphore)

当我们多个线程要访问同一个资源的时候，往往会设置一个信号量，当信号量大于0的时候，新的线程可以去操作这个资源，操作时信号量-1，操作完后信号量+1，当信号量等于0的时候，必须等待，所以通过控制信号量，我们可以控制能够同时进行的并发数。

信号量有以下三个函数：

- dispatch_semaphore_create：创建一个信号量
- dispatch_semaphore_signal：信号量+1
- dispatch_semaphore_wait：等待，直到信号量大于0时，即可操作，同时将信号量-1

```
- (void)dispatchSignal {

    // value: 最多几个资源可以访问
    long value = 2;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 任务1
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");

        dispatch_semaphore_signal(semaphore);
    });

    // 任务2
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");

        dispatch_semaphore_signal(semaphore);
    });

    // 任务3
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");

        dispatch_semaphore_signal(semaphore);
    });
}
```
运行结果
```
run task 1
run task 2
complete task 1
complete task 2
run task 3
complete task 3
```

由于设定的信号值为2，先执行两个线程，等执行完一个，才会继续执行下一个，保证同一时间执行的线程数不超过2。

如果我们把信号量设置成1，`dispatch_semaphore_create(1)` 那么执行结果就会变成顺序执行

```
run task 1
complete task 1
run task 2
complete task 2
run task 3
complete task 3
```

