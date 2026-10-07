extends RefCounted
## Body-clear road links connect atlas guidance and the visible street route.
static func build(g: Node) -> void:
    g.navigation_graph.clear()
    var segments: Array=[]
    for road in g.roads:
        for k in range(road.points.size()-1):
            var a: Vector2=road.points[k]
            var b: Vector2=road.points[k+1]
            var cuts: Array=[0.0,1.0]
            var steps: int=maxi(1,int(ceil(a.distance_to(b)/850.0)))
            for i in range(1,steps):cuts.append(float(i)/steps)
            segments.append({"a":a,"b":b,"cuts":cuts})
    for i in range(segments.size()):
        for j in range(i+1,segments.size()):
            var s: Dictionary=segments[i]
            var t: Dictionary=segments[j]
            var hit=Geometry2D.segment_intersects_segment(s.a,s.b,t.a,t.b)
            if hit is Vector2:
                s.cuts.append(clampf((hit-s.a).dot(s.b-s.a)/(s.b-s.a).length_squared(),0,1))
                t.cuts.append(clampf((hit-t.a).dot(t.b-t.a)/(t.b-t.a).length_squared(),0,1))
    var ids: Dictionary={}
    for s in segments:
        s.cuts.sort()
        var previous: int=-1
        for cut in s.cuts:
            var p: Vector2=Vector2(s.a).lerp(s.b,float(cut))
            var key:=Vector2i(roundi(p.x),roundi(p.y))
            if not ids.has(key):
                var id: int=ids.size()
                ids[key]=id
                g.navigation_graph.add_point(id,p)
                if g._point_blocked(p,18):g.navigation_graph.set_point_disabled(id,true)
            var id: int=ids[key]
            if previous>=0 and previous!=id and not g.navigation_graph.is_point_disabled(id) and not g.navigation_graph.is_point_disabled(previous):
                if g.CityAccess.path_clear(g,g.navigation_graph.get_point_position(previous),p,18):g.navigation_graph.connect_points(previous,id)
            previous=id
    g.navigation_timer=0.0

static func attachment(g: Node,p: Vector2) -> int:
    var candidates: Array=[]
    for id in g.navigation_graph.get_point_ids():
        if g.navigation_graph.is_point_disabled(id):continue
        candidates.append({"id":id,"d":p.distance_squared_to(g.navigation_graph.get_point_position(id))})
    candidates.sort_custom(func(a,b):return a.d<b.d)
    for i in range(mini(40,candidates.size())):
        var id: int=candidates[i].id
        if g.navigation_graph.get_point_connections(id).is_empty():continue
        if g.CityAccess.path_clear(g,p,g.navigation_graph.get_point_position(id),14):return id
    return -1

static func route(g: Node,from: Vector2,target: Vector2) -> PackedVector2Array:
    var out:=PackedVector2Array()
    if target==Vector2.ZERO:return out
    if from.distance_to(target)<180 and g.CityAccess.path_clear(g,from,target,14):return PackedVector2Array([from,target])
    var start:=attachment(g,from)
    var finish:=attachment(g,target)
    if start>=0 and finish>=0:
        var middle: PackedVector2Array=g.navigation_graph.get_point_path(start,finish)
        if not middle.is_empty():out.append(from);out.append_array(middle);out.append(target)
    if out.is_empty() and g.CityAccess.path_clear(g,from,target,14):out=PackedVector2Array([from,target])
    return out

static func length(points: PackedVector2Array) -> float:
    var total:=0.0
    for i in range(points.size()-1):total+=points[i].distance_to(points[i+1])
    return total

static func refresh(g: Node,delta: float) -> void:
    g.navigation_timer-=delta
    var target: Vector2=g._current_objective_pos()
    if target!=g.navigation_target or g.navigation_timer<=0:
        g.navigation_target=target;g.navigation_route=route(g,g.player_pos,target);g.navigation_timer=1.2

static func draw_route(g: Node2D) -> void:
    if g._modal_active() or g.interior_active or g.photo_mode:return
    var line: PackedVector2Array=g.navigation_route
    for i in range(line.size()-1):
        var a: Vector2=line[i]
        var b: Vector2=line[i+1]
        if not g._world_rect_visible(Rect2(a.min(b),a.max(b)-a.min(b)).grow(70)):continue
        var count: int=maxi(1,int(ceil(a.distance_to(b)/70)))
        for k in range(count):
            var p: Vector2=a.lerp(b,float(k)/count)
            if not g._tile_visible(g._project(p),50):continue
            var end: Vector2=a.lerp(b,minf(1,(float(k)+.42)/count))
            g.draw_line(g._project(p),g._project(end),Color(.02,.07,.06,.7),6*g.world_zoom,true)
            g.draw_line(g._project(p),g._project(end),Color("#cbe4a0"),2.4*g.world_zoom,true)
