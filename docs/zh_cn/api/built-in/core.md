# Horizon-Core

### 这是什么？

Horizon 的核心组件，提供必要的库功能

### 它和 `modules` 的区别？

你可以理解为，对游戏没有直接作用的部件，例如 `log`

## `ticker/*`
触发器，提供了多种时序间隔的固定触发

- 在 `_ms/reg.cfg` 中注册事件

>  需要注意的是，触发器的时间间隔并不固定，受帧率影响

## `log/*`

提供关闭控制台输出控制的函数

## `msg/*`

Horizon 的消息输出控制，所有的消息由此输出给用户，以便通过自定义输出通道

- Usage：`setinfo hzMsg 文本;hzMsg_send`

## `sndFetch/*`
Horizon 声音抓取

## `reg`

Horizon 的所有暴露接口注册

keyPreference 只应调用此文件内注册的接口