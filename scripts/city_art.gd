extends RefCounted
## One projection and one world scale for the playable comic city.
const ASPHALT = preload("res://assets/visual/materials/asphalt_ink.png")
const FACADES = preload("res://assets/visual/materials/facades_ink.png")
const VEHICLES = preload("res://assets/visual/materials/vehicles_ink.png")
const CHARACTERS = preload("res://assets/visual/materials/characters_ink.png")

static func character_direction(heading: float) -> int:
    var forward=Vector2.from_angle(heading)
    if absf(forward.x)>absf(forward.y):
        return 3 if forward.x>0 else 1
    return 0 if forward.y>0 else 2

static func draw_character(g: Node2D, pos: Vector2, heading: float, outfit: int, phase: float, state: String, tint: Color = Color.WHITE) -> void:
    var scale: float=g.world_zoom
    var foot: Vector2=g._project(pos)
    var moving: bool=state in ["walk","cross","run"]
    var bob: float=absf(sin(phase))*0.9*scale if moving else 0.0
    var lean: float=sin(phase)*0.018 if moving else 0.0
    var cell: Vector2=CHARACTERS.get_size()/4.0
    var source:=Rect2(Vector2(character_direction(heading),clampi(outfit,0,3))*cell,cell)
    var size:=Vector2(32.0,38.0)*scale
    var anchor:=foot+Vector2(0,-bob)
    g._draw_poly_ellipse(foot+Vector2(1,2)*scale,Vector2(5.4,2.8)*scale,0,Color(0,0,0,0.26))
    g.draw_set_transform(anchor,lean,Vector2.ONE)
    # Each direction uses the same foot pivot; no sprite rotates flat on the road.
    g.draw_texture_rect_region(CHARACTERS,Rect2(-Vector2(size.x*0.5,size.y*0.95),size),source,tint)
    g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
    var head: Vector2=anchor-Vector2(0,33)*scale
    if state=="chat":
        g.draw_circle(head+Vector2(8,-3)*scale,4.0*scale,Color("#e9f0e8"))
        for dot in [-1,0,1]:
            g.draw_circle(head+Vector2(8+dot*2,-3)*scale,0.5*scale,Color("#35434a"))
    elif state=="alert":
        g.draw_string(ThemeDB.fallback_font,head+Vector2(-3,-3)*scale,"!",HORIZONTAL_ALIGNMENT_CENTER,8*scale,int(10*scale),Color("#ffd275"))
    elif state=="phone":
        g.draw_rect(Rect2(anchor-Vector2(-5,19)*scale,Vector2(2,3.4)*scale),Color("#a5eff3"))
    if g._weather_state() in ["rain","storm"] and outfit!=2 and state!="sit":
        var canopy=head+Vector2(0,-6)*scale
        g.draw_line(canopy,anchor-Vector2(2,12)*scale,Color("#9eaaa9"),0.8*scale,true)
        g.draw_circle(canopy,8.5*scale,Color("#153143"))
        for wedge in range(6):
            var a=float(wedge)*TAU/6.0
            var b=float(wedge+1)*TAU/6.0
            g.draw_colored_polygon(PackedVector2Array([canopy,canopy+Vector2.from_angle(a)*8*scale,canopy+Vector2.from_angle(b)*8*scale]),Color("#578c9a") if wedge%2==0 else Color("#366775"))

static func facade_region(style: String, seed_value: int) -> Vector2:
    if style=="center" and seed_value%3==0:
        return Vector2(0.0,0.5)
    if style in ["glass", "center", "terminal", "data", "astro", "solar"]:
        return Vector2(0.5, 0.0)
    if style in ["industry", "harbor", "rail", "air"]:
        return Vector2(0.5, 0.5)
    if style in ["neon", "culture", "expo", "coast"]:
        return Vector2(0.0, 0.5)
    return Vector2.ZERO if seed_value % 4 != 0 else Vector2(0.0, 0.5)

static func draw_building(g: Node2D, b: Dictionary) -> void:
    var r: Rect2 = b.rect
    var z: float = float(b.height)
    var world = [r.position, Vector2(r.end.x,r.position.y), r.end, Vector2(r.position.x,r.end.y)]
    var base: Array[Vector2] = []
    var roof: Array[Vector2] = []
    for p in world:
        base.append(g._project(p))
        roof.append(g._project(p,z))
    var lift: Vector2 = roof[0]-base[0]
    var ink = Color("#11151c")
    var scale: float = g.world_zoom
    var seed_value: int = int(b.seed)
    var region = facade_region(str(b.style),seed_value)
    var shadow = PackedVector2Array()
    var sun_shift = Vector2(0.30,0.43)*z*scale
    for p in base:
        shadow.append(p+sun_shift)
    g.draw_colored_polygon(shadow,Color(0.015,0.018,0.024,0.20))
    for edge in range(4):
        var next = (edge+1)%4
        var edge_vec = base[next]-base[edge]
        var outward = Vector2(edge_vec.y,-edge_vec.x)
        # Back-facing walls used to be painted over front-facing walls.
        if outward.dot(lift)>=-0.01:
            continue
        var face = PackedVector2Array([base[edge],base[next],roof[next],roof[edge]])
        var shade = 0.78 if edge==1 else 1.0
        var tint = Color(shade,shade,shade,1.0)
        if g.graphics_quality>0:
            var uv = PackedVector2Array([region+Vector2(0.002,0.498),region+Vector2(0.498,0.498),region+Vector2(0.498,0.002),region+Vector2(0.002,0.002)])
            g.draw_colored_polygon(face,tint,uv,FACADES)
        else:
            g.draw_colored_polygon(face,Color(b.wall).lightened(0.16 if edge==2 else 0.03))
            g._draw_facade_face(b,base[edge],base[next],roof[next],roof[edge],edge)
        g.draw_polyline(PackedVector2Array([face[0],face[1],face[2],face[3],face[0]]),ink,1.5*scale,true)
        # Cornices, entrance light, and façade depth remain geometry, not baked perspective.
        for t in [0.07,0.92]:
            g.draw_line(base[edge].lerp(roof[edge],t),base[next].lerp(roof[next],t),Color(0.76,0.72,0.61,0.65),1.8*scale,true)
        if g.graphics_quality>=2 and edge_vec.length()>170.0 and lift.length()>44.0:
            var sign = base[edge].lerp(base[next],0.63).lerp(roof[edge].lerp(roof[next],0.63),0.21)
            var tangent = edge_vec.normalized()
            var half = minf(25.0*scale,edge_vec.length()*0.13)
            g.draw_line(sign-tangent*half,sign+tangent*half,ink,12.0*scale,true)
            g.draw_line(sign-tangent*half,sign+tangent*half,Color(b.accent).lightened(0.24),3.0*scale,true)
            g.draw_line(sign+Vector2(0,5)*scale-tangent*half*0.85,sign+Vector2(0,5)*scale+tangent*half*0.85,Color(1.0,0.82,0.56,0.8),1.0*scale,true)
    var roof_poly = PackedVector2Array(roof)
    g.draw_colored_polygon(roof_poly,Color(b.roof).lightened(0.18))
    if g.graphics_quality>0:
        var roof_uv = PackedVector2Array()
        for p in world:
            roof_uv.append(p/245.0)
        g.draw_colored_polygon(roof_poly,Color(0.64,0.67,0.69,0.46),roof_uv,ASPHALT)
    g.draw_polyline(PackedVector2Array([roof[0],roof[1],roof[2],roof[3],roof[0]]),ink,2.6*scale,true)
    var center: Vector2 = (roof[0]+roof[1]+roof[2]+roof[3])*0.25
    var inset = PackedVector2Array()
    for p in roof:
        inset.append(center+(p-center)*0.93)
    g.draw_polyline(PackedVector2Array([inset[0],inset[1],inset[2],inset[3],inset[0]]),Color(0.76,0.77,0.73,0.54),1.4*scale,true)
    # Rooftop silhouette: vents, skylights, stair housings, solar panels, terraces.
    if g.graphics_quality>0:
        var count = 2+seed_value%3
        for n in range(count):
            var u = 0.23+float((seed_value/7+n*29)%57)/100.0
            var v = 0.25+float((seed_value/11+n*31)%51)/100.0
            var pos = g._quad_bilerp(roof[0],roof[1],roof[2],roof[3],u,v)
            var size = Vector2(18+seed_value%13,12+seed_value%7)*scale
            var height_offset = lift.normalized()*5.5*scale
            var box = Rect2(pos-size*0.5,size)
            g.draw_rect(Rect2(box.position+Vector2(4,6)*scale,size),Color(0,0,0,0.24))
            g.draw_rect(box,Color("#2a323c"))
            g.draw_rect(Rect2(box.position+height_offset,size),Color("#8c9599"))
            g.draw_rect(Rect2(box.position+height_offset,size),ink,false,1.3*scale)
            for slat in range(4):
                var y = box.position.y+height_offset.y+size.y*(0.2+float(slat)*0.18)
                g.draw_line(Vector2(box.position.x+height_offset.x+2*scale,y),Vector2(box.end.x+height_offset.x-2*scale,y),Color("#394552"),0.8*scale)
    g._draw_roof_detail(b,roof)
    g._draw_massing_detail(b,roof)

static func draw_roads(g: Node2D) -> void:
    var scale: float=g.world_zoom
    # Every footway and curb is laid first. Every carriageway is cut through
    # afterwards, so crossing streets form one open, continuous asphalt surface.
    for road in g.roads:
        if road.get("regional",false):continue
        var projected=PackedVector2Array()
        for p in road.points: projected.append(g._project(p))
        var width: float=float(road.width)*scale
        g.draw_polyline(projected,Color("#19212a"),width+68*scale,true)
        g.draw_polyline(projected,Color("#a89f8b"),width+56*scale,true)
        g.draw_polyline(projected,Color("#c9c3ad"),width+5*scale,true)
        if g.graphics_quality>0:
            for k in range(road.points.size()-1):
                var a: Vector2=road.points[k]
                var b: Vector2=road.points[k+1]
                if not g._world_rect_visible(Rect2(a.min(b),a.max(b)-a.min(b)).grow(float(road.width)+80)): continue
                var normal=(b-a).normalized().orthogonal()
                for side in [-1.0,1.0]:
                    var inner=normal*(float(road.width)*0.5+4)*side
                    var outer=normal*(float(road.width)*0.5+27)*side
                    var poly=PackedVector2Array()
                    var uv=PackedVector2Array()
                    for q in [a+inner,b+inner,b+outer,a+outer]:
                        poly.append(g._project(q))
                        uv.append(q/52.0)
                    g.draw_colored_polygon(poly,Color(0.92,0.90,0.81,1),uv,g.VS_SIDEWALK)
    for road in g.roads:
        if road.get("regional",false):continue
        var pts: PackedVector2Array=road.points
        var projected=PackedVector2Array()
        for p in pts: projected.append(g._project(p))
        var width: float=float(road.width)*scale
        g.draw_polyline(projected,Color("#343e49"),width,true)
        if g.graphics_quality>0:
            for k in range(pts.size()-1):
                var a: Vector2=pts[k]
                var b: Vector2=pts[k+1]
                if not g._world_rect_visible(Rect2(a.min(b),a.max(b)-a.min(b)).grow(float(road.width)+80)): continue
                var normal=(b-a).normalized().orthogonal()*float(road.width)*0.5
                var poly=PackedVector2Array()
                var uv=PackedVector2Array()
                for q in [a-normal,b-normal,b+normal,a+normal]:
                    poly.append(g._project(q))
                    uv.append(q/165.0)
                g.draw_colored_polygon(poly,Color(0.75,0.80,0.88,1),uv,ASPHALT)
        if g._weather_state() in ["rain","storm"]:
            g.draw_polyline(projected,Color(0.26,0.43,0.58,0.12),width-6*scale,true)
    draw_canal_bridges(g)
    for road in g.roads:
        if road.get("regional",false):continue
        var pts: PackedVector2Array = road.points
        var length: float = g._polyline_length(pts)
        var count: int = maxi(1,int(length/52.0))
        for k in range(count):
            var t: float = (float(k)+0.5)/float(count)
            var wp: Vector2 = g._sample_polyline(pts,t)
            var screen: Vector2 = g._project(wp)
            if not g._tile_visible(screen,180.0):
                continue
            var tangent: Vector2 = g._polyline_tangent(pts,t)
            var normal = Vector2(-tangent.y,tangent.x)
            var at_junction = false
            for junction in g.junctions:
                if wp.distance_to(Vector2(junction.pos))<maxf(float(road.width),float(g.roads[int(junction.b)].width))*0.65:
                    at_junction=true
                    break
            if not at_junction:
                for side_sign in [-1.0,1.0]:
                    var yellow = screen+normal*2.0*scale*side_sign
                    g.draw_line(yellow-tangent*25.5*scale,yellow+tangent*25.5*scale,Color("#d4b859"),1.3*scale,true)
                    if float(road.width)>100.0:
                        var lane = screen+normal*float(road.width)*0.27*scale*side_sign
                        g.draw_line(lane-tangent*10*scale,lane+tangent*10*scale,Color("#dedace"),1.6*scale,true)
            if at_junction: continue
            for side_sign in [-1.0,1.0]:
                var curb = screen+normal*(float(road.width)*0.5+13.0)*scale*side_sign
                g.draw_line(curb-normal*9*scale,curb+normal*9*scale,Color(0.15,0.17,0.19,0.28),0.8*scale,true)
        g._draw_road_surface_details(road)
    g._draw_junction_overlays()

static func add_street_blocks(g: Node2D) -> void:
    var local_rng = RandomNumberGenerator.new()
    local_rng.seed=621042
    var protected: Array[Vector2] = [g.player_pos]
    for data in [g.mission_sites,g.named_npcs,g.photo_points,g.scan_points,g.caches,g.glyphs,g.property_sites,g.vertical_sites,g.side_job_sites,g.race_sites]:
        for entry in data:
            if entry.has("pos"):
                protected.append(Vector2(entry.pos))
    for road in g.roads:
        var length: float = g._polyline_length(road.points)
        var count = maxi(1,int(length/280.0))
        for k in range(2,count-2):
            var t = float(k)/float(count)
            var wp: Vector2 = g._sample_polyline(road.points,t)
            var tangent: Vector2 = g._polyline_tangent(road.points,t)
            # Footprint collision remains axis-aligned; reserve bends for parks and plazas.
            if minf(absf(tangent.x),absf(tangent.y))>0.15:
                continue
            var normal = Vector2(-tangent.y,tangent.x)
            for side_sign in [-1.0,1.0]:
                var depth = local_rng.randf_range(100,160)
                var front = local_rng.randf_range(150,225)
                var center = wp+normal*(float(road.width)*0.5+53+depth*0.5)*side_sign
                var size = Vector2(depth,front) if absf(tangent.y)>0.7 else Vector2(front,depth)
                var rect = Rect2(center-size*0.5,size)
                if not Rect2(Vector2(50,50),g.CITY_SIZE-Vector2(100,100)).encloses(rect) or g._rect_in_park(rect) or g._rect_hits_landmark(rect) or g._rect_near_road(rect,34) or g.waters.any(func(w): return Rect2(w.rect).grow(22).intersects(rect)):
                    continue
                var blocked = false
                for p in protected:
                    if rect.grow(110).has_point(p):
                        blocked=true
                        break
                if blocked:
                    continue
                for b in g.buildings:
                    if Rect2(b.rect).grow(28).intersects(rect):
                        blocked=true
                        break
                if blocked:
                    continue
                var district: Dictionary = g._district_at(center)
                var h = local_rng.randf_range(64,115)
                var recipe: Dictionary = g._building_recipe(str(district.style))
                var seed_value = local_rng.randi_range(0,1000000)
                g.buildings.append({"rect":rect,"height":h,"wall":district.wall,"roof":district.roof,"accent":district.accent,"style":district.style,"seed":seed_value,"floors":4,"massing":"slab","facade":recipe.facade[seed_value%recipe.facade.size()],"roof_mode":recipe.roof[seed_value%recipe.roof.size()],"street_block":true})
                var frontage=wp+normal*(float(road.width)*0.5+39.0)*side_sign
                if frontage_is_clear(g,frontage) and not g._point_over_water(frontage):
                    g.street_ensembles.append({"pos":frontage,"tangent":tangent,"normal":normal*side_sign,"seed":seed_value,"style":district.style})
    g.buildings.sort_custom(func(a,b): return Rect2(a.rect).end.y<Rect2(b.rect).end.y)
    # Trees, cafés and benches also belong on open frontages between buildings.
    for road in g.roads:
        var count=maxi(1,int(g._polyline_length(road.points)/190.0))
        for k in range(2,count-2):
            var t=float(k)/float(count)
            var wp: Vector2=g._sample_polyline(road.points,t)
            var tangent: Vector2=g._polyline_tangent(road.points,t)
            var normal=Vector2(-tangent.y,tangent.x)
            for sign_value in [-1.0,1.0]:
                var pos=wp+normal*(float(road.width)*0.5+51.0)*sign_value
                if not frontage_is_clear(g,pos) or g._point_in_building(pos) or g._point_over_water(pos):
                    continue
                g.street_ensembles.append({"pos":pos,"tangent":tangent,"normal":normal*sign_value,"seed":int(absf(pos.x*0.71+pos.y*0.37)),"style":g._district_at(pos).style})

static func frontage_is_clear(g: Node2D, pos: Vector2) -> bool:
    # A frontage on one road can lie in a crossing road. Keep the full furniture
    # footprint clear of every carriageway, including at intersections and bends.
    for road in g.roads:
        if g._distance_to_polyline(pos,road.points)<float(road.width)*0.5+32.0:
            return false
    return true

static func draw_pool(g: Node2D, center: Vector2, radius: float, color: Color) -> void:
    for n in range(18):
        var a=TAU*float(n)/18.0
        var b=TAU*float(n+1)/18.0
        var edge=Color(color.r,color.g,color.b,0.0)
        var poly=PackedVector2Array([center,center+Vector2.from_angle(a)*radius,center+Vector2.from_angle(b)*radius])
        g.draw_polygon(poly,PackedColorArray([color,edge,edge]))

static func draw_pavers(g: Node2D, district: Dictionary) -> void:
    if g.graphics_quality==0 or str(district.style) in ["green","garden","wind"]:
        return
    var r: Rect2=district.rect
    var visible_size: Vector2=g.get_viewport_rect().size/g.world_zoom
    var visible=Rect2(g.camera_pos-visible_size*0.55,visible_size*1.1).intersection(r)
    var step=64.0
    for x in range(int(floor(visible.position.x/step)),int(ceil(visible.end.x/step))+1):
        var wp_x=float(x)*step
        g.draw_line(g._project(Vector2(wp_x,visible.position.y)),g._project(Vector2(wp_x,visible.end.y)),Color(0.74,0.74,0.69,0.09),0.7*g.world_zoom,true)
    for y in range(int(floor(visible.position.y/step)),int(ceil(visible.end.y/step))+1):
        var wp_y=float(y)*step
        g.draw_line(g._project(Vector2(visible.position.x,wp_y)),g._project(Vector2(visible.end.x,wp_y)),Color(0.05,0.08,0.11,0.22),0.9*g.world_zoom,true)

static func draw_junction(g: Node2D, j: Dictionary) -> void:
    var wp: Vector2=j.pos
    var scale: float=g.world_zoom
    var widths=[float(g.roads[int(j.a)].width),float(g.roads[int(j.b)].width)]
    var axes=[g._closest_road_tangent(int(j.a),wp),g._closest_road_tangent(int(j.b),wp)]
    # Crosswalks and stop bars belong on the approaches, beyond the open centre.
    # There is no perimeter box, transverse footway, or raised lip in the node.
    for axis in range(2):
        var tangent: Vector2=axes[axis]
        var normal=Vector2(-tangent.y,tangent.x)
        var own: float=widths[axis]
        var cross: float=widths[1-axis]
        var stripes=maxi(5,int((own-18)/10))
        for sign_value in [-1.0,1.0]:
            var centre=wp+tangent*(cross*0.5+21)*sign_value
            for k in range(stripes):
                var stripe=centre+normal*(float(k)-float(stripes-1)*0.5)*10
                g.draw_line(g._project(stripe-tangent*8),g._project(stripe+tangent*8),Color("#e6dfca"),5*scale,true)
            var stop=centre+tangent*23*sign_value
            g.draw_line(g._project(stop-normal*own*0.43),g._project(stop+normal*own*0.43),Color("#e1dac7"),2.2*scale,true)
            var pole=centre+tangent*13*sign_value+normal*(own*0.5+18)
            var foot: Vector2=g._project(pole)
            var top: Vector2=g._project(pole,14)
            g.draw_line(foot,top,Color("#26363c"),3*scale,true)
            g.draw_rect(Rect2(top-Vector2(3.8,7)*scale,Vector2(7.6,15)*scale),Color("#17242c"))
            var green: bool=g._junction_green(j,int(j.a) if axis==0 else int(j.b))
            g.draw_circle(top+Vector2(0,3 if green else -3)*scale,2*scale,Color("#83dba4") if green else Color("#ee7a67"))
    # Four corner kerbs finish before the zebra; the road surface remains level.
    for sx in [-1.0,1.0]:
        for sy in [-1.0,1.0]:
            var corner=wp+Vector2(sx*(widths[0]*0.5+18),sy*(widths[1]*0.5+18))
            var screen: Vector2=g._project(corner)
            g.draw_circle(screen,6.5*scale,Color("#918d7c"))
            g.draw_circle(screen,3.8*scale,Color("#c3bea7"))

static func draw_canal_bridges(g: Node2D) -> void:
    # Water runs underneath a continuous deck; stone abutments and guardrails
    # identify these spans without implying a flyover at ordinary intersections.
    for road in g.roads:
        if road.get("regional",false):continue
        for k in range(road.points.size()-1):
            var a: Vector2=road.points[k]
            var b: Vector2=road.points[k+1]
            var tangent=(b-a).normalized()
            var normal=Vector2(-tangent.y,tangent.x)
            for water in g.waters:
                if water.get("regional",false):continue
                var r: Rect2=water.rect
                var first=0.0
                var last=1.0
                var hit=true
                for axis in range(2):
                    var d: float=(b-a)[axis]
                    if absf(d)<0.001:
                        if a[axis]<r.position[axis] or a[axis]>r.end[axis]: hit=false; break
                    else:
                        var t1=(r.position[axis]-a[axis])/d
                        var t2=(r.end[axis]-a[axis])/d
                        first=maxf(first,minf(t1,t2))
                        last=minf(last,maxf(t1,t2))
                        if first>last: hit=false; break
                if not hit or last<first: continue
                var begin=a.lerp(b,first)-tangent*18
                var finish=a.lerp(b,last)+tangent*18
                if not g._world_rect_visible(Rect2(begin.min(finish),begin.max(finish)-begin.min(finish)).grow(150)): continue
                var half: float=float(road.width)*0.5+29
                for side in [-1.0,1.0]:
                    var e1=begin+normal*half*side
                    var e2=finish+normal*half*side
                    g.draw_line(g._project(e1),g._project(e2),Color(0.02,0.09,0.12,0.48),8*g.world_zoom,true)
                    g.draw_line(g._project(e1,9),g._project(e2,9),Color("#b5c6c3"),3*g.world_zoom,true)
                    var count=maxi(1,int(begin.distance_to(finish)/55))
                    for i in range(count+1):
                        var post=e1.lerp(e2,float(i)/count)
                        g.draw_line(g._project(post),g._project(post,9),Color("#879e9e"),2.8*g.world_zoom,true)
                for end in [begin,finish]:
                    for side in [-1.0,1.0]:
                        var p: Vector2=g._project(end+normal*(half+4)*side)
                        g.draw_rect(Rect2(p-Vector2(8,11)*g.world_zoom,Vector2(16,22)*g.world_zoom),Color("#7e9594"))
                        g.draw_rect(Rect2(p-Vector2(8,11)*g.world_zoom,Vector2(16,22)*g.world_zoom),Color("#203842"),false,1.5*g.world_zoom)

static func clear_crossings(g: Node, own_road: int, a: Vector2, b: Vector2, clearance: float) -> Array:
    # Subtract other carriageways from a footway/lane centreline in world space.
    # The same intervals drive 3D sidewalk meshes, so there is no raised curb
    # slab across an at-grade junction in the photo scene either.
    var intervals: Array=[Vector2(0,1)]
    for ri in range(g.roads.size()):
        if ri==own_road: continue
        var road: Dictionary=g.roads[ri]
        for k in range(road.points.size()-1):
            var begin: Vector2=road.points[k]
            var end: Vector2=road.points[k+1]
            var tangent=(end-begin).normalized()
            var normal=Vector2(-tangent.y,tangent.x)
            var center=(begin+end)*0.5
            var start=Vector2((a-center).dot(tangent),(a-center).dot(normal))
            var finish=Vector2((b-center).dot(tangent),(b-center).dot(normal))
            var delta=finish-start
            var half=Vector2(begin.distance_to(end)*0.5,float(road.width)*0.5+clearance)
            var first=0.0
            var last=1.0
            var hit=true
            for axis in range(2):
                if absf(delta[axis])<0.001:
                    if absf(start[axis])>half[axis]: hit=false; break
                else:
                    var near_t=(-half[axis]-start[axis])/delta[axis]
                    var far_t=(half[axis]-start[axis])/delta[axis]
                    first=maxf(first,minf(near_t,far_t))
                    last=minf(last,maxf(near_t,far_t))
                    if first>last: hit=false; break
            if not hit: continue
            var remaining: Array=[]
            for interval in intervals:
                if last<=interval.x or first>=interval.y:
                    remaining.append(interval)
                else:
                    if first>interval.x: remaining.append(Vector2(interval.x,first))
                    if last<interval.y: remaining.append(Vector2(last,interval.y))
            intervals=remaining
    var result: Array=[]
    for interval in intervals:
        if a.distance_to(b)*(interval.y-interval.x)>2:
            result.append(PackedVector2Array([a.lerp(b,interval.x),a.lerp(b,interval.y)]))
    return result

static func draw_street_pools(g: Node2D) -> void:
    if g.graphics_quality==0:
        return
    for s in g.street_ensembles:
        var p: Vector2=g._project(s.pos)
        if not g._tile_visible(p,160):
            continue
        draw_pool(g,p,64*g.world_zoom,Color(1.0,0.64,0.24,0.21))
        if int(s.seed)%3==0:
            var accent: Color=g._district_at(s.pos).accent
            draw_pool(g,p+Vector2(s.normal)*22*g.world_zoom,48*g.world_zoom,Color(accent.r,accent.g,accent.b,0.13))

static func draw_street_ensembles(g: Node2D) -> void:
    var scale: float=g.world_zoom
    for s in g.street_ensembles:
        var world: Vector2=s.pos
        var base: Vector2=g._project(world)
        if not g._tile_visible(base,210):
            continue
        var seed_value: int=int(s.seed)
        var tangent: Vector2=s.tangent
        var normal: Vector2=s.normal
        # Raised slab and warm lamp define a coherent sidewalk frontage.
        var paving=Rect2(base-Vector2(28,26)*scale,Vector2(56,52)*scale)
        g.draw_rect(paving,Color(0.45,0.43,0.38,0.30))
        var pole_world=world-tangent*30
        var foot: Vector2=g._project(pole_world)
        var lamp: Vector2=g._project(pole_world,44)
        g.draw_line(foot+Vector2(5,6)*scale,foot+Vector2(24,30)*scale,Color(0,0,0,0.22),3*scale,true)
        g.draw_line(foot,lamp,Color("#121923"),3.5*scale,true)
        g.draw_line(foot+Vector2(1,0)*scale,lamp+Vector2(1,0)*scale,Color("#7b8281"),0.8*scale,true)
        g.draw_line(lamp,lamp-normal*10*scale,Color("#1c2028"),3*scale,true)
        g.draw_circle(lamp-normal*10*scale,3.5*scale,Color("#ffe0a1"))
        var variant=seed_value%4
        if variant==0 or str(s.style) in ["coast","canal","neon"]:
            var tree_world=world+tangent*16+normal*8
            var root: Vector2=g._project(tree_world)
            var crown: Vector2=g._project(tree_world,52)
            g.draw_rect(Rect2(root-Vector2(13,9)*scale,Vector2(26,18)*scale),Color("#746954"))
            g.draw_line(root,crown,Color("#111a18"),6*scale,true)
            g.draw_line(root,crown,Color("#8c7950"),3.4*scale,true)
            for leaf in range(9):
                var angle=TAU*float(leaf)/9.0+sin(float(Time.get_ticks_msec())/1800+seed_value)*0.045
                var direction=Vector2.from_angle(angle)
                var side=Vector2(-direction.y,direction.x)
                var length=(23+seed_value%7)*scale
                var poly=PackedVector2Array([crown,crown+direction*length*0.52+side*5*scale,crown+direction*length+Vector2(0,4)*scale,crown+direction*length*0.52-side*3*scale])
                g.draw_colored_polygon(poly,Color("#34734b") if leaf%2==0 else Color("#234f36"))
                g.draw_polyline(PackedVector2Array([poly[0],poly[1],poly[2],poly[3],poly[0]]),Color("#142a21"),0.8*scale,true)
                g.draw_line(crown,crown+direction*length*0.88,Color("#72a154"),0.8*scale,true)
        elif variant==1:
            var cafe_world=world+tangent*14+normal*17
            var table: Vector2=g._project(cafe_world,9)
            var canopy: Vector2=g._project(cafe_world,27)
            g.draw_circle(table,10*scale,Color("#c9ae79"))
            for chair in [-1.0,1.0]:
                var pos=table+tangent*17*scale*chair
                g.draw_circle(pos+Vector2(2,4)*scale,5*scale,Color(0,0,0,0.2))
                g.draw_rect(Rect2(pos-Vector2(4,4)*scale,Vector2(8,8)*scale),Color("#9a6e48"))
            for wedge in range(8):
                var a=TAU*float(wedge)/8.0
                var b=TAU*float(wedge+1)/8.0
                var poly=PackedVector2Array([canopy,canopy+Vector2.from_angle(a)*20*scale,canopy+Vector2.from_angle(b)*20*scale])
                g.draw_colored_polygon(poly,Color("#c84b38") if wedge%2==0 else Color("#ed7751"))
                g.draw_line(poly[0],poly[1],Color("#582c24"),0.9*scale,true)
            g.draw_arc(canopy,20*scale,0,TAU,24,Color("#462d29"),1.5*scale,true)
            g.draw_circle(canopy,2.0*scale,Color("#f6d6ad"))
        else:
            var bench: Vector2=g._project(world+tangent*15+normal*14,8)
            for slat in range(4):
                var offset=normal*float(slat-2)*2.4*scale
                g.draw_line(bench-tangent*16*scale+offset,bench+tangent*16*scale+offset,Color("#af8153"),1.7*scale,true)
            for leg in [-1.0,1.0]:
                g.draw_line(bench+tangent*12*scale*leg-normal*7*scale,bench+tangent*12*scale*leg+normal*8*scale,Color("#23302b"),2.2*scale,true)
            var planter: Vector2=g._project(world+normal*26-tangent*11,4)
            g.draw_rect(Rect2(planter-Vector2(7,6)*scale,Vector2(14,12)*scale),Color("#a99a7b"))
            g.draw_circle(planter-Vector2(0,7)*scale,9*scale,Color("#3f784a"))
            g.draw_circle(planter+Vector2(3,-8)*scale,5*scale,Color("#71995a"))

static func draw_vehicle(g: Node2D, pos: Vector2, heading: float, cls: String, color: Color, parked: bool, archetype: String) -> void:
    var scale: float=g.world_zoom
    var size: Vector2=g.VEHICLE_SIZES.get(cls,Vector2(45,22))*scale
    var center: Vector2=g._project(pos,8)
    var forward=Vector2.from_angle(heading)
    var side=Vector2(-forward.y,forward.x)
    g._draw_poly_ellipse(center+Vector2(4,6)*scale,Vector2(size.x*0.53,size.y*0.52),heading,Color(0,0,0,0.26))
    var index: int=g.VEHICLE_CLASSES.find(cls)
    if archetype=="response": index=10
    if archetype=="ambulance": index=11
    var cell: Vector2=Vector2(VEHICLES.get_size())/Vector2(3,4)
    var source=Rect2(Vector2(index%3,index/3)*cell,cell)
    var sprite_size=Vector2(size.y*1.65,size.x*1.28)
    g.draw_set_transform(center,heading+PI*0.5,Vector2.ONE)
    g.draw_texture_rect_region(VEHICLES,Rect2(-sprite_size*0.5,sprite_size),source,Color.WHITE if index>=10 else color.lightened(0.12))
    g.draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
    var player_car: bool=g.current_vehicle>=0 and g.player_pos.distance_to(pos)<2 and not parked
    var braking: bool=player_car and g.vehicle_braking
    var front=center+forward*size.x*0.43
    var rear=center-forward*size.x*0.44
    var dark: bool=g.world_clock>18 or g.world_clock<7 or g._weather_state() in ["rain","storm","mist"]
    if dark:
        for sign_value in [-1.0,1.0]:
            var headlight=front+side*size.y*0.30*sign_value
            var beam=PackedVector2Array([headlight-side*2*scale,headlight+side*2*scale,headlight+forward*80*scale+side*18*scale,headlight+forward*80*scale-side*18*scale])
            g.draw_colored_polygon(beam,Color(1.0,0.84,0.52,0.05))
            g.draw_circle(headlight,1.5*scale,Color("#fff0c7"))
            draw_pool(g,rear+side*size.y*0.3*sign_value,12*scale,Color(1,0.08,0.1,0.14 if braking else 0.045))
    if g._is_emergency_archetype(archetype):
        var pulse=0.5+0.5*sin(float(Time.get_ticks_msec())/120)
        for sign_value in [-1.0,1.0]:
            var light=center+side*size.y*0.27*sign_value
            var flash=Color(1.0,0.08,0.16,0.18*pulse) if sign_value<0 else Color(0.15,0.48,1.0,0.18*(1.0-pulse))
            draw_pool(g,light,24*scale,flash)
            g.draw_circle(light,2.0*scale,Color(flash.r,flash.g,flash.b,0.85))
    if archetype=="taxi":
        g.draw_line(center-side*4*scale,center+side*4*scale,Color("#ffcf51"),3*scale,true)
    if player_car and absf(g.vehicle_velocity)>200 and absf(g.vehicle_turn_error)>0.7:
        for sign_value in [-1.0,1.0]:
            var tire=rear+side*size.y*0.40*sign_value
            g.draw_line(tire,tire-forward*23*scale,Color(0,0,0,0.27),2*scale,true)
            draw_pool(g,tire-forward*12*scale,14*scale,Color(0.79,0.84,0.86,0.20))
