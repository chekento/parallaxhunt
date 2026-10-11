extends RefCounted
const Room=preload("res://scripts/interior_art.gd")
const World=preload("res://scripts/romance_world.gd")
const Data=preload("res://scripts/romance_data.gd")
const INK=Color("#233039")

static func obstacles() -> Array[Rect2]:
    return [Rect2(80,225,295,120),Rect2(580,235,245,215),Rect2(85,500,230,95),Rect2(120,695,160,100),Rect2(620,550,210,70),Rect2(610,900,210,85),Rect2(85,920,240,60),Rect2(450,190,18,210),Rect2(450,575,18,130)]
static func nearest(g: Node) -> Dictionary:
    if not g.home_state.leases.has(g.active_apartment):return {}
    for item in [[Vector2(360,390),"meal","KOCHEN"],[Vector2(565,495),"rest","AUSRUHEN"],[Vector2(575,970),"nursery","FAMILIENZIMMER"]]:
        if g.interior_player_pos.distance_to(item[0])<65:return {"type":"home_moment","id":item[1],"action":item[2]}
    if g.home_state.living and g.active_apartment==g.home_state.primary and g.interior_player_pos.distance_to(Vector2(375,625))<72:
        return {"type":"romance_person","id":str(g.love_state.partner),"action":"PARTNERIN"}
    return {}
static func draw_room(g: Node2D) -> void:
    var home:=World.home(g,g.active_apartment)
    var accent:=Color(str(home.get("color","#bba388")))
    if g.home_state.style=="sea":accent=Color("#8aafb7")
    if g.home_state.style=="garden":accent=Color("#a8bc93")
    var origin: Vector2=Room.origin(g)
    g.draw_set_transform(origin)
    var room:=Rect2(Vector2.ZERO,g.interior_size)
    g.draw_rect(room.grow(15),Color(0,0,0,.35));g.draw_rect(room,Color("#b39878"))
    for y in range(175,1240,42):
        g.draw_line(Vector2(18,y),Vector2(902,y),Color("#83684f"),2)
        for x in range(25,890,155):g.draw_line(Vector2(x+(75 if int(y/42)%2 else 0),y),Vector2(x+(75 if int(y/42)%2 else 0),y+42),Color("#907457"),1)
    Room.box(g,Rect2(0,25,920,145),accent.darkened(.2),25)
    Room.window(g,Rect2(45,55,165,80),true);Room.window(g,Rect2(710,55,165,80),true)
    Room.text(g,Vector2(247,77),"UNSER ZUHAUSE" if g.home_state.living and g.home_state.primary==g.active_apartment else "DEIN APARTMENT",29,Color("#f4e8cf"),480)
    Room.text(g,Vector2(247,118),str(home.get("name","Wohnung")),21,Color("#ddd8cb"),450)
    g.draw_rect(Rect2(0,170,18,1070),INK);g.draw_rect(Rect2(902,170,18,1070),INK);g.draw_rect(Rect2(0,1240,920,20),INK)
    for rect in [Rect2(450,190,18,210),Rect2(450,575,18,130)]:Room.box(g,rect,accent.lightened(.12),22)
    Room.kitchen(g,Rect2(80,225,295,120))
    Room.shelf(g,Rect2(80,180,295,40),true)
    Room.text(g,Vector2(85,397),"KÜCHE / KOCHEN",21,Color("#453f39"),310)
    Room.rug(g,Rect2(55,450,355,415),accent.darkened(.12))
    Room.sofa(g,Rect2(85,500,230,95),accent.darkened(.14))
    Room.box(g,Rect2(120,695,160,100),Color("#b7825c"),17)
    for p in [Vector2(154,726),Vector2(242,761)]:
        g.draw_circle(p,18,Color("#f0e4cf"));g.draw_circle(p,11,Color("#c59662"));g.draw_circle(p+Vector2(27,-15),7,Color("#dbbf94"))
    Room.chair(g,Vector2(90,750),accent);Room.chair(g,Vector2(317,750),accent)
    Room.box(g,Rect2(580,235,245,215),Color("#776456"),18)
    g.draw_rect(Rect2(594,219,216,54),Color("#e7dfc9"));g.draw_rect(Rect2(594,280,216,146),accent.lightened(.19))
    for x in [610,710]:Room.box(g,Rect2(x,224,84,45),Color("#efe5d2"),8)
    for y in [295,310,405]:g.draw_line(Vector2(602,y),Vector2(799,y),accent.lightened(.37),2)
    Room.text(g,Vector2(575,500),"RUHE / +8 SPIELSTUNDEN",19,Color("#453f39"),310)
    Room.box(g,Rect2(620,550,210,70),accent.darkened(.24),16)
    Room.window(g,Rect2(622,650,203,80),true)
    g.draw_rect(Rect2(618,738,215,20),INK)
    for x in range(625,833,24):g.draw_line(Vector2(x,740),Vector2(x,800),Color("#7a8d83"),3)
    Room.plant(g,Vector2(805,823),35);Room.plant(g,Vector2(510,225),26);Room.plant(g,Vector2(102,1085),37)
    Room.shelf(g,Rect2(85,920,240,60))
    var family_room: bool=g.home_state.nursery and g.active_apartment==g.home_state.primary and int(home.get("capacity",0))>=3
    if family_room:
        Room.box(g,Rect2(610,900,210,85),Color("#e1c9a9"),13)
        for x in range(620,819,24):g.draw_line(Vector2(x,887),Vector2(x,967),Color("#a68b73"),4)
        g.draw_rect(Rect2(621,900,187,64),Color("#cad5b7"))
        for p in [Vector2(637,1030),Vector2(710,1050),Vector2(780,1020)]:
            g.draw_circle(p,14,Color("#e8b597"));g.draw_rect(Rect2(p+Vector2(-8,9),Vector2(16,15)),Color("#9bb9bf"))
        Room.text(g,Vector2(607,1105),"FAMILIENZIMMER",21,Color("#453f39"),290)
    else:
        Room.box(g,Rect2(610,900,210,85),Color("#b78b62"),16)
        Room.shelf(g,Rect2(670,855,130,35));Room.chair(g,Vector2(720,1020),accent)
        Room.text(g,Vector2(607,1105),"ZIMMER FÜR EURE ZUKUNFT" if int(home.get("capacity",0))>=3 else "ARBEITSECKE",18,Color("#453f39"),295)
    if g.home_state.living and g.active_apartment==g.home_state.primary:
        var p: Dictionary=Data.person(str(g.love_state.partner))
        if not p.is_empty():draw_person_local(g,Vector2(375,625),p,1.25)
        Room.text(g,Vector2(280,682),str(p.get("name","")),22,Color("#423e37"),150)
    g.draw_arc(Vector2(460,840),28,0,TAU,48,Color("#c8dfb5"),3,true)
    Room.text(g,Vector2(372,905),"ZUHAUSE",24,Color("#453f39"),220)
    g.draw_rect(Rect2(389,1234,142,22),Color("#719c91"));Room.text(g,Vector2(370,1210),"ZUR STRASSE",21,Color("#453f39"),240)
    g.draw_set_transform(Vector2.ZERO)

static func draw_person_local(g: Node2D,p: Vector2,profile: Dictionary,scale: float=1.0) -> void:
    var skin:=Color(str(profile.skin));var hair:=Color(str(profile.hair));var clothes:=Color(str(profile.color))
    g.draw_circle(p+Vector2(0,4)*scale,10*scale,Color(0,0,0,.25))
    for x in [-4,4]:
        g.draw_line(p+Vector2(x,-16)*scale,p+Vector2(x,0)*scale,Color("#303442"),5*scale,true)
        g.draw_circle(p+Vector2(x+1,1)*scale,3.4*scale,INK)
    g.draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-34)*scale,p+Vector2(9,-34)*scale,p+Vector2(7,-16)*scale,p+Vector2(-7,-16)*scale]),clothes)
    g.draw_line(p+Vector2(-9,-31)*scale,p+Vector2(-13,-16)*scale,clothes.darkened(.1),5*scale,true)
    g.draw_line(p+Vector2(9,-31)*scale,p+Vector2(13,-16)*scale,clothes.darkened(.1),5*scale,true)
    g.draw_circle(p+Vector2(-13,-14)*scale,3*scale,skin);g.draw_circle(p+Vector2(13,-14)*scale,3*scale,skin)
    g.draw_circle(p+Vector2(0,-44)*scale,9*scale,hair)
    g.draw_circle(p+Vector2(0,-42)*scale,6.5*scale,skin)
    g.draw_arc(p+Vector2(0,-45)*scale,7.2*scale,PI,TAU,16,hair,3.5*scale,true)
    g.draw_line(p+Vector2(-8,-42)*scale,p+Vector2(-7,-32)*scale,hair,3*scale,true)
    g.draw_circle(p+Vector2(-2,-43)*scale,1*scale,INK);g.draw_circle(p+Vector2(2,-43)*scale,1*scale,INK)
    g.draw_line(p+Vector2(-2,-38)*scale,p+Vector2(2,-38)*scale,Color("#a75f62"),1.4*scale,true)
static func draw_person(g: Node2D,id: String) -> void:
    var p:=Data.person(id)
    if p.is_empty():return
    var world: Vector2=World.person_pos(g,id);var foot: Vector2=g._project(world)
    if not g._tile_visible(foot,150):return
    draw_person_local(g,foot,p,float(g.world_zoom))
    if g.player_pos.distance_to(world)<180:
        g.draw_arc(foot,12*g.world_zoom,0,TAU,32,Color("#e8b0ba"),1.4*g.world_zoom,true)
static func draw_exteriors(g: Node2D) -> void:
    for h in g.apartment_sites:
        if h.legacy or not g._world_rect_visible(Rect2(h.rect).grow(130)):continue
        var entry: Vector2=g._project(h.pos)
        g.draw_line(entry,g._project(h.footway),Color("#b9aa90"),18*g.world_zoom,true)
        var tone:=Color("#e8b0ba") if g.home_state.leases.has(h.id) else Color("#dcc895")
        g.draw_circle(entry,16*g.world_zoom,Color("#172e32"));g.draw_arc(entry,16*g.world_zoom,0,TAU,36,tone,2*g.world_zoom,true)
        var center: Vector2=h.rect.get_center()
        var facing: Vector2=(Vector2(h.pos)-center).normalized()
        var side:=facing.orthogonal()
        for direction in [-1.0,1.0]:
            var planter: Vector2=g._project(Vector2(h.pos)+side*direction*36-facing*12)
            g.draw_rect(Rect2(planter-Vector2(7,0)*g.world_zoom,Vector2(14,8)*g.world_zoom),Color("#9c7259"))
            g.draw_circle(planter-Vector2(0,5)*g.world_zoom,7*g.world_zoom,Color("#88a96c"))
            g.draw_circle(planter-Vector2(2,8)*g.world_zoom,2.4*g.world_zoom,Color("#e8b0ba"))
        g.draw_string(ThemeDB.fallback_font,entry+Vector2(-100,-26)*g.world_zoom,str(h.name),HORIZONTAL_ALIGNMENT_CENTER,200*g.world_zoom,int(14*g.world_zoom),Color("#f0e8d6"))
