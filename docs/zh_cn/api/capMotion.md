# capMotion

capMotion 提供了一套完整的移动解决方案

## 约定

下文中，`<motion>` 代指下列四者之一：
- `forward`
- `back`
- `right`
- `left`

## API
### 移动
```
+/-capMot_<motion>
```

### 移动反向 (multibind)
```
capMot_mvrev
```

### 强制开启/关闭移动反向 (multibind)
to do

### 改变移动速度 (joy mode only)
给出满速示例。自行更改数值即可
```
alias capMot_joy_setSpeedFull "alias capMot_joyf_spd joy_forward_sensitivity 1;alias capMot_joyb_spd joy_forward_sensitivity -1;alias capMot_joyr_spd joy_side_sensitivity 1;alias capMot_joyl_spd joy_side_sensitivity -1;capMot_joy_upd"
```

### 切换移动模式 (multibind)
```
capMot_sw2joy_ticked
capMot_sw2key_ticked
```

### 切换移动模式
```
capMot_sw2joy
capMot_sw2key
```

### 重置 (multibind)
```
capMot_reset
```
