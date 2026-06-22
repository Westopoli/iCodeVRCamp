---
title: "Pandoc Code Highlight Test"
author: "iCode Camp"
---

# Slide 1: Basic GDScript highlighting

```gdscript
var ball_speed_x := 6.0
var ball_speed_y := 3.0
var paddle_speed := 6.0
```

# Slide 2: Long line (the wrapping problem)

```gdscript
if Input.is_key_pressed(KEY_SPACE):
    ball_moving = true
if ball_moving == false:
    return
```

# Slide 3: Comments (the WRITE THIS panel)

```gdscript
# ball left-right speed (pick a number)
# ball up-down speed (pick a number)
# paddle speed (pick a number)
```

# Slide 4: Indentation stress test

```gdscript
var upper_border = 0
var lower_border = SCREEN_H - BALL_SIZE
if ball.position.y < upper_border or ball.position.y > lower_border:
    ball_speed_y = -ball_speed_y
else:
    pass
```

# Slide 5: Indented comment scaffold (the wrapping + indentation problem)

```gdscript
# if ball passed right edge (> SCREEN_W):
#     add 1 to left_score
#     call reset_ball()
# if ball passed left edge (< 0):
#     add 1 to right_score
#     call reset_ball()
```

# Slide 6: Mixed — syntax left, scaffold right

:::::::::::::: {.columns}
::: {.column width="48%"}

**SYNTAX**

```gdscript
if Input.is_key_pressed(KEY_SPACE):
    variable = true
if variable == false:
    return
```

:::
::: {.column width="48%"}

**WRITE THIS**

```gdscript
# if Space is pressed:
#     set ball_moving to true
# if ball_moving is false:
#     return
```

:::
::::::::::::::

# Slide 7: Python comparison (does it highlight python too?)

:::::::::::::: {.columns}
::: {.column width="48%"}

**Python**

```python
x = 5

def update():
    pass
```

:::
::: {.column width="48%"}

**GDScript**

```gdscript
var x = 5

func update():
    pass
```

:::
::::::::::::::

# Slide 8: Nested indentation (the real killer)

```gdscript
if has_key:
    line 1
    if door_locked:
        line 2
    line 3
line 4
```
