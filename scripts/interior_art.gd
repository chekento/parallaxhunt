extends RefCounted
## Authored rooms share the exterior ink, sprite atlas, and foot pivot.
const PEOPLE=preload("res://assets/visual/materials/characters_ink.png")
const CARS=preload("res://assets/visual/materials/vehicles_ink.png")
const INK=Color("#17212a")

static func feature_pos(kind: String, floor_index: int) -> Vector2:
    if kind=="apartment":return Vector2(460,840)
    if kind=="home": return Vector2(720,835) if floor_index==0 else Vector2(755,420)
    return {"bar":Vector2(300,455),"cafe":Vector2(700,405),"restaurant":Vector2(725,480),"shop":Vector2(740,395),"garage":Vector2(765,420),"workshop":Vector2(765,420),"hospital":Vector2(600,405),"openai_hq":Vector2(465,425),"roof":Vector2(460,470),"sublevel":Vector2(460,460)}.get(kind,Vector2(460,420))

static func title(kind: String, floor_index: int) -> String:
    return {"apartment":"APARTMENT","bar":"BAR & LOUNGE","cafe":"CAFÉ","restaurant":"RESTAURANT","shop":"CITY STORE","garage":"GARAGE","workshop":"WERKSTATT","home":"WOHNUNG" if floor_index==0 else "HAUSGARAGE","hospital":"STADTKLINIKUM","openai_hq":"VISITOR LAB" if floor_index==0 else "RESEARCH GALLERY","roof":"DACHTERRASSE","sublevel":"UNTERGRUND"}.get(kind,"INNENRAUM")

static func obstacles(kind: String, floor_index: int) -> Array[Rect2]:
    if kind=="bar": return [Rect2(90,245,470,120),Rect2(70,620,235,90),Rect2(610,910,230,100),Rect2(595,520,130,110),Rect2(365,800,130,110)]
    if kind=="cafe": return [Rect2(550,190,280,140),Rect2(170,400,120,110),Rect2(605,550,120,110),Rect2(230,820,120,110)]
    if kind=="restaurant": return [Rect2(610,190,240,205),Rect2(110,350,210,130),Rect2(355,640,210,130),Rect2(635,830,180,120)]
    if kind in ["garage","workshop"] or (kind=="home" and floor_index==1): return [Rect2(135,350,180,390),Rect2(425,350,180,390),Rect2(675,210,170,125),Rect2(70,870,215,70)]
    if kind=="home": return [Rect2(90,350,270,120),Rect2(140,530,190,85),Rect2(90,710,215,185),Rect2(570,195,270,150),Rect2(620,715,220,65),Rect2(370,655,20,95),Rect2(370,855,20,130)]
    if kind=="shop": return [Rect2(100,370,150,450),Rect2(395,370,150,450),Rect2(650,200,190,95),Rect2(670,730,155,150)]
    if kind=="hospital": return [Rect2(320,225,520,90),Rect2(95,430,240,190),Rect2(95,800,240,190),Rect2(610,650,230,85),Rect2(610,850,230,85)]
    if kind=="openai_hq": return [Rect2(310,205,305,110),Rect2(95,545,240,160),Rect2(585,545,240,160),Rect2(345,870,230,90)]
    if kind=="roof": return [Rect2(110,640,270,215),Rect2(595,630,220,330),Rect2(400,320,120,80)]
    if kind=="sublevel": return [Rect2(320,230,280,130),Rect2(105,610,225,325),Rect2(640,620,180,300)]
    return []

static func walkable(g: Node, p: Vector2) -> bool:
    if not Rect2(Vector2(45,185),g.interior_size-Vector2(90,225)).has_point(p): return false
    for r in obstacles(g.interior_kind,g.interior_floor):
        if r.grow(19).has_point(p): return false
    return true

static func origin(g: Node2D) -> Vector2:
    return (g.get_viewport_rect().size-g.interior_size)*0.5+Vector2(0,70)

static func text(g: Node2D, p: Vector2, value: String, size: int=25, color: Color=Color("#e6e8df"), width: float=700) -> void:
    g.draw_string(ThemeDB.fallback_font,p,value,HORIZONTAL_ALIGNMENT_LEFT,width,size,color)

static func box(g: Node2D, r: Rect2, color: Color, height: float=15) -> void:
    g.draw_rect(Rect2(r.position+Vector2(7,9),r.size),Color(0,0,0,0.22))
    g.draw_rect(r,color.darkened(0.32))
    var top=Rect2(r.position-Vector2(0,height),r.size)
    g.draw_rect(top,color)
    g.draw_rect(top,INK,false,3)
    g.draw_line(top.position+Vector2(3,3),Vector2(top.end.x-3,top.position.y+3),color.lightened(0.28),2,true)

static func rug(g: Node2D, r: Rect2, color: Color) -> void:
    g.draw_rect(r,color.darkened(0.35))
    g.draw_rect(r.grow(-8),color)
    g.draw_rect(r.grow(-17),Color("#d0bb91"),false,2)
    for x in range(int(r.position.x)+20,int(r.end.x)-10,32):
        g.draw_line(Vector2(x,r.position.y-4),Vector2(x,r.position.y+3),Color("#c5aa81"),2)
        g.draw_line(Vector2(x,r.end.y-3),Vector2(x,r.end.y+4),Color("#c5aa81"),2)

static func plant(g: Node2D, p: Vector2, radius: float=24) -> void:
    g.draw_circle(p+Vector2(4,4),radius,Color(0,0,0,0.20))
    g.draw_circle(p,radius*0.64,Color("#b77854"))
    g.draw_circle(p,radius*0.45,Color("#283c32"))
    for i in range(7):
        var dir=Vector2.from_angle(float(i)*TAU/7)
        var end=p+dir*radius-Vector2(0,18)
        g.draw_colored_polygon(PackedVector2Array([p-Vector2(0,8),end+dir.rotated(PI/2)*8,end+dir*13,end-dir.rotated(PI/2)*8]),Color("#579277") if i%2==0 else Color("#357163"))
        g.draw_line(p-Vector2(0,8),end+dir*6,Color("#82b68a"),1.5,true)

static func sofa(g: Node2D, r: Rect2, color: Color) -> void:
    box(g,r,color,18)
    box(g,Rect2(r.position-Vector2(0,16),Vector2(r.size.x,28)),color.darkened(0.18),12)
    for i in range(3):
        var cushion=Rect2(r.position+Vector2(14+i*(r.size.x-26)/3,14),Vector2((r.size.x-40)/3,r.size.y-30))
        g.draw_rect(cushion,color.lightened(0.08))
        g.draw_rect(cushion,Color(color.lightened(0.3),0.45),false,1)
    for side in [r.position.x,r.end.x-16]:
        box(g,Rect2(side,r.position.y-3,16,r.size.y),color.darkened(0.15),15)

static func chair(g: Node2D, p: Vector2, color: Color) -> void:
    g.draw_circle(p+Vector2(2,3),20,Color(0,0,0,0.18))
    box(g,Rect2(p-Vector2(18,12),Vector2(36,30)),color,7)
    g.draw_line(p+Vector2(-18,-20),p+Vector2(18,-20),color.lightened(0.2),8,true)

static func table(g: Node2D, p: Vector2, radius: float, color: Color, setting: bool=true) -> void:
    for side in [-1.0,1.0]:
        chair(g,p+Vector2(radius+34,0)*side,Color("#5b6d68"))
    g.draw_circle(p+Vector2(5,7),radius+4,Color(0,0,0,0.22))
    g.draw_circle(p,radius+2,INK)
    g.draw_circle(p-Vector2(0,10),radius,color)
    g.draw_arc(p-Vector2(0,10),radius-5,PI,TAU,24,color.lightened(0.27),2,true)
    if setting:
        for side in [-1,1]:
            var q=p+Vector2(side*radius*0.5,-12)
            g.draw_circle(q,14,Color("#ebe5cb"))
            g.draw_circle(q,10,Color("#bcad94"),false,1)
            g.draw_rect(Rect2(q+Vector2(18,-10),Vector2(2,20)),Color("#c4c5b5"))
            g.draw_circle(q+Vector2(2,-24),6,Color("#a2d1c2"))
        g.draw_circle(p+Vector2(0,-13),7,Color("#ab7054"))
        g.draw_circle(p+Vector2(0,-20),9,Color("#76a684"))

static func window(g: Node2D, r: Rect2, warm: bool) -> void:
    g.draw_rect(r.grow(7),INK)
    g.draw_rect(r,Color("#263a56") if warm else Color("#6fabb9"))
    for i in range(8):
        var x=r.position.x+float(i)*r.size.x/8
        var h=20+float((i*23)%56)
        g.draw_rect(Rect2(x,r.end.y-h,r.size.x/8-4,h),Color("#172937"))
        for yy in range(8,int(h)-4,16):
            g.draw_rect(Rect2(x+5,r.end.y-h+yy,4,5),Color("#d6ad77") if warm else Color("#b1d7d1"))
    g.draw_line(Vector2(r.get_center().x,r.position.y),Vector2(r.get_center().x,r.end.y),Color("#ccd5c6"),5)
    g.draw_line(r.position+Vector2(0,r.size.y*.55),r.position+Vector2(r.size.x,r.size.y*.55),Color("#ccd5c6"),5)
    g.draw_colored_polygon(PackedVector2Array([r.position+Vector2(8,8),r.position+Vector2(40,8),r.end-Vector2(20,8),r.end-Vector2(48,8)]),Color(1,1,1,0.09))

static func shelf(g: Node2D, r: Rect2, bottles: bool=false) -> void:
    box(g,r,Color("#4b4f51") if not bottles else Color("#624833"),23)
    for row in range(3):
        var y=r.position.y+float(row+1)*r.size.y/3-10
        for col in range(maxi(3,int(r.size.x/35))):
            var x=r.position.x+15+float(col)*32
            var color=[Color("#94b98a"),Color("#cc9a65"),Color("#82adc1"),Color("#b681a3")][(col+row)%4]
            if bottles:
                g.draw_rect(Rect2(x,y-22,13,23),color)
                g.draw_rect(Rect2(x+4,y-31,5,10),color.darkened(0.14))
                g.draw_rect(Rect2(x+1,y-12,11,7),Color("#e8d4af"))
            else:
                g.draw_rect(Rect2(x,y-24,22,22),color)
                g.draw_rect(Rect2(x+3,y-20,16,5),color.lightened(0.3))
        g.draw_line(Vector2(r.position.x+4,y+4),Vector2(r.end.x-4,y+4),Color("#afa086"),4)

static func kitchen(g: Node2D, r: Rect2) -> void:
    box(g,r,Color("#bdc5bb"),18)
    var stove=Rect2(r.position+Vector2(15,12),Vector2(90,r.size.y-38))
    g.draw_rect(stove,Color("#303e44"))
    for x in [23,67]:
        for y in [28,73]:
            g.draw_circle(stove.position+Vector2(x,y),15,Color("#75858b"))
            g.draw_circle(stove.position+Vector2(x,y),9,Color("#293b42"))
    var sink=Rect2(r.end-Vector2(100,r.size.y-14),Vector2(70,r.size.y-44))
    g.draw_rect(sink,Color("#859b9e"))
    g.draw_rect(sink.grow(-7),Color("#46616b"))
    g.draw_arc(sink.get_center()-Vector2(0,10),14,PI,TAU,12,Color("#d0ddd8"),4,true)

static func car(g: Node2D, p: Vector2, variant: int) -> void:
    var cell=CARS.get_size()/Vector2(3,4)
    var source=Rect2(Vector2(variant%3,int(variant/3))*cell,cell)
    g.draw_texture_rect_region(CARS,Rect2(p-Vector2(80,190),Vector2(160,340)),source)

static func person(g: Node2D, p: Vector2, heading: float, outfit: int, moving: bool, seated: bool=false) -> void:
    var forward=Vector2.from_angle(heading)
    var dir=3 if forward.x>0 else 1
    if absf(forward.y)>absf(forward.x): dir=0 if forward.y>0 else 2
    var cell=PEOPLE.get_size()/4
    var bob=absf(sin(Time.get_ticks_msec()/95.0))*2 if moving else 0.0
    g.draw_circle(p+Vector2(1,3),13,Color(0,0,0,0.24))
    var source=Rect2(Vector2(dir,outfit)*cell,cell)
    if seated:
        source.size.y*=0.74
        g.draw_texture_rect_region(PEOPLE,Rect2(p-Vector2(32,68),Vector2(64,58)),source)
    else:
        g.draw_texture_rect_region(PEOPLE,Rect2(p-Vector2(36,83+bob),Vector2(72,88)),source)

static func draw_room(g: Node2D) -> void:
    var kind: String=g.interior_kind
    var floor_index: int=g.interior_floor
    var warm: bool=kind in ["bar","cafe","restaurant","home"] and floor_index==0
    var floor_color=Color("#735c48") if warm else Color("#566872")
    if kind=="bar": floor_color=Color("#5d4545")
    if kind=="roof": floor_color=Color("#4a5765")
    if kind=="sublevel": floor_color=Color("#34434a")
    var accent=Color("#f0b77d") if warm else Color(g.interior_accent)
    g.draw_set_transform(origin(g))
    var room=Rect2(Vector2.ZERO,g.interior_size)
    g.draw_rect(room.grow(15),Color(0,0,0,0.32))
    g.draw_rect(room,floor_color)
    if warm:
        for y in range(170,int(room.size.y),44):
            g.draw_line(Vector2(18,y),Vector2(room.size.x-18,y),Color("#372f33"),2)
            for x in range(30,int(room.size.x),160):
                var shifted=x+(80 if int(y/44)%2==0 else 0)
                g.draw_line(Vector2(shifted,y),Vector2(shifted,y+44),Color("#413a37"),1.5)
                g.draw_line(Vector2(shifted+13,y+17),Vector2(shifted+115,y+17),Color(0.86,0.72,0.48,0.09),1.2)
    else:
        for y in range(170,int(room.size.y),64):
            for x in range(20,int(room.size.x)-30,64):
                g.draw_rect(Rect2(x,y,60,60),floor_color.lightened(0.035 if (int(x/64)+int(y/64))%2==0 else -0.015))
        for x in range(20,int(room.size.x),64):
            g.draw_line(Vector2(x,170),Vector2(x,room.size.y-15),Color(0.03,0.07,0.09,0.19),1)
    # Cutaway back wall, side skirting, sconces and window light give the room depth.
    box(g,Rect2(0,24,room.size.x,146),Color("#394650") if not warm else Color("#695041"),24)
    g.draw_rect(Rect2(0,170,18,room.size.y-170),INK)
    g.draw_rect(Rect2(room.size.x-18,170,18,room.size.y-170),INK)
    g.draw_rect(Rect2(0,room.size.y-18,room.size.x,18),INK)
    for p in [Vector2(100,205),Vector2(810,205),Vector2(100,980),Vector2(810,980)]:
        for radius in [72,52,32]:
            g.draw_circle(p,radius,Color(accent,0.035))
        box(g,Rect2(p-Vector2(10,25),Vector2(20,30)),Color("#ddbe83"),5)
    if kind not in ["roof","sublevel","bar"]:
        window(g,Rect2(40,54,180,82),warm)
        window(g,Rect2(700,54,180,82),warm)
    if kind=="bar":
        g.draw_rect(Rect2(250,42,355,85),Color("#243138"))
        g.draw_rect(Rect2(250,42,355,85),Color("#f3b387"),false,3)
    text(g,Vector2(265,80),title(kind,floor_index),32,accent,470)
    text(g,Vector2(265,118),g.interior_name,22,Color("#e4ddcf"),440)
    if kind=="bar":
        shelf(g,Rect2(80,100,170,130),true)
        shelf(g,Rect2(630,100,215,130),true)
        box(g,Rect2(90,245,470,120),Color("#a4764e"),24)
        for x in [165,280,390,495]:
            chair(g,Vector2(x,398),Color("#965c61"))
            g.draw_circle(Vector2(x,278),7,Color("#e3d3b1"))
        for x in [405,465]:
            g.draw_line(Vector2(x,295),Vector2(x,245),Color("#d7cda9"),8,true)
            g.draw_line(Vector2(x,245),Vector2(x-15,245),Color("#bdc2ab"),7,true)
        rug(g,Rect2(65,540,770,530),Color("#684459"))
        sofa(g,Rect2(70,620,235,90),Color("#8e555f"))
        sofa(g,Rect2(610,910,230,100),Color("#8e555f"))
        table(g,Vector2(660,575),55,Color("#a27a55"))
        table(g,Vector2(430,855),55,Color("#a27a55"))
        plant(g,Vector2(790,450),35)
        text(g,Vector2(80,500),"TRESEN",22,Color("#ecd3a3"))
    elif kind=="cafe":
        box(g,Rect2(550,190,280,140),Color("#be9d71"),22)
        box(g,Rect2(580,212,90,70),Color("#40565c"),15)
        g.draw_rect(Rect2(590,194,70,30),Color("#b4c6be"))
        for x in [705,750,790]:
            g.draw_circle(Vector2(x,251),16,Color("#e2b076"))
            g.draw_arc(Vector2(x,245),9,0,PI,12,Color("#987039"),3,true)
        for p in [Vector2(230,455),Vector2(665,605),Vector2(290,875)]: table(g,p,55,Color("#c7a36e"))
        sofa(g,Rect2(570,880,260,85),Color("#6c927b"))
        plant(g,Vector2(95,290),38)
        plant(g,Vector2(785,1040),30)
        text(g,Vector2(560,365),"KAFFEE & GEBÄCK",24,Color("#efdab4"))
    elif kind=="restaurant":
        kitchen(g,Rect2(610,190,240,205))
        for r in [Rect2(110,350,210,130),Rect2(355,640,210,130),Rect2(635,830,180,120)]:
            rug(g,r.grow(45),Color("#526758"))
            box(g,r,Color("#99744f"),15)
            for q in [r.position+Vector2(50,35),r.end-Vector2(50,45)]:
                g.draw_circle(q,24,Color("#e8e1cb"))
                g.draw_circle(q,14,Color("#ac9264"))
            chair(g,r.position+Vector2(-30,70),Color("#7f9a7c"))
            chair(g,r.end+Vector2(30,-60),Color("#7f9a7c"))
        text(g,Vector2(620,450),"KÜCHE / BESTELLEN",22)
        plant(g,Vector2(420,300),35)
    elif kind in ["garage","workshop"] or (kind=="home" and floor_index==1):
        for x in [100,390]:
            var bay=Rect2(x,280,255,530)
            g.draw_rect(bay,Color("#384a54"))
            g.draw_rect(bay,Color("#d7b969"),false,4)
            for side in [bay.position.x+18,bay.end.x-18]:
                box(g,Rect2(side,320,14,430),Color("#718687"),7)
            car(g,Vector2(x+125,545),1 if x==100 else 7)
        box(g,Rect2(675,210,170,125),Color("#9caeab"),20)
        g.draw_rect(Rect2(695,202,115,55),Color("#163c43"))
        g.draw_polyline(PackedVector2Array([Vector2(701,227),Vector2(725,227),Vector2(738,211),Vector2(749,242),Vector2(760,220),Vector2(800,220)]),Color("#73f3ce"),3,true)
        shelf(g,Rect2(70,870,215,70))
        for x in range(630,840,24):
            g.draw_line(Vector2(x,940),Vector2(x+12,920),Color("#d7b969"),6)
        text(g,Vector2(680,378),"DIAGNOSE",23,Color("#b8ddd1"),180)
        text(g,Vector2(130,845),"SERVICE 01",24)
        text(g,Vector2(420,845),"SERVICE 02",24)
    elif kind=="home":
        rug(g,Rect2(70,290,365,360),Color("#957565"))
        sofa(g,Rect2(90,350,270,120),Color("#789483"))
        box(g,Rect2(140,530,190,85),Color("#b79b70"),12)
        g.draw_rect(Rect2(185,523,70,32),Color("#eee4c9"))
        kitchen(g,Rect2(570,195,270,150))
        box(g,Rect2(90,710,215,185),Color("#b7ba9b"),15)
        g.draw_rect(Rect2(101,716,193,142),Color("#749795"))
        for x in [110,200]: box(g,Rect2(x,702,78,40),Color("#e4dfbf"),4)
        g.draw_line(Vector2(106,788),Vector2(290,788),Color("#e0cba7"),7)
        g.draw_line(Vector2(380,655),Vector2(380,750),Color("#9c8270"),16)
        g.draw_line(Vector2(380,855),Vector2(380,985),Color("#9c8270"),16)
        box(g,Rect2(620,715,220,65),Color("#b69d79"),18)
        box(g,Rect2(680,696,92,40),Color("#293c49"),12)
        g.draw_rect(Rect2(688,680,75,27),Color("#8baab1"))
        plant(g,Vector2(465,850),40)
        plant(g,Vector2(830,535),32)
        text(g,Vector2(620,820),"HAUS / GARAGE",24)
    elif kind=="shop":
        shelf(g,Rect2(100,370,150,450))
        shelf(g,Rect2(395,370,150,450))
        box(g,Rect2(650,200,190,95),Color("#ad9971"),18)
        box(g,Rect2(740,218,62,40),Color("#334853"),12)
        g.draw_rect(Rect2(745,205,48,24),Color("#73f3ce"))
        for p in [Vector2(700,770),Vector2(745,790),Vector2(720,830)]: box(g,Rect2(p,Vector2(55,50)),Color("#ad9068"),10)
        text(g,Vector2(670,355),"KASSE",26,Color("#d9e5af"))
        text(g,Vector2(100,870),"AUSRÜSTUNG",23)
        text(g,Vector2(395,870),"VORRÄTE",23)
        plant(g,Vector2(800,1030),35)
    elif kind=="hospital":
        box(g,Rect2(320,225,520,90),Color("#ced8c9"),18)
        for p in [Vector2(435,250),Vector2(705,250)]:
            box(g,Rect2(p-Vector2(35,25),Vector2(70,40)),Color("#425d65"),12)
            g.draw_rect(Rect2(p-Vector2(27,35),Vector2(54,26)),Color("#9dd9c7"))
        for y in [430,800]:
            box(g,Rect2(95,y,240,190),Color("#a4bcbb"),18)
            g.draw_rect(Rect2(110,y+10,210,140),Color("#e2e6d6"))
            box(g,Rect2(115,y,195,40),Color("#bacfc5"),5)
            g.draw_line(Vector2(78,y-50),Vector2(350,y-50),Color("#b4d4cf"),9)
        for y in [680,880]:
            for x in [640,720,800]: chair(g,Vector2(x,y),Color("#679b99"))
        g.draw_rect(Rect2(250,60,18,66),Color("#83e3c5"))
        g.draw_rect(Rect2(226,84,66,18),Color("#83e3c5"))
        text(g,Vector2(620,368),"TRIAGE / HILFE",24)
        text(g,Vector2(115,730),"BEHANDLUNG",23)
    elif kind=="openai_hq":
        box(g,Rect2(310,205,305,110),Color("#aec6bf"),18)
        for x in [350,455,560]:
            g.draw_circle(Vector2(x,255),26,Color("#354f56"))
            g.draw_circle(Vector2(x,245),16,Color("#bce3d0"))
        for r in [Rect2(95,545,240,160),Rect2(585,545,240,160)]:
            box(g,r,Color("#b9c8b9"),18)
            box(g,Rect2(r.position+Vector2(40,20),Vector2(160,68)),Color("#34565d"),10)
            g.draw_rect(Rect2(r.position+Vector2(50,10),Vector2(140,50)),Color("#8ac5b1"))
            for i in range(5):
                g.draw_line(r.position+Vector2(60,22+i*7),r.position+Vector2(130+i*9,22+i*7),Color("#cde7d4"),2)
        sofa(g,Rect2(345,870,230,90),Color("#62897e"))
        plant(g,Vector2(175,400),42)
        plant(g,Vector2(755,420),42)
        text(g,Vector2(320,365),"INTERAKTIVE AUSSTELLUNG",25)
    elif kind=="roof":
        g.draw_rect(Rect2(0,-170,920,340),Color("#26394e"))
        for i in range(14):
            var h=50+(i*43)%110
            g.draw_rect(Rect2(i*69,170-h,60,h),Color("#182e3d"))
        g.draw_line(Vector2(20,184),Vector2(900,184),Color("#b5bdba"),9)
        for x in range(40,900,36): g.draw_line(Vector2(x,184),Vector2(x,225),Color("#718c92"),4)
        for r in [Rect2(110,640,270,215),Rect2(595,630,220,330)]:
            box(g,r,Color("#233b57"),10)
            for x in range(int(r.position.x)+6,int(r.end.x),32): g.draw_line(Vector2(x,r.position.y),Vector2(x,r.end.y-10),Color("#7398a8"),2)
            for y in range(int(r.position.y)+6,int(r.end.y),42): g.draw_line(Vector2(r.position.x,y),Vector2(r.end.x,y),Color("#7398a8"),2)
        box(g,Rect2(400,320,120,80),Color("#839ba0"),22)
        g.draw_line(Vector2(460,340),Vector2(460,222),Color("#bfd1c9"),12)
        g.draw_circle(Vector2(460,218),20,Color(g.interior_accent))
        for radius in [40,64,88]: g.draw_arc(Vector2(460,218),radius,PI*.15,PI*.85,24,Color(g.interior_accent,0.35),3,true)
        text(g,Vector2(355,425),"DACH-RELAY",28)
        plant(g,Vector2(155,1020),42)
        plant(g,Vector2(765,1030),42)
    else:
        for y in [100,180]:
            g.draw_line(Vector2(35,y),Vector2(885,y),Color("#9c7960"),14)
            g.draw_line(Vector2(35,y-3),Vector2(885,y-3),Color("#c5a082"),3)
        box(g,Rect2(320,230,280,130),Color("#57737a"),22)
        g.draw_rect(Rect2(345,235,230,75),Color("#153c47"))
        for i in range(7): g.draw_line(Vector2(360,250+i*7),Vector2(520+(i%3)*14,250+i*7),Color("#86d6c6"),3)
        for r in [Rect2(105,610,225,325),Rect2(640,620,180,300)]:
            shelf(g,r)
            for y in range(int(r.position.y)+20,int(r.end.y),65): g.draw_circle(Vector2(r.end.x-30,y),5,Color("#86d6c6"))
        text(g,Vector2(335,410),"INFRASTRUKTUR-KNOTEN",23)
    # Explicit approach marker, exit and stairs; fixtures never occupy these targets.
    var feature=feature_pos(kind,floor_index)
    g.draw_arc(feature,29,0,TAU,32,Color(g.interior_accent,0.70),2.5,true)
    g.draw_circle(feature,5,Color(g.interior_accent))
    var exit=Vector2(room.size.x*.5,room.size.y-48)
    var near=clampf(1.0-g.interior_player_pos.distance_to(exit)/135.0,0,1)
    g.draw_rect(Rect2(exit-Vector2(82,31),Vector2(164,66)),Color("#102c33"))
    for side in [-1,1]: box(g,Rect2(exit+Vector2(side*(40+near*37)-37,-25),Vector2(74,50)),Color("#739994"),4)
    text(g,exit+Vector2(-67,-52),"AUSGANG",25,Color("#d6ede1"),145)
    if kind in ["home","shop","restaurant","cafe","bar","hospital","openai_hq"]:
        var lift: Vector2=g._interior_elevator_pos()
        box(g,Rect2(lift-Vector2(45,30),Vector2(90,64)),Color("#455965"),10)
        g.draw_line(lift-Vector2(0,35),lift+Vector2(0,24),Color("#b3cfcc"),2)
        text(g,lift+Vector2(-50,-50),"ETAGE %d ↑" % (2 if floor_index==0 else 1),22,Color("#bfddd9"),160)
    # Patrons and staff use full sprites with room-scaled silhouettes.
    var patrons: Array=[]
    if kind=="bar": patrons=[Vector2(320,225),Vector2(749,575),Vector2(519,855)]
    elif kind=="cafe": patrons=[Vector2(319,455),Vector2(576,605),Vector2(785,182)]
    elif kind=="restaurant": patrons=[Vector2(60,410),Vector2(605,705),Vector2(560,270)]
    elif kind in ["garage","workshop"]: patrons=[Vector2(370,610),Vector2(680,210)]
    elif kind=="shop": patrons=[Vector2(340,760),Vector2(610,265)]
    elif kind=="hospital": patrons=[Vector2(500,205),Vector2(390,555),Vector2(610,600)]
    elif kind=="openai_hq": patrons=[Vector2(140,755),Vector2(660,755)]
    for i in range(patrons.size()): person(g,patrons[i],PI*.5,1+i%3,false,(kind=="bar" and i>0) or (kind=="cafe" and i<2))
    g.draw_set_transform(Vector2.ZERO)

static func draw_player(g: Node2D) -> void:
    g.draw_set_transform(origin(g))
    g.draw_arc(g.interior_player_pos,22,0,TAU,32,Color("#73f3ce"),2.5,true)
    person(g,g.interior_player_pos,g.player_heading,0,g.move_vec.length()>0.08 and not g._modal_active())
    g.draw_set_transform(Vector2.ZERO)
