# HTTP

- 超文本传输协议

    - 请求/响应报文
    - 连接建立流程
    - HTTP的特点

## 一、请求、响应报文

- **请求报文**
- **响应报文**

### 1.1、请求报文

- `1` - 请求行
- `2、3` - 首部行
- `4` - 空行
- `5` - 实体主体

![请求报文](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E8%AF%B7%E6%B1%82%E6%8A%A5%E6%96%87.png)

**如下**：

```
POST /somedir/page.html HTTP/1.1    
// 以上是请求行: 方法字段、URL字段和HTTP版本字段
Host: www.user.com
Content-Type: application/x-www-form-urlencoded
Connection: Keep-Alive
User-agent: Mozilla/5.0.    
Accept-lauguage: fr  
// 以上是首部行
（此处必须有一空行）  // 空行分割header和请求内容 
name=world   请求体
```

- `Host`：指明了该对象所在的主机
- `Connection`：`Keep-Alive`首部行用来表明该浏览器告诉服务器使用持续连接
- `Content-Type`：`x-www-form-urlencoded`首部行用来表明`HTTP`会将请求参数用`key1=val1&key2=val2`的方式进行组织，并放到请求实体里面
- `User-agent`：首部行用来指明用户代理，即向服务器发送请求的浏览器类型
- `Accept-lauguage`：首部行表示用户想得到该对象的法语版本（如果服务器中有这样的对象的话），否则，服务器应发送它的默认版本

### 1.2、响应报文

- `1` - 状态行
- `2、3` - 首部行
- `4` - 空行
- `5` - 实体主体

```
HTTP/1.1 200 OK    
// 以上是状态行：协议版本字段、状态码、相应状态信息
Connection: close
Server: Apache/2.2.3(CentOS)
Date: Sat, 31 Dec 2005 23:59:59 GMT
Content-Type: text/html
Content-Length: 122
// 以上是首部行
（此处必须有一空行）  // 空行分割header和实体主体
(data data data data)// 响应实体主体
```

- `Connection`：`close`首部行告诉客户，发送完报文后将关闭TCP连接。
- `Date`：指的不是对象创建或最后修改的时间，而是服务器从文件系统中检索到该对象，插入到响应报文，并发送该响应报文的时间。
- `Server`：首部行指示该报文是由一台`Apache Web`服务器产生的，类似于`HTTP`请求报文里的`User-agent`。
- `Content-Length`：首部行指示了被发送对象中的字节数。
- `Content-Type`：首部行指示了实体体中的对象是`HTML`文本。

**状态码及其相应的短语指示了请求的结果。**

一些常见的状态码和对应的短语：

- **200 OK**：请求成功，信息在返回的响应报文中
- **301 Moved Permanently**：请求的对象已经被永久转移了，新的`URL`定义在响应报文中的`Location`：首部行中。客户软件将自动获取新的URL
- **400 Bad Request**：一个通用差错代码，指示该请求不能被服务器理解
- **404 Not Found**：被请求的文件不在服务器上
- **505 HTTP Version Not Supported**：服务器不支持请求报文使用的HTTP协议版本
-  `4`开头的状态码通常是客户端的问题，`5`开头的则通常是服务端的问题

![响应报文](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E5%93%8D%E5%BA%94%E6%8A%A5%E6%96%87.png)

---

## 二、连接建立流程

### 2.1、三次握手、四次挥手

![连接建立流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E5%BB%BA%E7%AB%8B%E8%BF%9E%E6%8E%A5%E6%B5%81%E7%A8%8B.png)

### 2.2、请求方式

- GET
- POST
- PUT
- DELETE
- HEAD
- OPTIONS

#### 2.2.1、GET和POST方式的区别

从两个角度来看：

- **语法**

    - `GET`的请求参数一般以`?`分割拼接到`URL`后面，`POST`请求参数在`Body`里面。
    - `GET`参数长度限制为`2048`个字符，`POST`一般是**没限制的**。
    - `GET`请求由于参数裸露在URL中是**不安全的**，`POST`请求则是**相对安全**。
    
- **语义**

    - `GET`：获取资源是`安全的`、`幂等的(只读的，纯粹的)`、`可缓存的`。
    
        - `安全的`：是指不会引起`Server端`的任何状态变化。（`HEAD`、`OPTIONS`也是安全的）
        - `幂等的`：同一个请求方法执行多次和执行一次的效果完全相同。
        - `可缓存的`：请求会主动进行缓存。（`HEAD`也是）
    
    - `POST`：获取资源是`非安全的`、`非幂等的`、`不可缓存的`。
    
        - `非安全的`：是可能会引起服务器状态变化的。
        - `非幂等的`：同一个请求方法执行多次和执行一次的效果可能不相同。
        - `不可缓存的`：请求不会主动进行缓存。
        
**`GET`和`POST`本质上就是`TCP`链接，并无差别。但是由于HTTP的规定和浏览器/服务器的限制，导致他们在应用过程中体现出一些不同。**

- 在响应时，GET产生一个TCP数据包；POST产生两个TCP数据包。
- 对于GET方式的请求，浏览器会把Header和实体主体一并发送出去，服务器响应200（返回数据）。
- 而对于POST，浏览器先发送Header，服务器响应100 Continue，浏览器再发送实体主体，服务器响应200 OK（返回数据）。

#### 2.2.2、GET相对POST的优势是什么？

1. 最大的优势就是方便。GET 的URL可以直接手输，从而GET请求中的URL可以被存在书签里，或者历史记录里。
2. 可以被缓存，大大减轻服务器的负担。

---

## 三、HTTP的特点

- 无连接
- 无状态

### 3.1、无连接
  
- HTTP的持久连接：每个连接可以处理多个请求-响应事务。  

    - `Connection`: keep-alive
    - `time`: 20
    - `max`: 10
    
![持久连接](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E6%8C%81%E4%B9%85%E8%BF%9E%E6%8E%A5.png)
  
- 怎样判断一个请求是否结束？
  
    - `Content-length`：1024
  
    - `chunked`：最后会有一个空的chunked
  
- Charles抓包原理是怎样的？
  
    - 中间人（代理服务器）攻击
  
![Charles抓包原理](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/Charles%E6%8A%93%E5%8C%85%E5%8E%9F%E7%90%86.png)
    
### 3.2、无状态
  
- Cookie / Session：即协议对于事务处理没有记忆能力。
      
---

## 四、HTTPS与网络安全

### 4.1、HTTPS和HTTP有怎样的区别？
  
> HTTPS = HTTP + SSL/TLS

- `SSL`：全称是`Secure Sockets Layer`，即**安全套接层协议**，是为网络通信提供安全及数据完整性的一种安全协议。
- `TLS`：全称是`Transport Layer Security`，即**安全传输层协议**。

![HTTPS与网络安全](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/HTTPS%E4%B8%8E%E7%BD%91%E7%BB%9C%E5%AE%89%E5%85%A8.png)

### 4.2、会话秘钥

> 会话秘钥 = random S + random C + 预主秘钥

### 4.3、加密手段？

- 非对称加密：连接建立过程使用, 很耗时。

![非对称加密](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E9%9D%9E%E5%AF%B9%E7%A7%B0%E5%8A%A0%E5%AF%86.png)

- 对称加密：后续通信过程使用。

![对称加密](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/HTTP/imgs/%E5%AF%B9%E7%A7%B0%E5%8A%A0%E5%AF%86.png)
