# UDP

- 概念
- 特点
- 报文结构


## 一、概念

`User Datagram Protocol`用户数据报协议，传输层协议。

`UDP`是是面向非连接的协议，传送数据不需要和服务器连接，只需要知道**ip**和**监听端口**，不需要链接没有目的的socket，只是将数据报投递出去，不管接收方是否成功接收到，是一种**不可靠**的传输。

---

## 二、特点

- 关于何时、发送什么数据的应用层控制更加精细。
- 无需连接建立
- 无连接状态
- 分组首部开销小

### 2.1、关于何时、发送什么数据的应用层控制更加精细

- 只要应用将数据传递给`UDP`，`UDP`就会将此数据打包进`UDP`**报文段**并立刻将其传递给网络层。
- 而`TCP`则是有个拥塞控制机制，以确保数据能够安全传输，而不管可靠传输成功需要用多少时间。
- 所以有些实时应用，比如微信视频、语音都是更希望数据能够及时发送，为此可以容忍一部分数据丢失，比较适合用UDP。

### 2.2、无需连接建立

- 众所周知，`TCP`在数据传输前需要经过**三次握手**，`UDP`却不需要做任何的准备即可进行数据传输，因此UDP不会引入建立连接的时延。
- 这也是`DNS`运行在`UDP`而不是TCP上的主要原因。
- 而HTTP协议之所以使用TCP，是因为对于HTTP协议来说，可靠性是至关重要的。

### 2.3、无连接状态

- TCP需要维护连接状态。此连接状态包括接收和发送缓存、拥塞控制参数以及序号与确认号的参数。
- `UDP`不需要维护连接状态，也不用跟踪这些参数。

### 2.4、分组首部开销小

每个TCP报文段都有20字节的首部开销，而`UDP`仅有`8`字节的开销。

所以，如非必要，比如电子邮件，远程终端服务，web，以及文件传输，需要可靠地数据传输，会去采用TCP。其余的尤其是对实时性要求高的应用，比如实时视频会议，网络电话，一般都会选用`UDP`。

## 三、报文结构

![UDP报文结构](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/UDP/imgs/%E6%8A%A5%E6%96%87%E7%BB%93%E6%9E%84.png)

**应用层**数据占用`UDP`报文段的数据字段。`UDP`首部只有4个字段，每个字段由2个字节组成，即**UDP首部仅有8字节**。

- **端口号**：可以使目的主机将应用数据交给运行在目的端系统中端相应进程，执行分用功能。

![端口号复用和分用](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/UDP/imgs/%E5%A4%8D%E7%94%A8%E5%88%86%E7%94%A8.png)

- **长度**：该字段指示了在UDP报文段中的字节数（首部+数据）。

- **检验和**：接收方使用检验和来检查在该报文段中是否出现了差错，即**差错检测**。

---

## 四、差错检测

![差错检测](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/UDP/imgs/%E5%B7%AE%E9%94%99%E6%A3%80%E6%B5%8B.png)

- **UDP检验和**提供了**差错检测**功能。

- **校验和**：相当于用于确定当UDP报文段从源到达目的地移动时，其中的比特是否发生了改变（比如，由于链路中的噪声干扰或存储在路由器中时的引入问题）。

- 发送方的UDP对报文段中的所有16比特字对和进行**反码**运算，求和时遇到的任何溢出都被回卷。得到的结果被放在UDP报文段中的检验和字段。

比如，假定有下面三个16比特的字:

```
0110011001100000
0101010101010101
1000111100001100
```

1. 这些16比特字的前两个之和是：

```
1011101110110101
```

2. 再将该和与第三个16比特字相加，得出:

```
10100101011000001
```

3. 发现溢出了，该和就要被回卷，即把首位的1加到最后一位去，得出：

```
0100101011000010
```

4. 然后对其进行反码运算，所谓反码运算，即是将所有的1换成0，0换成1:

```
1011010100111101
```

这就是得出的检验和。而在接收方，全部的4个16比特字（包括检验和）加在一起。如果分组中没有引入差错，显然在接收处该和将是1111111111111111。而如果这些比特之一是0，那我们就知道该分组中出现了差错。

UDP在**端到端**基础上在运输层提供差错检测，这就是在系统设计中被称颂的**端到端原则**。

而UDP虽然提供差错检测，但它对差错恢复无能为力（这就需要用到可靠数据传输TCP了）。

---

## 五、一个基于UDP的简单的聊天Demo

三种方式来实现UDP通信：

- C语言
- Python
- GCDAsyncUdpSocket

### 5.1、C语言方式

- 首先，初始化`socket`对象，UDP要用`SOCK_DGRAM`。

- 其次，初始化`sockaddr_in`网络通信对象，如果作为服务端要绑定`socket`对象与通信链接，来接收消息。

- 再之，开启一个循环，循环调用`recvfrom`来接收消息。

- 最后，收到消息后，保存下发消息对象的地址，以便之后回复消息。

```
- (void)initCSocket {
    char receiveBuffer[1024];
    __uint32_t nSize = sizeof(struct sockaddr);
   
    if ((_listenfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("socket() error. Failed to initiate a socket");
    }
    
    bzero(&_addr, sizeof(_addr));
    _addr.sin_family = AF_INET;
    _addr.sin_port = htons(_destPort);
    
    if(bind(_listenfd, (struct sockaddr *)&_addr, sizeof(_addr)) == -1) {
        perror("Bind() error.");
    }
    
    _addr.sin_addr.s_addr = inet_addr([_destHost UTF8String]); // ip可是是本服务器的ip，也可以用宏INADDR_ANY代替，代表0.0.0.0，表明所有地址
   
    while(true) {
        long strLen = recvfrom(_listenfd, receiveBuffer, sizeof(receiveBuffer), 0, (struct sockaddr *)&_addr, &nSize);
        NSString * message = [[NSString alloc] initWithBytes:receiveBuffer length:strLen encoding:NSUTF8StringEncoding];
        _destPort = ntohs(_addr.sin_port);
        _destHost = [[NSString alloc] initWithUTF8String:inet_ntoa(_addr.sin_addr)];
        NSLog(@"来自%@---%zd:%@",_destHost,_destPort,message);
    }
}
```

> 由于开启`while`循环来一直接收消息，所以为了避免阻塞主线程，这里要将`initCSocket`函数放在子线程中调用。

```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self initCSocket];
});
```

> 调用`sendto`方法来发送消息。

```
- (void)sendMessage:(NSString *)message {
    NSData *sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    sendto(_listenfd, [sendData bytes], [sendData length], 0, (struct sockaddr *)&_addr, sizeof(struct sockaddr));
}
```
---

### 5.2、Python

Python的方式就比较简单了。

1. 初始化`socket`，绑定端口

```
socket = socket(AF_INET, SOCK_DGRAM)

socket.bind(('', port))
```

2. 循环接收消息

```
while True:
    message, address = socket.recvfrom(2048)
    print address,message
```

3. 发送消息

```
socket.sendto(message, address)
```
---

### 5.3、GCDAsyncUdpSocket方式

[GCDAsyncUdpSocket地址](https://github.com/robbiehanson/CocoaAsyncSocket)

- 首先，初始化`Socket`对象。
- 其次，绑定端口，调用`beginReceiving:`方法来接收消息。

```
- (void)initGCDSocket {
    _receiveSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error;
    // 绑定一个端口(可选),如果不绑定端口, 那么就会随机产生一个随机的唯一的端口
    // 端口数字范围(1024,2^16-1)
    [_receiveSocket bindToPort:test_port error:&error];
    if (error) {
        NSLog(@"服务器绑定失败");
    }
    // 开始接收对方发来的消息
    [_receiveSocket beginReceiving:nil];
}
```

- 在代理方法里获取到对方发过来的消息，记录下主机和端口，以便之后回复消息。

```
#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _destPort = [GCDAsyncUdpSocket portFromAddress:address];
    _destHost = [GCDAsyncUdpSocket hostFromAddress:address];
    NSLog(@"来自%@---%zd:%@",_destHost,_destPort,message);
}
```

- 调用`sendData:(NSData *)data ...`方法来发送消息。

```
- (void)sendMessage:(NSString *)message {
    NSData *sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_receiveSocket sendData:sendData toHost:_destHost port:_destPort withTimeout:60 tag:500];
}
```
---

## 六、iOS端基于UDP简易聊天demo

### 6.1、利用Python实现UDP通信

- 创建两个python文件，分别作为客户端和服务端，然后同时运行。

- 客户端：

```
from socket import *
host = '127.0.0.1'
port = 12000
socket = socket(AF_INET, SOCK_DGRAM)
while True:
    message = raw_input('input message ,print 0 to close :\n')
    socket.sendto(message, (host, port))
    if message == '0':
        socket.close()
        break
    receiveMessage, serverAddress = socket.recvfrom(2048)
    print receiveMessage,serverAddress
```

- 服务端：

```
from socket import *
port = 12000
socket = socket(AF_INET, SOCK_DGRAM)
socket.bind(('', port))
print 'server is ready to receive'
count = 0
while True:
    message, address = socket.recvfrom(2048)
    print address,message
    count = count + 1
    if message == '0':
        socket.close()
        break
    else:
        message = raw_input('input message ,print 0 to close :\n')
        socket.sendto(message, address)
```

- 客户端打印：

```
/usr/local/bin/python2.7 /Users/wangyong/Desktop/other/python/UDPClient.py
input message ,print 0 to close :
hello，服务端
hello，客户端 ('10.208.61.53', 12000)
input message ,print 0 to close :
结束通信吧我们
好的 ('10.208.61.53', 12000)
input message ,print 0 to close :
0

Process finished with exit code 0
```

- 服务端打印：

```
/usr/local/bin/python2.7 /Users/wangyong/Desktop/other/python/UDPServer.py
server is ready to receive
('10.208.61.53', 53500) hello，服务端
input message ,print 0 to close :
hello，客户端
('10.208.61.53', 53500) 结束通信吧我们
input message ,print 0 to close :
好的
('10.208.61.53', 53500) 0

Process finished with exit code 0
```

### 6.2、C语言或GCDAsyncUdpSocket

1. UDPManager封装

    - `initSocketWithReceiveHandle:(dispatch_block_t)receiveHandle`：初始化`socket`相关，`receiveHandle`是接收到消息后的回调
    
