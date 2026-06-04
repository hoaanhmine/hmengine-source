# Hướng dẫn Modchart (HMEngine)

## Cách dùng

Tạo file `.lua` trong thư mục songs/data/ của bài hát, viết code trong `onCreatePost()`.

```lua
function onCreatePost()
    -- KHÔNG cần addModifier nữa — tự động thêm khi dùng ease/set/setPercent
    ease("confusion", 4, 8, 360, "sineInOut")
    ease("scale", 4, 8, 1.5, "quadOut")
    setPercent("mini", 1)
end
```

---

## API Lua đầy đủ

### Quản lý modifier

```lua
-- Tên modifier tự động lowercase, không phân biệt hoa thường

setPercent(name, value, player?, field?)
-- Đặt % của modifier (0-100 hoặc giá trị khác tuỳ modifier)
setPercent("confusion", 50)           -- player 0
setPercent("confusion", 50, 1)        -- player 1
setPercent("confusion", 50, 0, 2)     -- playfield 2

getPercent(name, player?, field?)     -- -> number

setRawValue(name, value, player?, field?)
-- Giống setPercent nhưng dùng giá trị tuyệt đối

getRawValue(name, player?, field?)    -- -> number
```

### Timeline (theo beat)

```lua
-- set: đặt giá trị tại beat
set(name, beat, value, player?, field?)
set("confusion", 4, 360)

-- ease: chạy từ beat trong length beat để đạt value
ease(name, beat, length, value, easeName?, player?, field?)
ease("confusion", 4, 8, 360, "sineInOut")

-- add: cộng thêm value sau length beat
add(name, beat, length, value, easeName?, player?, field?)

-- setAdd: đặt + cộng dồn
setAdd(name, beat, value, player?, field?)
```

### Timeline — variant "Now" (dùng tại beat hiện tại)

```lua
setNow(name, value, player?, field?)
easeNow(name, length, value, easeName?, player?, field?)
addNow(name, length, value, easeName?, player?, field?)
setAddNow(name, value, player?, field?)
```

### Batch (table)

```lua
-- Truyền table thay cho tên để set nhiều modifier cùng lúc
set({confusion=360, scale=1.5, drunk=50}, 0)
ease({confusion=360, scale=1.5}, 4, 8, "sineInOut")
setNow({confusion=180, scale=0.5})
```

### Callback & Repeater

```lua
callback(beat, funcName, field?)
-- Gọi hàm Lua tại beat nhất định

repeater(startBeat, length, funcName, field?)
-- Gọi hàm lặp lại mỗi length beat

scheduleCallback(beat, funcName, field?)
-- Giống callback
```

### Playfield & Alias

```lua
addPlayfield()
-- Tạo thêm playfield (cho nhiều người chơi / nhiều layout)

alias(originalName, aliasName, field)
-- Đặt tên khác cho modifier
```

### Getter

```lua
getCurrentBeat()   -> number
getCurrentStep()   -> number
getSongPosition()  -> number  (ms)
getBPM()           -> number
getPlayerCount()   -> number
getHoldSize()      -> number
getHoldSizeDiv2()  -> number
getArrowSize()     -> number
getArrowSizeDiv2() -> number

getRenderedStrumPosition(strumSprite, field?) -> {x: number, y: number}
```

---

## Danh sách Modifier

### Scroll / Direction

| Tên | Tác dụng |
|-----|----------|
| **reverse** | Đảo hướng scroll. `split`=đảo nửa phải, `alternate`=đảo cách lane, `cross`=đảo lane trong |
| **scrollAngleX/Y/Z** | Xoay hướng scroll 3D |
| **curvedScrollX/Y** | Scroll cong dần theo khoảng cách |
| **xmod** | Nhân tốc độ scroll |
| **randomspeed** | Scroll speed ngẫu nhiên mỗi note |
| **centered** | Căn giữa notes vào giữa màn hình |

### Xoay / Transform

| Tên | Tác dụng |
|-----|----------|
| **confusion** | Xoay notes theo nhịp. `dizzy`=quay Z, `roll`=lộn X, `twirl`=lộn Y |
| **rotateX/Y/Z** | Xoay notes quanh tâm receptor |
| **centerRotateX/Y/Z** | Xoay quanh tâm màn hình |
| **fieldRotateX/Y/Z** | Xoay quanh tâm khu vực player |
| **localRotateX/Y/Z** | Xoay quanh receptor giữa |
| **invert** | Đảo lane: `invert`=đổi cặp, `flip`=đảo toàn bộ |
| **opponentSwap** | Đổi chỗ notes sang phía đối thủ |
| **transform** | Dịch raw `x`/`y`/`z` và `xoffset`/`yoffset`/`zoffset` |

### Scale / Zoom

| Tên | Tác dụng |
|-----|----------|
| **scale** | Scale notes. `scaleX`/`scaleY` riêng. `tiny`=thu nhỏ 50%. `stretch`=nén ngang kéo dọc |
| **zoom** | Zoom toàn màn hình / `localZoom`=zoom từ player center |
| **mini** | Mini effect (thu nhỏ) |

### Ẩn hiện

| Tên | Tác dụng |
|-----|----------|
| **stealth** | Ẩn tap arrows. `dark`=ẩn holds. `alpha`=độ mờ |
| **sudden** | Mờ dần khi tới receptor. `suddenStart`/`suddenEnd`/`suddenGlow` |
| **hidden** | Mờ dần khi đi xa receptor. `hiddenStart`/`hiddenEnd`/`hiddenGlow` |

### Wave / Oscillation

| Tên | Tác dụng |
|-----|----------|
| **drunk** | Lắc lư cosine 2 bên |
| **tipsy** | Lắc nhẹ cả 3 trục |
| **tornado** | Xoáy theo cột |
| **bumpy** | Nhảy sin |
| **bounce** | Nảy theo `\|sin(beat)\|` |
| **beat** | Rung/lắc theo nhịp, mult, speed |
| **schmovinDrunk** | Drunk mượt hơn |
| **schmovinTipsy** | Nhảy nhẹ theo nhịp, mỗi lane khác phase |
| **schmovinTornado** | Tornado mượt hơn (cosine) |

### Waveform (shape displacement)

| Tên | Tác dụng |
|-----|----------|
| **sawtooth** | Sóng răng cưa |
| **square** | Sóng vuông |
| **zigzag** | Sóng tam giác |
| **digital** | Sóng bậc thang. `digitalz`=trên Z. `tandigital`=dùng tan() |
| **drugged** | Lắc phức tạp + scale squish + glow màu |

### Perspective / Curves

| Tên | Tác dụng |
|-----|----------|
| **asymptote** | Notes hội tụ về tâm receptor (phối cảnh) |
| **attenuate** | Notes bị đẩy xa khỏi receptor (phối cảnh mạnh hơn) |
| **parabolaX/Y/Z** | Cong parabol (t²) |
| **cubicX/Y/Z** | Cong cubic (t³) |
| **skewX/Y** | Nghiêng shear. `fieldSkewX/Y`=biến dạng playfield |
| **boost** | Tăng tốc khi tới receptor. `brake`=giảm tốc. `wave`=scroll sin |

### Path / Layout

| Tên | Tác dụng |
|-----|----------|
| **infinite** | Notes bay hình số 8 |
| **radionic** | Notes xoay vòng tròn quanh tâm + glow |
| **carousel** | Notes xoay vòng như băng chuyền |
| **receptorScroll** | Notes chạy lên xuống luân phiên |
| **arrowShape** | Notes đi theo path hình mũi tên (từ CSV) |
| **eyeShape** | Notes đi theo path hình mắt (từ CSV) |
| **schmovinArrowShape** | ArrowShape với timing 4D |
| **luapath** | Notes đi theo path 3D do Lua/HScript định nghĩa |
| **straightholds** | Holds giữ nguyên vị trí |

### False Paradise

| Tên | Tác dụng |
|-----|----------|
| **wiggle** | Lắc nhẹ X/Y/angle theo nhịp |
| **vibrate** | Rung ngẫu nhiên |
| **spiral** | Xoáy logarit |
| **counterClockWise** | Bay vòng tròn ngược kim đồng hồ |

### Psych NoteTween Bridge

| Tên | Tác dụng |
|-----|----------|
| **psych_noteTweenAngle** | Đồng bộ angle từ noteTweenAngle (Psych) |
| **psych_noteTweenDirection** | Đồng bộ direction từ noteTweenDirection (Psych) |

---

## Ease functions

```
linear        sineIn        sineOut       sineInOut
quadIn        quadOut       quadInOut     cubeIn
cubeOut       cubeInOut     quartIn       quartOut
quartInOut    quintIn       quintOut      quintInOut
expoIn        expoOut       expoInOut     circIn
circOut       circInOut     elasticIn     elasticOut
elasticInOut  backIn        backOut       backInOut
bounceIn      bounceOut     bounceInOut   smoothStep
smootherStep  pop           popSmall      popLarge
step
```

---

## Ví dụ nhanh

```lua
function onCreatePost()
    -- Cơ bản
    setPercent("mini", 1)

    -- Confusion từ từ
    ease("confusion", 0, 16, 720, "sineInOut")  -- 2 vòng trong 16 beat

    -- Ẩn rồi hiện
    ease("stealth", 16, 4, 1, "quadIn")          -- ẩn
    ease("stealth", 24, 4, 0, "quadOut")         -- hiện

    -- Scroll reverse vào cuối
    ease("reverse", 100, 4, 1, "cubeOut")

    -- Batch
    set({x=-100, y=50}, 0)
    ease({drunk=100, tipsy=50}, 32, 8, "sineInOut")

    -- Callback
    callback(64, "onDropPart")
end

function onDropPart()
    debugPrint("Beat 64 reached!")
    ease("confusion", 64, 8, 1440, "expoOut")
end
```

---

## Per-playfield

```lua
-- Mặc định field = -1 (tất cả)
-- field = 0 = player 1, field = 1 = player 2
setPercent("confusion", 50, 0, 0)   -- player 1, field 0
setPercent("confusion", 50, 1, 1)   -- player 2, field 1
```

## Ghi chú

- Modifier name **không phân biệt hoa thường**: `"Confusion"` = `"confusion"`
- `addModifier()` **không bắt buộc** — tự động thêm khi gọi `set/setPercent/ease/add`
- Chỉ cần `addModifier()` cho scripted modifier (DynamicModifier từ Haxe/Lua)
- `beat` trong các hàm timeline tính từ beat hiện tại (crochet sync)
- `field` = playfield index, -1 = tất cả
