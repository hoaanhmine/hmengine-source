# Modchart Modifier Reference

## Cách dùng trong Lua

```lua
-- Thêm modifier
addModifier("confusion")

-- Set giá trị (player 1 default)
setPercent("confusion", 50)
setPercent("confusion", 50, 1)    -- player 2
setPercent("confusion", 50, 0, 2) -- lane 2 (column 3)

-- Easing
ease("confusion", 4, 8, 360, "sineInOut")
ease("confusion", 4, 8, 360, "sineInOut", 0, 1) -- player, lane

-- Set tức thì
set("confusion", 4, 360)
-- Set/add/ease batch với table
set({confusion=0, scale=1}, 0)
```

---

## Danh sách Modifier

### Cốt lõi

| Tên | Tác dụng |
|-----|----------|
| **reverse** | Đảo hướng scroll (lên/xuống). `split` = đảo nửa phải, `alternate` = đảo cách lane, `cross` = đảo lane trong cùng. Có per-lane |
| **scrollAngleX/Y/Z** | Xoay hướng scroll theo trục 3D |
| **curvedScrollX/Y** | Scroll cong - góc scroll tăng dần theo khoảng cách |
| **xmod** | Nhân tốc độ scroll (giống mod speed) |
| **randomspeed** | Tốc độ scroll ngẫu nhiên mỗi note |
| **centered** | Căn giữa tất cả notes vào giữa màn hình |

### Modifier chính

| Tên | Tác dụng |
|-----|----------|
| **confusion** | Xoay notes theo nhịp. `dizzy` = quay Z liên tục, `roll` = lộn X, `twirl` = lộn Y |
| **drunk** | Notes lắc lư sang 2 bên theo sóng cosine |
| **tipsy** | Tương tự drunk nhưng nhẹ hơn, lắc trên cả 3 trục |
| **tornado** | Xoáy notes theo hình xoắn ốc quanh cột |
| **bumpy** | Notes nhảy lên xuống hình sin |
| **bounce** | Notes nảy theo nhịp (`\|sin(beat)\|`) |
| **beat** | Notes rung/lắc theo nhịp, có tốc độ và mult |
| **stealth** | Ẩn notes. `dark` = ẩn holds, `alpha` = độ mờ. `sudden` = mờ dần khi tới, `hidden` = mờ dần khi đi xa |
| **scale** | Scale notes. `tiny` = thu nhỏ 50%/lần, `mini` = gần giống tiny, `stretch` = nén ngang + kéo dọc |
| **zoom** | Zoom toàn bộ từ tâm màn hình. `localZoom` = zoom từ tâm player. `mini`/`localMini` = zoom nghịch (thu nhỏ) |
| **rotateX/Y/Z** | Xoay notes quanh tâm receptor. `centerRotate` = xoay quanh tâm màn hình, `fieldRotate` = xoay quanh tâm khu vực player, `localRotate` = xoay quanh receptor giữa |
| **skewX/Y** | Nghiêng notes theo shear. `fieldSkewX/Y` = biến dạng cả playfield hình bình hành |
| **boost** | Tăng/giảm tốc notes khi tới receptor. `brake` = giảm tốc, `wave` = scroll hình sin |
| **transform** | Dịch chuyển X/Y/Z raw. `x`/`y`/`z` và `xoffset`/`yoffset`/`zoffset` |
| **infinite** | Notes đi theo hình số 8 (lemniscate) |
| **radionic** | Notes xếp vòng tròn quay quanh tâm màn hình, kèm scale/glow theo nhịp |
| **sawtooth** | Dịch notes theo sóng răng cưa |
| **square** | Dịch notes theo sóng vuông (trái phải đột ngột) |
| **zigzag** | Dịch notes theo sóng tam giác (zigzag) |
| **drugged** | Notes lắc lư phức tạp + scale squish + glow màu |
| **invert** | Đảo vị trí lane: `invert` = đổi cặp, `flip` = đảo toàn bộ thứ tự lane |
| **receptorScroll** | Notes chạy lên xuống luân phiên theo nhịp |
| **carousel** | Notes xoay vòng quanh màn hình như băng chuyền |
| **asymptote** | Notes hội tụ về tâm receptor khi ở xa (hiệu ứng phối cảnh) |
| **parabolaX/Y/Z** | Cong notes theo parabol (t²) |
| **cubicX/Y/Z** | Cong notes theo cubic (t³) |
| **digital** | Sóng bậc thang (pixel hóa). `digitalz` = trên trục Z, `tandigital` = dùng tan() cho chuyển đổi sắc nét |
| **attenuate** | Notes càng xa càng bị đẩy ra khỏi receptor (hiệu ứng phối cảnh mạnh hơn asymptotic) |

### False Paradise

| Tên | Tác dụng |
|-----|----------|
| **wiggle** | Notes lắc nhẹ theo nhịp (X, Y, và góc Z) |
| **vibrate** | Notes rung ngẫu nhiên (offset X, Y random) |
| **spiral** | Notes xoáy theo hình xoắn ốc logarit |
| **counterClockWise** | Notes bay vòng tròn ngược chiều kim đồng hồ |
| **eyeShape** | Notes đi theo đường cong hình mắt (từ CSV) |
| **arrowShape** | Notes đi theo đường hình mũi tên (từ CSV) |
| **schmovinArrowShape** | Notes đi theo path arrowShape với timing (dạng 4D) |
| **schmovinDrunk** | Drunk nhẹ nhàng hơn, sóng theo nhịp + khoảng cách |
| **schmovinTipsy** | Nhảy nhẹ theo nhịp, mỗi lane khác phase |
| **schmovinTornado** | Tornado mượt hơn, dùng cosine wave |

### Psych NoteTween Bridge

| Tên | Tác dụng |
|-----|----------|
| **psych_noteTweenAngle** | Đồng bộ angle từ noteTweenAngle (Psych) vào hệ thống modchart |
| **psych_noteTweenDirection** | Đồng bộ direction từ noteTweenDirection (Psych) vào scroll |

### Path/Scripting

| Tên | Tác dụng |
|-----|----------|
| **luapath** | Notes đi theo path 3D do Lua/HScript định nghĩa runtime. 3 mode: wrap, clamp, drive |
| **opponentSwap** | Dịch notes về phía đối thủ (đổi field giữa player 1 và 2) |

---

## Các modifier thường dùng kết hợp

```lua
-- Scroll effect cơ bản
addModifier("reverse")

-- Confusion spam
addModifier("confusion")
addModifier("dizzy")
addModifier("roll")

-- Ẩn/hiện
addModifier("stealth")
addModifier("sudden")
addModifier("hidden")

-- Gravity / phối cảnh
addModifier("asymptote")
addModifier("attenuate")

-- Vòng tròn
addModifier("radionic")
addModifier("counterClockWise")
addModifier("spiral")

-- Waves
addModifier("drunk")
addModifier("tornado")
addModifier("bumpy")
addModifier("beat")

-- Scale / Zoom
addModifier("scale")
addModifier("zoom")
addModifier("stretch")
addModifier("tiny")

-- Dịch chuyển
addModifier("x")
addModifier("y")
```

---

## Per-lane variant

Hầu hết modifier có thể dùng riêng cho từng lane bằng cách thêm số lane vào cuối tên hoặc truyền param field:

```lua
-- Per-lane: đặt percent riêng
setPercent("confusion", 90, 0, 0)   -- lane 1 player 1
setPercent("confusion", 180, 0, 1)  -- lane 2 player 1
setPercent("confusion", 270, 0, 2)  -- lane 3
setPercent("confusion", 360, 0, 3)  -- lane 4
```

## Ease functions có sẵn

```
linear, sineIn, sineOut, sineInOut, quadIn, quadOut, quadInOut,
cubeIn, cubeOut, cubeInOut, quartIn, quartOut, quartInOut,
quintIn, quintOut, quintInOut, expoIn, expoOut, expoInOut,
circIn, circOut, circInOut, elasticIn, elasticOut, elasticInOut,
backIn, backOut, backInOut, bounceIn, bounceOut, bounceInOut,
smoothStep, smootherStep, pop, popSmall, popLarge, step
```
