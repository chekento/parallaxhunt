extends RefCounted
## Deterministic access repair keeps persistent collectible IDs and actor indices.
const CELL := 360.0

static func rebuild_index(g: Node) -> void:
    g.collision_grid.clear()
    for b in g.buildings:
        var r: Rect2=Rect2(b.rect).grow(32)
        for x in range(int(floor(r.position.x/CELL)),int(floor(r.end.x/CELL))+1):
            for y in range(int(floor(r.position.y/CELL)),int(floor(r.end.y/CELL))+1):
                var key=Vector2i(x,y)
                if not g.collision_grid.has(key): g.collision_grid[key]=[]
                g.collision_grid[key].append(Rect2(b.rect))
    g.collision_index_ready=true

static func blocked(g: Node, p: Vector2, radius: float) -> bool:
    if p.x<radius or p.y<radius or p.x>g.WORLD_SIZE.x-radius or p.y>g.WORLD_SIZE.y-radius:
        return true
    for l in g.landmarks:
        if g._landmark_rect(l).grow(radius).has_point(p): return true
    if g.collision_index_ready:
        var key=Vector2i(int(floor(p.x/CELL)),int(floor(p.y/CELL)))
        for r in g.collision_grid.get(key,[]):
            if r.grow(radius).has_point(p): return true
    else:
        for b in g.buildings:
            if Rect2(b.rect).grow(radius).has_point(p): return true
    for w in g.waters:
        if Rect2(w.rect).grow(radius).has_point(p):
            if w.has("polygon"):
                var edge:=PackedVector2Array(w.polygon)
                edge.append(edge[0])
                if not Geometry2D.is_point_in_polygon(p,w.polygon) and g._distance_to_polyline(p,edge)>radius:continue
            var bridge_walk=false
            for road in g.roads:
                # Bridge footways are real, painted surfaces, with body clearance.
                if g._distance_to_polyline(p,road.points)<=float(road.width)*0.5+28.0-radius:
                    bridge_walk=true
                    break
            if not bridge_walk: return true
    return false

static func path_clear(g: Node, a: Vector2, b: Vector2, radius: float=14.0) -> bool:
    var count=maxi(1,int(ceil(a.distance_to(b)/18.0)))
    for i in range(count+1):
        if blocked(g,a.lerp(b,float(i)/count),radius): return false
    return true

static func road_projections(g: Node, p: Vector2) -> Array:
    var result: Array=[]
    for road in g.roads:
        for k in range(road.points.size()-1):
            var a: Vector2=road.points[k]
            var b: Vector2=road.points[k+1]
            var segment=b-a
            var q=a+segment*clampf((p-a).dot(segment)/maxf(1,segment.length_squared()),0,1)
            result.append({"pos":q,"distance":p.distance_squared_to(q),"tangent":segment.normalized(),"width":float(road.width)})
    result.sort_custom(func(a,b): return a.distance<b.distance)
    return result

static func connected(g: Node, p: Vector2, radius: float=14.0) -> bool:
    if blocked(g,p,radius): return false
    var projections=road_projections(g,p)
    for i in range(mini(6,projections.size())):
        if path_clear(g,p,projections[i].pos,radius): return true
    return false

static func safe_point(g: Node, p: Vector2, radius: float=16.0) -> Vector2:
    if connected(g,p,radius): return p
    var candidates: Array=[]
    var projections=road_projections(g,p)
    for i in range(mini(8,projections.size())):
        var r: Dictionary=projections[i]
        var normal=Vector2(-r.tangent.y,r.tangent.x)
        for along in [0.0,-90.0,90.0,-220.0,220.0,-420.0,420.0]:
            var road_pos: Vector2=r.pos+r.tangent*along
            for side in [-1.0,1.0,0.0]:
                var candidate=road_pos+normal*(r.width*0.5+12.0)*side
                candidates.append({"pos":candidate,"road":road_pos,"score":p.distance_squared_to(candidate)+(1500.0 if side==0 else 0.0)})
    candidates.sort_custom(func(a,b): return a.score<b.score)
    for candidate in candidates:
        if path_clear(g,candidate.pos,candidate.road,radius): return candidate.pos
    # A known connected boulevard, used only if a malformed imported coordinate has no local approach.
    return Vector2(5100,4220)

static func repair(g: Node) -> void:
    rebuild_index(g)
    g.access_repairs=0
    for data in [g.named_npcs,g.caches,g.glyphs,g.mission_sites,g.property_sites,g.vertical_sites,g.scan_points,g.photo_points,g.side_job_sites,g.city_micro_events,g.storefronts,g.fragments,g.secrets,g.region_pois]:
        for entry in data:
            var before: Vector2=entry.pos
            var after=safe_point(g,before)
            entry["pos"]=after
            if after!=before:
                entry["original_pos"]=before
                g.access_repairs+=1
    g.district_access_points.clear()
    for district in g.districts:
        g.district_access_points[str(district.name)]=safe_point(g,Rect2(district.rect).get_center())
    g.player_pos=safe_point(g,g.player_pos)
