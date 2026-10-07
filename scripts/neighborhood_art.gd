extends RefCounted
## Small authored street scenes make useful places recognizable at pedestrian zoom.
static func polygon(g: Node2D,points: Array,z: float,tint: Color,outline: bool=true) -> void:
    var shape:=PackedVector2Array()
    for p in points:shape.append(g._project(p,z))
    g.draw_colored_polygon(shape,tint)
    if outline:shape.append(shape[0]);g.draw_polyline(shape,Color("#263b39"),1.2*g.world_zoom,true)
static func slab(g: Node2D,p: Vector2,size: Vector2,height: float,tint: Color) -> void:
    var corners: Array=[p-size*.5,p+Vector2(size.x,-size.y)*.5,p+size*.5,p+Vector2(-size.x,size.y)*.5]
    for edge in [1,2]:
        var next: int=(edge+1)%4
        g.draw_colored_polygon(PackedVector2Array([g._project(corners[edge]),g._project(corners[next]),g._project(corners[next],height),g._project(corners[edge],height)]),tint.darkened(.3 if edge==1 else .15))
    polygon(g,corners,height,tint)
static func caption(g: Node2D,p: Vector2,title: String,tint: Color,z: float=0) -> void:
    var scale: float=g.world_zoom
    var screen: Vector2=g._project(p,z)
    g.draw_string(ThemeDB.fallback_font,screen+Vector2(1,2)*scale,title,HORIZONTAL_ALIGNMENT_CENTER,210*scale,maxi(12,int(10*scale)),Color("#152d2a"))
    g.draw_string(ThemeDB.fallback_font,screen,title,HORIZONTAL_ALIGNMENT_CENTER,210*scale,maxi(12,int(10*scale)),tint)
static func planter(g: Node2D,p: Vector2,flowers: bool) -> void:
    slab(g,p,Vector2(28,20),13,Color("#a67d60"))
    for i in range(6):
        var center: Vector2=g._project(p+Vector2((i%3-1)*7,(i/3-.5)*7),19)
        g.draw_circle(center,5*g.world_zoom,Color("#648956"))
        if flowers:g.draw_circle(center-Vector2(1,3)*g.world_zoom,2.4*g.world_zoom,[Color("#f3c677"),Color("#eda8b3"),Color("#c0a4d2")][i%3])
static func dog(g: Node2D,p: Vector2) -> void:
    var scale: float=g.world_zoom;var screen: Vector2=g._project(p)
    g._draw_poly_ellipse(screen+Vector2(1,3)*scale,Vector2(12,5)*scale,0,Color(.04,.08,.07,.3))
    for side in [-1.0,1.0]:g.draw_line(screen+Vector2(side*6,-4)*scale,screen+Vector2(side*6,1)*scale,Color("#dbc8a2"),4*scale,true)
    g._draw_poly_ellipse(screen-Vector2(0,9)*scale,Vector2(10,7)*scale,0,Color("#c2a47b"))
    g.draw_circle(screen-Vector2(0,17)*scale,7*scale,Color("#ebd4a6"))
    for side in [-1.0,1.0]:
        g._draw_poly_ellipse(screen+Vector2(side*7,-17)*scale,Vector2(3,6)*scale,side*.4,Color("#82583f"))
        g.draw_circle(screen+Vector2(side*2.7,-19)*scale,1.1*scale,Color("#273d36"))
    g.draw_circle(screen-Vector2(0,15)*scale,1.8*scale,Color("#34413a"))
    g.draw_line(screen+Vector2(8,-7)*scale,screen+Vector2(14,-14+sin(Time.get_ticks_msec()*.009)*3)*scale,Color("#bf9b6f"),3*scale,true)
static func pico_position(g: Node) -> Vector2:
    var progress: int=int(g.life_progress.get("pico",0))
    if progress==3 and (g.life_active=="pico" or not g.life_completed.get("pico",false)):return g.player_pos+Vector2(-23,9)
    if g.life_active=="pico" or not g.life_completed.get("pico",false):return Vector2(g.CityLife.get_place(g,"dog").pos)-Vector2(0,15)
    return Vector2(g.CityLife.get_place(g,"kiosk").pos)+Vector2(48,4)
static func draw(g: Node2D) -> void:
    var s: float=g.world_zoom
    for place in g.life_places:
        var p: Vector2=place.pos;var kind: String=place.kind;var screen: Vector2=g._project(p)
        if not g._tile_visible(screen,260):continue
        var scene: Vector2=place.get("scene",p+Vector2(0,-42))
        if place.has("plaza"):
            var plaza: Rect2=place.plaza
            for x in range(10):
                for y in range(9):
                    var tile:=plaza.position+Vector2(x*30,y*25.5)
                    g.draw_rect(Rect2(g._project(tile),Vector2(29,24.5)*s),Color("#9da58e") if (x+y)%4 else Color("#abb19b"))
            for point in [Vector2(-126,-88),Vector2(126,-88),Vector2(126,84),Vector2(-126,84)]:planter(g,scene+point,true)
        if kind in ["kiosk","flowers","post","recycling"]:
            var color: Color={"kiosk":Color("#709a8a"),"flowers":Color("#cb9aab"),"post":Color("#6095ab"),"recycling":Color("#8da77d")}[kind]
            slab(g,scene,Vector2(68,34),32,color)
            polygon(g,[scene+Vector2(-43,-24),scene+Vector2(43,-24),scene+Vector2(43,25),scene+Vector2(-43,25)],61,color.lightened(.18))
            for k in range(7):
                var a: Vector2=scene+Vector2(-39+k*12,-24)
                g.draw_line(g._project(a,61),g._project(a+Vector2(0,49),61),Color("#efdec0"),4*s,true)
            for side in [-1.0,1.0]:g.draw_line(g._project(scene+Vector2(side*38,22)),g._project(scene+Vector2(side*38,22),60),Color("#3a514b"),2*s,true)
            if kind=="flowers":
                for x in [-26,0,26]:planter(g,scene+Vector2(x,20),true)
            elif kind=="post":
                for x in [-22,0,22]:slab(g,scene+Vector2(x,20),Vector2(16,14),22,Color("#d0af7e"))
            else:
                for x in [-24,-8,8,24]:g.draw_line(g._project(scene+Vector2(x,18),34),g._project(scene+Vector2(x,27),34),Color("#ead8b9"),10*s,true)
            caption(g,scene-Vector2(105,0),{"kiosk":"LINDENKIOSK","flowers":"NELAS BLUMEN","post":"POST & PAKETE","recycling":"NOCH GUT"}[kind],Color("#fff1c9"),63)
            g.CityArt.draw_character(g,p+Vector2(-31,-5),PI*.5,1 if kind=="kiosk" else 2,0,"chat")
        elif kind in ["books","records","atelier","arcade"]:
            slab(g,scene,Vector2(78,34),51,Color("#826d56") if kind=="books" else Color("#557a78"))
            for row in range(3):
                var z: float=10+row*16
                for k in range(8):
                    var point: Vector2=scene+Vector2(-30+k*8,18)
                    if kind=="records":g.draw_circle(g._project(point,z),4*s,Color("#29383a"));g.draw_circle(g._project(point,z),1.6*s,Color("#e7c794"))
                    else:g.draw_line(g._project(point,z),g._project(point,z+10),[Color("#d99e80"),Color("#b6cfaf"),Color("#d8c993"),Color("#89b4bb")][k%4],5*s,true)
            planter(g,scene+Vector2(58,4),true)
            caption(g,scene-Vector2(105,0),{"books":"GESCHICHTEN","records":"SAM · VINYL","atelier":"ADA · ATELIER","arcade":"RÄTSELTISCH"}[kind],Color("#f6dfb1"),56)
        elif kind=="garden":
            for side in [-1.0,1.0]:
                slab(g,scene+Vector2(side*36,0),Vector2(50,65),10,Color("#9d7758"))
                for x in range(3):
                    for y in range(4):
                        var plant: Vector2=scene+Vector2(side*36+(x-1)*14,(y-1.5)*14)
                        var tip: Vector2=g._project(plant,17)
                        g.draw_line(g._project(plant,10),tip,Color("#63854b"),2*s,true)
                        g.draw_circle(tip,4*s,Color("#e6b465") if g.life_completed.get("garden",false) else Color("#81985a"))
            g.draw_line(g._project(scene+Vector2(-73,40),12),g._project(scene+Vector2(73,40),12),Color("#c0b089"),2*s,true)
        elif kind=="fountain":
            g._draw_poly_ellipse(g._project(scene),Vector2(58,35)*s,0,Color("#bdb29c"))
            g._draw_poly_ellipse(g._project(scene,5),Vector2(48,27)*s,0,Color("#599b9a"))
            var radius: float=8+fposmod(Time.get_ticks_msec()*.012,22)
            g.draw_arc(g._project(scene,5),radius*s,0,TAU,24,Color(.8,.94,.86,.45),1.2*s,true)
            g.draw_line(g._project(scene,4),g._project(scene,38),Color("#b6ddd4"),2*s,true)
            for side in [-1.0,1.0]:planter(g,scene+Vector2(side*80,10),true)
        elif kind=="dog":
            for side in [-1.0,1.0]:
                var base: Vector2=scene+Vector2(side*40,0)
                g.draw_line(g._project(base),g._project(base,74),Color("#607558"),3*s,true);planter(g,base,true)
            g.draw_arc(g._project(scene,73),41*s,PI,TAU,24,Color("#81955f"),4*s,true)
        elif kind=="stage":
            slab(g,scene,Vector2(165,90),16,Color("#9b7859"))
            for x in range(-70,80,14):g.draw_line(g._project(scene+Vector2(x,-40),16),g._project(scene+Vector2(x,40),16),Color("#c19b70"),s,true)
            for side in [-1.0,1.0]:slab(g,scene+Vector2(side*64,-27),Vector2(23,19),46,Color("#314743"))
            var lit: bool=g.life_completed.get("festival",false)
            for i in range(9):
                var point: Vector2=scene+Vector2(-95+i*24,-26)
                var next: Vector2=point+Vector2(24,0)
                g.draw_line(g._project(point,95+sin(i*.38)*12),g._project(next,95+sin((i+1)*.38)*12),Color("#43544a"),s,true)
                g.draw_circle(g._project(point,92+sin(i*.38)*12),3.5*s,Color("#f8d891") if lit else Color("#9daf8e"))
            g.CityArt.draw_character(g,scene,0,2,0,"chat")
            if lit:
                for i in range(4):
                    var actor: Vector2=p+Vector2(-85+i*55,38)
                    if not g._point_blocked(actor,16):g.CityArt.draw_character(g,actor,-PI*.5,i%4,.3,"chat")
        elif kind in ["utility","antenna"]:
            slab(g,scene,Vector2(30,25),40,Color("#69847d"))
            g.draw_circle(g._project(scene+Vector2(0,14),28),3*s,Color("#a6e2b6"))
            if kind=="antenna":
                g.draw_line(g._project(scene,35),g._project(scene,120),Color("#8aa39a"),2*s,true)
                for h in [65.0,92.0,112.0]:g.draw_line(g._project(scene-Vector2(22,0),h),g._project(scene+Vector2(22,0),h),Color("#bdd0ba"),2*s,true)
        elif kind=="mural":
            var left: Vector2=scene-Vector2(82,0);var right: Vector2=scene+Vector2(82,0)
            g.draw_colored_polygon(PackedVector2Array([g._project(left),g._project(right),g._project(right,110),g._project(left,110)]),Color("#6b8680"))
            if g.life_completed.get("mural",false):
                g.draw_circle(g._project(scene+Vector2(24,0),73),22*s,Color("#eac278"))
                for k in range(3):
                    var wave:=PackedVector2Array()
                    for i in range(25):wave.append(g._project(scene+Vector2(-80+i*6.5,0),24+k*15+sin(i*.32+k)*7))
                    g.draw_polyline(wave,Color("#7dd1c7"),5*s,true)
            else:
                for x in range(-72,80,24):g.draw_line(g._project(scene+Vector2(x,0),4),g._project(scene+Vector2(x,0),105),Color("#82958b"),s,true)
        elif kind=="bench":
            slab(g,scene,Vector2(76,27),18,Color("#aa8765"));planter(g,scene+Vector2(56,0),true)
        if g._modal_active():continue
        var active: bool=not g.CityLife.step(g).is_empty() and str(g.CityLife.step(g).at)==str(place.id)
        var tint:=Color("#f0ca8c") if active else Color("#c4d8c8")
        if p.distance_to(g.player_pos)<260:
            caption(g,p+Vector2(-105,65),str(place.name),tint)
            if not bool(g.life_seen.get(place.id,false)):g.draw_circle(g._project(p+Vector2(0,14)),3*s,Color("#eaca8d"))
    var pico: Vector2=pico_position(g)
    if g._tile_visible(g._project(pico),70):dog(g,pico)
