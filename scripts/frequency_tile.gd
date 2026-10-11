extends Button
## Large readable spectrum controls show both target and current level.
var channel: int=0
var level: int=0
var target_level: int=0
func _init() -> void:
    custom_minimum_size=Vector2(180,260)
    mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
func _draw() -> void:
    var mint:=Color("#9ed7bc");var gold:=Color("#e9c789")
    var width: float=size.x-40
    draw_string(ThemeDB.fallback_font,Vector2(20,34),"KANAL %d" % [channel+1],HORIZONTAL_ALIGNMENT_LEFT,width,22,Color("#b9d0ca"))
    draw_string(ThemeDB.fallback_font,Vector2(20,68),"ZIEL %d" % [target_level+1],HORIZONTAL_ALIGNMENT_LEFT,width,24,gold)
    for i in range(5):
        var bar_width: float=(width-16)/5
        var height: float=25+i*16
        var r:=Rect2(20+i*(bar_width+4),194-height,bar_width,height)
        draw_rect(r,mint if i<=level else Color("#294845"))
        if i==target_level:draw_rect(r.grow(2),gold,false,2,true)
    draw_string(ThemeDB.fallback_font,Vector2(20,230),"%d / 5" % [level+1],HORIZONTAL_ALIGNMENT_LEFT,width,25,mint if level==target_level else Color("#d9e4d6"))
