extends Control
var profile: Dictionary={}
var banner:=false
const INK=Color("#253038")

func _ready() -> void:
    clip_contents=true

func _draw() -> void:
    var r:=Rect2(Vector2.ZERO,size)
    draw_style_box(style(Color("#d6cbb8"),Color("#eadfd0")),r)
    for i in range(8):
        draw_arc(Vector2(size.x-85,70),55+i*24,.1,3.3,64,Color("#b2a897"),1,true)
    if banner:
        draw_circle(Vector2(150,size.y*.5),72,Color("#b78e98"))
        heart(Vector2(150,size.y*.5),36,Color("#f1ded5"))
        draw_string(ThemeDB.fallback_font,Vector2(255,70),"EIN ZUHAUSE FÜR ZWEI",HORIZONTAL_ALIGNMENT_LEFT,size.x-280,29,INK)
        draw_string(ThemeDB.fallback_font,Vector2(255,112),"Blicke. Abende. Ein gemeinsames Leben.",HORIZONTAL_ALIGNMENT_LEFT,size.x-280,23,Color("#52615b"))
        draw_line(Vector2(255,143),Vector2(size.x-38,143),Color("#b99b8e"),2,true)
        return
    if profile.is_empty():return
    var p:=Vector2(145,size.y*.52)
    var skin:=Color(str(profile.skin));var hair:=Color(str(profile.hair));var coat:=Color(str(profile.color))
    draw_circle(p+Vector2(2,20),76,Color("#b3a898"))
    draw_circle(p,74,Color("#e5dcca"))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-72,75),p+Vector2(-58,18),p+Vector2(-26,7),p+Vector2(26,7),p+Vector2(60,22),p+Vector2(76,75)]),coat.darkened(.2))
    draw_colored_polygon(PackedVector2Array([p+Vector2(-26,10),p+Vector2(-10,46),p+Vector2(8,46),p+Vector2(28,10)]),Color("#eee2d4"))
    draw_rect(Rect2(p+Vector2(-11,-4),Vector2(23,25)),skin.darkened(.09))
    draw_circle(p+Vector2(0,-42),44,hair)
    draw_circle(p+Vector2(0,-36),33,skin)
    draw_circle(p+Vector2(-32,-33),7,skin);draw_circle(p+Vector2(32,-33),7,skin)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-44,-37),p+Vector2(-27,-78),p+Vector2(12,-82),p+Vector2(38,-56),p+Vector2(32,-44),p+Vector2(4,-59),p+Vector2(-18,-64),p+Vector2(-29,-40),p+Vector2(-27,15),p+Vector2(-46,10)]),hair)
    draw_colored_polygon(PackedVector2Array([p+Vector2(32,-55),p+Vector2(43,-29),p+Vector2(38,22),p+Vector2(27,19),p+Vector2(29,-43)]),hair.lightened(.06))
    for x in [-13,13]:
        draw_arc(p+Vector2(x,-40),7,.2,2.7,16,INK,2,true)
        draw_circle(p+Vector2(x,-38),2.3,INK)
        draw_arc(p+Vector2(x,-48),8,3.4,5.8,12,hair,2,true)
    draw_line(p+Vector2(1,-32),p+Vector2(-2,-24),skin.darkened(.26),1.8,true)
    draw_arc(p+Vector2(0,-22),10,.1,2.9,18,Color("#a65f65"),3,true)
    draw_circle(p+Vector2(-33,-20),3,Color("#d9c4a1"));draw_circle(p+Vector2(33,-20),3,Color("#d9c4a1"))
    draw_line(p+Vector2(-41,28),p+Vector2(-50,65),coat.lightened(.18),2,true)
    draw_line(p+Vector2(42,28),p+Vector2(51,65),coat.lightened(.18),2,true)
    draw_string(ThemeDB.fallback_font,Vector2(260,65),str(profile.name)+" · "+str(profile.age),HORIZONTAL_ALIGNMENT_LEFT,size.x-280,34,INK)
    draw_string(ThemeDB.fallback_font,Vector2(260,108),str(profile.role),HORIZONTAL_ALIGNMENT_LEFT,size.x-280,23,Color("#52615b"))
    var tone: String={"attentive":"Aufmerksam & persönlich","playful":"Verspielt & frech","bold":"Direkt & mit Knistern"}.get(str(profile.tone),"")
    draw_string(ThemeDB.fallback_font,Vector2(260,150),tone,HORIZONTAL_ALIGNMENT_LEFT,size.x-280,23,Color("#85666b"))
func heart(p: Vector2,r: float,c: Color) -> void:
    draw_circle(p+Vector2(-r*.35,-r*.25),r*.55,c);draw_circle(p+Vector2(r*.35,-r*.25),r*.55,c)
    draw_colored_polygon(PackedVector2Array([p+Vector2(-r*.82,-r*.02),p+Vector2(0,r*.9),p+Vector2(r*.82,-r*.02)]),c)
static func style(bg: Color,border: Color) -> StyleBoxFlat:
    var s:=StyleBoxFlat.new();s.bg_color=bg;s.border_color=border;s.set_border_width_all(2);s.set_corner_radius_all(24);return s
