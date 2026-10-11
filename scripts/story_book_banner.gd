extends Control
## Illustrated dossier cover, drawn at native UI resolution without external assets.
var chapter_number:=1
var completed:=false
func _ready() -> void:
    custom_minimum_size=Vector2(0,245);mouse_filter=Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
    var w: float=size.x
    draw_rect(Rect2(Vector2.ZERO,size),Color("#10292f"))
    for i in range(14):
        var line:=PackedVector2Array()
        for k in range(32):line.append(Vector2(float(k)*w/31,25+i*17+sin(float(k)*.23+i*.45)*12))
        draw_polyline(line,Color(.48,.70,.62,.11),1.5,true)
    var p:=Vector2(w*.72,126)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-85,-75),p+Vector2(88,-88),p+Vector2(102,69),p+Vector2(-67,82)]),Color("#cfb98d"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-80,-80),p+Vector2(87,-74),p+Vector2(80,81),p+Vector2(-91,73)]),Color("#eadcba"))
    for i in range(7):draw_line(p+Vector2(-67,-37+i*15),p+Vector2(57,-33+i*15),Color("#91a28b"),1.5,true)
    draw_arc(p+Vector2(25,-7),26,0,TAU,40,Color("#a67b48"),2,true)
    draw_line(p+Vector2(18,2),p+Vector2(26,12),Color("#a67b48"),2,true)
    draw_line(p+Vector2(26,12),p+Vector2(39,-10),Color("#a67b48"),2,true)
    draw_line(Vector2(30,40),Vector2(w*.44,40),Color("#8cbfa6"),2,true)
    draw_string(ThemeDB.fallback_font,Vector2(30,84),"DIE OFFENE AKTE",HORIZONTAL_ALIGNMENT_LEFT,w*.48,27,Color("#c9dacc"))
    draw_string(ThemeDB.fallback_font,Vector2(30,135),"EPILOG" if completed else "KAPITEL %02d" % chapter_number,HORIZONTAL_ALIGNMENT_LEFT,w*.48,38,Color("#efca85"))
    draw_string(ThemeDB.fallback_font,Vector2(30,189),"Herkunft. Erinnerung. Deine Entscheidung.",HORIZONTAL_ALIGNMENT_LEFT,w*.56,22,Color("#a8c2b7"))
