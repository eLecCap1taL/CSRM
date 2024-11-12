# KeyLib

keylib 旨在将键鼠移动逻辑变换为手柄逻辑，且提供后置刷新，更好的满足 multibind 下的需求

## 约定

下文中，`<motion>` 代指下列四者之一：
- `forward`
- `back`
- `right`
- `left`

## 使用格式

### 在任何情况下令 `<motion>` 为 `x`
```
keylib_<motion>_x_upd
```

### 在任何情况下令 `<motion>` 为 `x`，但并不更新移动状态
```
keylib_<motion>_x
```

### 更新 `<motion>` 方向的移动状态
```
keylib_<motion>_upd
```

## 它的使用场景是什么？
keylib 的核心功能在于 `upd`，下面将举例子说明
> 你写了一个移动模块，受制于 multibind，你现在在同一时间内有很多操作，形如 `+forward;-forward;forward 0.5 0 0;forward 0.5 0 0`，直接书写由于 multibind 是会失败的，但它明明应该只是一个动作，前面的这个语句显然等价于 `forward 1 0 0`。此时，使用 keylib 可以正常书写 `keylib_forward_1;keylib_forward_0;keylib_forward_0.5` 这样的多个语句，只需在最后调用一次 `keylib_forward_upd` 以刷新速度即可。
> 
> 注意 keylib 是覆写式而不是叠加式，可以思考 `forward 0.5 0 0;forward 0.2 0 0` 和 `forwardback 0.5 0 0;forwardback 0.2 0 0` 的区别，keylib 的行为与后者相同。
> 
> 如果你还是觉得 keylib 无用，那么 keylib 确实对你无用。