extends RefCounted
## Recognizable physical campaign places and subtle saved consequences.
static func draw(g: Node2D) -> void:
    var art=g.NeighborhoodArt;var s: float=g.world_zoom
    for place in g.life_places:
        if not place.get("new126",false):continue
        var p: Vector2=place.get("scene",place.pos-Vector2(0,42))
        if not g._tile_visible(g._project(p),280):continue
        var kind:=str(place.kind)
        var gold:=Color("#e8c78e");var green:=Color("#648e83")
        if kind=="clock":
            art.slab(g,p,Vector2(36,30),110,green)
            var face: Vector2=g._project(p,130)
            g.draw_circle(face,26*s,Color("#f0e5c6"));g.draw_arc(face,26*s,0,TAU,40,Color("#52675e"),3*s,true)
            for i in range(12):
                var angle: float=float(i)*TAU/12
                g.draw_line(face+Vector2.from_angle(angle)*20*s,face+Vector2.from_angle(angle)*23*s,Color("#486056"),1.3*s,true)
            var hour: float=g.world_clock/12*TAU-PI*.5
            g.draw_line(face,face+Vector2.from_angle(hour)*13*s,Color("#486056"),2*s,true)
            g.draw_line(face,face+Vector2.from_angle(hour*12)*19*s,Color("#486056"),1.5*s,true)
        elif kind=="archive":
            for side in [-1.0,1.0]:
                art.slab(g,p+Vector2(side*39,0),Vector2(40,28),55,Color("#917755"))
                for z in [12.0,27.0,42.0]:
                    for x in range(4):art.slab(g,p+Vector2(side*39-12+x*8,17),Vector2(6,10),z,Color("#e5d9b8"))
            art.slab(g,p+Vector2(0,26),Vector2(62,24),25,green)
            art.polygon(g,[p+Vector2(-24,12),p+Vector2(22,12),p+Vector2(20,40),p+Vector2(-20,40)],27,Color("#f2e5c0"))
            var ending: String=str(Dictionary(g.campaign_state.get("choices",{})).get("ending",""))
            if ending.begins_with("Geschützte"):
                art.slab(g,p+Vector2(39,14),Vector2(36,9),54,Color("#658e89"))
                g.draw_circle(g._project(p+Vector2(39,20),30),4*s,Color("#e8c78e"))
            elif not ending.is_empty():
                for i in range(4):art.slab(g,p+Vector2(-19+i*13,40),Vector2(11,13),29,Color("#dbcbaa"))
        elif kind=="notice":
            for x in [-55.0,55.0]:g.draw_line(g._project(p+Vector2(x,0)),g._project(p+Vector2(x,0),95),Color("#736d50"),5*s,true)
            g.draw_colored_polygon(PackedVector2Array([g._project(p+Vector2(-60,0),30),g._project(p+Vector2(60,0),30),g._project(p+Vector2(60,0),100),g._project(p+Vector2(-60,0),100)]),Color("#b49767"))
            for i in range(6):
                var center: Vector2=g._project(p+Vector2(-38+(i%3)*37,0),45+(i/3)*30)
                g.draw_rect(Rect2(center-Vector2(11,10)*s,Vector2(22,22)*s),Color("#eaddbb") if i%2 else Color("#bfd1c2"))
        elif kind in ["repair","freight"]:
            art.slab(g,p,Vector2(110,42),27,Color("#8b7960"))
            if kind=="repair":
                for i in range(5):
                    var center: Vector2=g._project(p+Vector2(-35+i*17,0),29)
                    g.draw_line(center,center+Vector2(7,12)*s,Color("#d4dbca"),3*s,true)
                for side in [-1.0,1.0]:g.draw_circle(g._project(p+Vector2(side*44,15)),8*s,Color("#33473f"))
            else:
                for i in range(4):art.slab(g,p+Vector2(-38+i*25,0),Vector2(21,25),48,Color("#c2a078"))
                art.slab(g,p+Vector2(0,-40),Vector2(110,12),105,green)
        elif kind=="shelter":
            art.slab(g,p,Vector2(112,26),18,Color("#aa8c6a"))
            for side in [-1.0,1.0]:g.draw_line(g._project(p+Vector2(side*65,-15)),g._project(p+Vector2(side*65,-15),105),Color("#527a74"),3*s,true)
            art.polygon(g,[p+Vector2(-73,-28),p+Vector2(73,-28),p+Vector2(73,35),p+Vector2(-73,35)],105,Color(.52,.72,.72,.50))
            for i in range(4):art.planter(g,p+Vector2(-85+i*57,55),true)
        else:
            art.slab(g,p,Vector2(50,34),64,green)
            for i in range(3):g.draw_line(g._project(p+Vector2(-15+i*15,18),12),g._project(p+Vector2(-15+i*15,18),47),gold,2*s,true)
            for i in range(3):g.draw_circle(g._project(p+Vector2(-12+i*12,20),55),3*s,Color("#bfe9bf"))
            if kind=="signal":
                g.draw_line(g._project(p),g._project(p,118),Color("#8da79a"),2*s,true)
                g.draw_arc(g._project(p,117),26*s,PI,TAU,22,gold,2*s,true)
        g.CityArt.draw_character(g,place.pos+Vector2(-40,-10),PI*.5,int(place.id.length())%4,0,"chat")
    var station: Dictionary=g.RegionWorld.get_poi(g,"echo_station")
    if not station.is_empty() and g._tile_visible(g._project(station.pos),600):
        var roof:=Vector2(132475,42055)
        var axis: Vector2=g._project(roof,124)
        art.slab(g,roof,Vector2(20,20),125,Color("#6b827a"))
        g._draw_poly_ellipse(axis+Vector2(15,-17)*s,Vector2(34,15)*s,-.5,Color("#c4d1bf"))
        g._draw_poly_ellipse(axis+Vector2(15,-20)*s,Vector2(25,10)*s,-.5,Color("#89aba5"))
        g.draw_line(axis,axis+Vector2(37,-35)*s,Color("#d8c68e"),3*s,true)
        g.draw_circle(axis+Vector2(37,-35)*s,5*s,Color("#ecce89"))
    for entry in [["echo_station","AVEN",1],["ranger","SANA",2],["suburb_square","LEVIN",0]]:
        var person: Dictionary=g.RegionWorld.get_poi(g,entry[0])
        if person.is_empty() or not g._tile_visible(g._project(person.pos),160):continue
        var stand: Vector2=person.pos+Vector2(-33,-9)
        g.CityArt.draw_character(g,stand,PI*.5,int(entry[2]),0,"chat")
        if stand.distance_to(g.player_pos)<230:art.caption(g,stand+Vector2(-60,27),entry[1],Color("#e9d8b0"))
    var restored: bool=int(g.campaign_state.get("chapter",0))>=4
    if restored:
        for id in ["kiosk","archive","notice","stage"]:
            var p: Dictionary=g.CityLife.get_place(g,id)
            if p.is_empty() or not g._tile_visible(g._project(p.pos),230):continue
            for i in range(7):
                var point: Vector2=g._project(Vector2(p.pos)+Vector2(-85+i*27,-55),85+sin(float(i)*.5)*10)
                g.draw_circle(point,5*s,Color(.97,.78,.43,.13));g.draw_circle(point,2*s,Color("#f7d495"))
    if g._modal_active():return
    for lane in ["main","side"]:
        var target: Vector2=g.MainStory.target(g,lane)
        if target==Vector2.ZERO:continue
        var pixel: Vector2=g._project(target)
        if not g._tile_visible(pixel,80):continue
        var gold:=Color("#ebbf74") if lane=="main" else Color("#a7d3ae")
        g.draw_arc(pixel,26*s,0,TAU,40,Color(gold,.65),1.2*s,true)
        g.draw_circle(pixel-Vector2(0,38)*s,7*s,gold)
        g.draw_line(pixel-Vector2(0,26)*s,pixel-Vector2(0,17)*s,gold,2*s,true)
