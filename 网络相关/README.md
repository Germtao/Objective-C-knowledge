# 网络

- `HTTP`协议
- `HTTPS`与网络安全
- `TCP` / `UDP`
- `DNS`解析
- `Session` / `Cookie`

## HTTP

### 定义

超文本传输协议
  
  - 请求/响应报文
  - 连接建立流程
  - HTTP的特点
  
#### 1. 请求/响应报文

  请求报文
    ![请求报文](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/Resource/%E8%AF%B7%E6%B1%82%E6%8A%A5%E6%96%87.png)
  
  响应报文
    ![响应报文](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/Resource/%E5%93%8D%E5%BA%94%E6%8A%A5%E6%96%87.png)

#### 2. 连接建立流程

  三次握手、四次挥手
  
  ![连接建立流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/Resource/HTTP%E5%BB%BA%E7%AB%8B%E8%BF%9E%E6%8E%A5%E6%B5%81%E7%A8%8B.png)

#### 3. HTTP的特点

  **无连接**
  
    HTTP的持久连接
    
    头部字段  
    
      `Connection`: keep-alive
      
      `time`: 20
      
      `max`: 10
    
  ![持久连接](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/Resource/%E6%8C%81%E4%B9%85%E8%BF%9E%E6%8E%A5.png)
  
  > 怎样判断一个请求是否结束？
  
    1. `Content-length`: 1024
  
    1. `chunked`: 最后会有一个空的chunked
  
  > Charles抓包原理是怎样的？
  
    中间人（代理服务器）攻击
  
  ![Charles抓包原理](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E7%BD%91%E7%BB%9C%E7%9B%B8%E5%85%B3/Resource/Charles%E6%8A%93%E5%8C%85%E5%8E%9F%E7%90%86.png)
  
    
  **无状态**
  
    Cookie / Session

### 问题？

1. HTTP的请求方式有哪些？
    GET、POST、PUT、HEAD、DELETE、OPTIONS

2. GET和POST方式的区别？

  一般回答：
  
    - GET请求参数以`?`分割拼接到URL后面, POST请求参数在Body里面
    - GET参数长度限制2048个字符, POST一般没有限制
    - GET请求不安全, POST请求比较安全

  标准回答：
  
    1. 从语义角度:
  
    GET: 获取资源
    
      安全的: 不应该引起`Server`端的任何状态变化, 如: GET、HEAD、OPTIONS
      幂等的: 同一个请求方法执行多次和执行一次的效果完全相同
      可缓存的: 请求可以被缓存, 如: GET、HEAD
      
    POST: 处理资源
      非安全的、非幂等的、非可缓存的
      
      





