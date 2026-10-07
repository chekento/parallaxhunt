extends Button
## A readable circuit tile drawn as geometry, independent of font glyphs.
var mask: int=0
var powered: bool=false
var source: bool=false
var target: bool=false

func _ready() -> void:
    custom_minimum_size=Vector2(126,126)
    mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
    for state in ["normal","hover","pressed","focus"]:
        var style:=StyleBoxFlat.new()
        style.bg_color=Color("#123038") if powered else Color("#101c29")
        style.border_color=Color("#66cdb1") if powered else Color("#34475b")
        style.set_border_width_all(2 if state=="normal" else 3)
        style.set_corner_radius_all(16)
        add_theme_stylebox_override(state,style)

func _draw() -> void:
    var c:=size*0.5
    var energy:=Color("#81f5cd") if powered else Color("#6d8396")
    var dirs: Array[Vector2]=[Vector2.UP,Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT]
    for i in range(4):
        if mask&(1<<i):
            var endpoint:=c+dirs[i]*(size.x*0.5-3)
            draw_line(c,endpoint,Color("#050e16"),16,true)
            draw_line(c,endpoint,energy,7,true)
            draw_circle(endpoint,4,energy)
    draw_circle(c,12,Color("#09141d"))
    draw_circle(c,7,energy)
    if source or target:
        var accent:=Color("#ffd280") if target else Color("#81f5cd")
        draw_circle(Vector2(size.x-15,15),10,Color("#08121b"))
        draw_string(ThemeDB.fallback_font,Vector2(size.x-20,20),"T" if target else "S",HORIZONTAL_ALIGNMENT_LEFT,-1,14,accent)
