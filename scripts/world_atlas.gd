extends Control
## Aspect-preserving paper atlas with explicit native touch ownership.
var game: Node
var mode: String="city"
var category: String="Ziele"
var selected: Callable
var center:=Vector2.ZERO
var zoom:=1.0
var scale_base:=1.0
var drag_start:=Vector2.ZERO
var last_drag:=Vector2.ZERO
var dragging:=false
var moved:=false
var initialized:=false
var touch_index: int=-1
var markers: Array=[]
var occupied_labels: Array[Rect2]=[]
func setup(g: Node,view: String,filter: String,callback: Callable) -> void:
    game=g;mode=view;category=filter;selected=callback
    clip_contents=true;mouse_filter=Control.MOUSE_FILTER_STOP
    custom_minimum_size=Vector2(0,780 if mode=="local" else 690)
    resized.connect(reset_view)
func reset_view() -> void:
    if game==null or size.x<100:return
    var extent: Vector2=game.WORLD_SIZE if mode=="region" else game.CITY_SIZE
    center=extent*.5
    if mode=="local":center=game.player_pos;extent=Vector2(3000,3000)
    scale_base=minf((size.x-42)/extent.x,(size.y-80)/extent.y)
    zoom=1;initialized=true;queue_redraw()
func zoom_by(factor: float) -> void:
    zoom=clampf(zoom*factor,.75,12);queue_redraw()
func recenter() -> void:
    center=game.player_pos;queue_redraw()
func point(world: Vector2) -> Vector2:
    return size*.5+(world-center)*scale_base*zoom
func unproject(pixel: Vector2) -> Vector2:
    return center+(pixel-size*.5)/maxf(.0001,scale_base*zoom)
func path(points: PackedVector2Array,color: Color,width: float) -> void:
    var line:=PackedVector2Array()
    for p in points:line.append(point(p))
    if line.size()>1:draw_polyline(line,color,width,true)
func box(rect: Rect2,color: Color,border: bool=false) -> void:
    var r:=Rect2(point(rect.position),rect.size*scale_base*zoom)
    if not r.intersects(Rect2(Vector2.ZERO,size)):return
    if border:draw_rect(r,color,false,1,true)
    else:draw_rect(r,color)
func text(p: Vector2,title: String,font_size: int,color: Color,width: float=230) -> void:
    draw_string(ThemeDB.fallback_font,p,title,HORIZONTAL_ALIGNMENT_LEFT,width,font_size,color)
func place_label(pixel: Vector2,title: String,color: Color) -> void:
    var label: String=title.split(" · ")[0]
    var width: float=minf(220,ThemeDB.fallback_font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x)
    for offset in [Vector2(18,-11),Vector2(18,22),Vector2(-width-18,-11),Vector2(-width-18,22)]:
        var r:=Rect2(pixel+offset-Vector2(2,16),Vector2(width+6,22))
        if not Rect2(Vector2(22,42),size-Vector2(44,85)).encloses(r):continue
        if occupied_labels.any(func(other):return other.intersects(r)):continue
        text(pixel+offset,label,16,color,width+4);occupied_labels.append(r);return
func _draw() -> void:
    if game==null:return
    if not initialized:reset_view()
    var ink:=Color("#354f4a")
    occupied_labels.clear()
    draw_rect(Rect2(Vector2.ZERO,size),Color("#dad5bd"))
    for i in range(11):
        var contour:=PackedVector2Array()
        for k in range(30):contour.append(Vector2(float(k)*size.x/29,float(i)*72+sin(k*.24+i*.53)*38))
        draw_polyline(contour,Color(.37,.46,.34,.09),1,true)
    for item in game.world_regions:
        box(item.rect,{"meadow":Color("#c4c89a"),"forest":Color("#a8bea0"),"lake":Color("#b4c9ac"),"wild":Color("#c4bea2"),"suburb":Color("#d6cdb0"),"heath":Color("#cabaac"),"village":Color("#d8cfb5")}.get(str(item.style),Color("#c4c89a")))
    box(game.world_regions[0].rect,Color("#d7cfb5"))
    for item in game.world_regions:
        if str(item.style)=="village":box(item.rect,Color("#d8cfb5"))
    for d in game.districts:
        box(d.rect,Color("#c7ccbf").lerp(Color(d.accent),.1))
        if mode!="region" and zoom<4:
            var r: Rect2=d.rect
            text(point(r.position)+Vector2(10,23),str(d.name).to_upper(),14,Color("#667b70"),r.size.x*scale_base*zoom-18)
    if mode!="region" or zoom>2:
        for b in game.buildings:
            var rect: Rect2=b.rect
            var r:=Rect2(point(rect.position),rect.size*scale_base*zoom)
            if r.size.x<1.2 or not r.intersects(Rect2(Vector2.ZERO,size)):continue
            draw_rect(r,Color("#b1937b") if b.get("regional",false) else Color("#90a397"))
            if r.size.x>10:draw_rect(r,Color("#72867a"),false,.8)
    for p in game.parks:box(p.rect,Color("#a4ba8e"))
    for w in game.waters:
        if w.has("polygon"):
            var poly:=PackedVector2Array()
            for p in w.polygon:poly.append(point(p))
            draw_colored_polygon(poly,Color("#82b4ba"));poly.append(poly[0]);draw_polyline(poly,Color("#d8e0c1"),2,true)
        else:box(w.rect,Color("#82b4ba"))
    for road in game.roads:
        var width: float=maxf(1.4,float(road.width)*scale_base*zoom)
        var regional: bool=bool(road.get("regional",false));var trail: bool=str(road.get("kind",""))=="trail"
        path(road.points,Color("#a99b7f") if regional else Color("#a2aea1"),width+2.3)
        path(road.points,Color("#ded4ac") if trail else (Color("#f0d997") if regional else Color("#f4f0d8")),width)
    if mode=="region" and zoom<2:
        for entry in [[Vector2(8500,1600),"MEGACITY",21],[Vector2(30700,5600),"SONNENHAGEN",20],[Vector2(27000,25000),"LINDENFELDER",19],[Vector2(55000,4800),"FICHTENWALD",21],[Vector2(70300,9500),"HOHES FREILAND",18],[Vector2(87700,11600),"HEIDEKAMM",18],[Vector2(92300,27900),"MÜHLENAU",19]]:
            var p: Vector2=point(entry[0]);text(p,entry[1],int(entry[2]),ink,260)
            occupied_labels.append(Rect2(p-Vector2(0,23),Vector2(210,28)))
    markers=build_markers()
    for m in markers:
        var pixel:=point(Vector2(m.pos))
        if not Rect2(Vector2(22,42),size-Vector2(44,80)).has_point(pixel):continue
        draw_circle(pixel+Vector2(1,2),13,Color(.20,.29,.25,.30));draw_circle(pixel,11,Color("#fbf4d6"))
        draw_circle(pixel,11,Color(m.color),false,2,true);text(pixel+Vector2(-6,5),str(m.glyph),15,Color(m.color),15)
        if mode=="local" or mode=="region" and category!="Fotos":place_label(pixel,str(m.name),ink)
    var target: Vector2=game._current_objective_pos()
    if not game.navigation_route.is_empty():path(game.navigation_route,Color(.29,.37,.28,.52),5.5);path(game.navigation_route,Color("#ddac53"),3.4)
    if target!=Vector2.ZERO:
        var pin:=point(target)
        draw_circle(pin,18,Color("#fff4ce"),false,5,true);draw_circle(pin,18,Color("#ba7b30"),false,2,true)
        draw_line(pin-Vector2(23,0),pin+Vector2(23,0),Color("#ba7b30"),2,true);draw_line(pin-Vector2(0,23),pin+Vector2(0,23),Color("#ba7b30"),2,true)
    var player:=point(game.player_pos)
    draw_circle(player,17,Color("#fbf4d6"));draw_circle(player,12,Color("#35695d"))
    var direction:=Vector2.from_angle(game.player_heading)
    draw_colored_polygon(PackedVector2Array([player+direction*19,player+direction.rotated(2.45)*8,player+direction.rotated(-2.45)*8]),Color("#fcf7e2"))
    var north:=Vector2(size.x-44,57)
    draw_colored_polygon(PackedVector2Array([north+Vector2(0,-20),north+Vector2(-7,8),north+Vector2(7,8)]),ink);text(north+Vector2(-6,-26),"N",18,ink,18)
    var units: float=5000 if mode=="region" and zoom<3 else (1000 if mode=="city" and zoom<3 else 250)
    var bar: float=units*scale_base*zoom
    while bar>size.x*.4:units*=.5;bar=units*scale_base*zoom
    var origin:=Vector2(26,size.y-30)
    draw_line(origin,origin+Vector2(bar,0),ink,3,true)
    for x in [0.0,bar]:draw_line(origin+Vector2(x,-5),origin+Vector2(x,5),ink,2,true)
    text(origin+Vector2(0,-13),"%d m" % int(units/10),17,ink,120)
    text(Vector2(24,32),"PARALLAX  /  "+{"city":"STADTATLAS","region":"UMLAND","local":"DEINE UMGEBUNG"}.get(mode,"ATLAS"),20,ink,size.x-110)
    draw_rect(Rect2(Vector2.ONE,size-Vector2(2,2)),Color("#738e7a"),false,2,true)
func build_markers() -> Array:
    var result: Array=[]
    if mode=="region" and zoom<2 and category in ["Ziele","Orte"]:
        result.append({"pos":Vector2(5100,4220),"name":"Zentrum","glyph":"C","color":Color("#52756c")})
        for p in game.region_pois:
            if str(p.id) in ["suburb_square","lake_view","trailhead","ranger","ridge_view","far_view","village_square","old_mill","south_view"]:result.append(marker_data(p))
        return result
    if category=="Erleben":
        for p in game.life_places:result.append({"pos":p.pos,"name":p.name,"glyph":"★" if game.life_seen.get(p.id,false) else "!","color":Color("#84693e")})
        return result
    if category=="Transit":
        for p in game.region_pois:
            if p.kind=="bus":result.append(marker_data(p))
        if mode!="region" or zoom>=2:
            for s in game.transit_stops:result.append({"pos":s.pos,"name":"Bus / Tram","glyph":"B","color":Color("#3b8792")})
    elif category=="Fotos":
        for p in game.photo_points:result.append({"pos":p.pos,"name":p.label,"glyph":"F","color":Color("#826888")})
        for p in game.region_pois:
            if p.kind=="view":result.append(marker_data(p))
    else:
        for p in game.region_pois:result.append(marker_data(p))
        if category=="Orte":
            for p in game.life_places:result.append({"pos":p.pos,"name":p.name,"glyph":"K","color":Color("#84693e")})
            for p in game.landmarks:result.append({"pos":p.pos,"name":p.name,"glyph":"+","color":Color("#698475")})
            for p in game.storefronts:result.append({"pos":p.pos,"name":p.name,"glyph":"S","color":Color("#926d45")})
        else:
            for p in game.named_npcs:result.append({"pos":p.pos,"name":p.name,"glyph":"N","color":Color("#467969")})
            for p in game.mission_sites:result.append({"pos":p.pos,"name":str(p.get("label",p.id)),"glyph":"!","color":Color("#9b7337")})
            for p in game.side_job_sites:result.append({"pos":p.pos,"name":"Stadtaufträge","glyph":"J","color":Color("#4c7d5b")})
            for p in game.vertical_sites:result.append({"pos":p.pos,"name":str(p.get("label","Dachzugang")),"glyph":"↑","color":Color("#477e98")})
            for p in game.property_sites:result.append({"pos":p.pos,"name":str(p.get("name","Wohnung / Garage")),"glyph":"H","color":Color("#826888")})
            for p in game.race_sites:result.append({"pos":p.pos,"name":str(p.name),"glyph":"R","color":Color("#9b7337")})
    return result
func marker_data(p: Dictionary) -> Dictionary:
    var glyphs: Dictionary={"bus":"B","cafe":"C","garage":"G","rest":"R","camp":"T","view":"V","ranger":"W","farm":"H","square":"S","bridge":"+","sign":"→","race":"R"}
    return {"pos":p.pos,"name":p.name,"glyph":glyphs.get(str(p.kind),"●"),"color":Color("#3e7866") if p.kind in ["rest","camp","ranger"] else Color("#976c3e")}
func select_point(pixel: Vector2) -> void:
    var world: Vector2=unproject(pixel).clamp(Vector2(30,30),game.WORLD_SIZE-Vector2(30,30))
    var name: String="Wegpunkt";var best:=28.0
    for m in markers:
        var d: float=point(m.pos).distance_to(pixel)
        if d<best:best=d;world=m.pos;name=m.name
    world=game.CityAccess.safe_point(game,world);selected.call({"pos":world,"name":name})
func _input(event: InputEvent) -> void:
    if not is_visible_in_tree() or (not event is InputEventScreenTouch and not event is InputEventScreenDrag):return
    var local: Vector2=get_global_transform_with_canvas().affine_inverse()*event.position
    var inside: bool=Rect2(Vector2.ZERO,size).has_point(local)
    if event is InputEventScreenTouch:
        if not inside and event.index!=touch_index:return
    elif event.index!=touch_index:return
    var converted: InputEvent=event.duplicate();converted.position=local
    _gui_input(converted);get_viewport().set_input_as_handled()
func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and touch_index<0:touch_index=event.index;dragging=true;moved=false;drag_start=event.position;last_drag=event.position
        elif not event.pressed and event.index==touch_index:
            if not moved:select_point(event.position)
            touch_index=-1;dragging=false
        accept_event()
    elif event is InputEventScreenDrag and event.index==touch_index:
        if event.position.distance_to(drag_start)>12:moved=true
        if moved:center-=(event.position-last_drag)/maxf(.0001,scale_base*zoom);center=center.clamp(Vector2.ZERO,game.WORLD_SIZE);queue_redraw()
        last_drag=event.position;accept_event()
    elif event is InputEventMouseButton:
        if event.device<0:return
        if event.button_index==MOUSE_BUTTON_WHEEL_UP and event.pressed:zoom_by(1.25);accept_event();return
        if event.button_index==MOUSE_BUTTON_WHEEL_DOWN and event.pressed:zoom_by(.8);accept_event();return
        if event.button_index==MOUSE_BUTTON_LEFT:
            if event.pressed:dragging=true;moved=false;drag_start=event.position;last_drag=event.position
            else:
                if dragging and not moved:select_point(event.position)
                dragging=false
            accept_event()
    elif event is InputEventMouseMotion and dragging:
        if event.device<0:return
        if event.position.distance_to(drag_start)>12:moved=true
        if moved:center-=(event.position-last_drag)/maxf(.0001,scale_base*zoom);center=center.clamp(Vector2.ZERO,game.WORLD_SIZE);queue_redraw()
        last_drag=event.position;accept_event()
    elif event is InputEventMagnifyGesture:zoom_by(event.factor);accept_event()
    elif event is InputEventPanGesture:center+=event.delta*40/maxf(.0001,scale_base*zoom);queue_redraw();accept_event()
